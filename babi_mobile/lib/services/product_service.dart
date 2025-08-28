// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/product.dart';
import 'package:flutter/foundation.dart';

class ProductService {
  final String _base = AuthService.API_BASE; // must include /api
  final AuthService _auth = AuthService();

  /// Fetch list of products with optional pagination and search
  Future<List<Product>> list({int page = 1, String? search}) async {
    final token = await _auth.getToken();

    final uri = Uri.parse('$_base/api/products').replace(
      queryParameters: {
        if (page > 1) 'page': page.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    http.Response res;
    try {
      res = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
    } catch (e) {
      throw Exception('Network error while fetching products: $e');
    }

    final data = _decode(res);

    if (!data.ok) {
      throw Exception('Failed to fetch products: ${data.message} (status ${res.statusCode})');
    }

    final body = data.body;

    // Accept either plain array or { data: [...] } or { items: [...] }
    final items = (body is List)
        ? body
        : (body is Map && body['data'] is List)
            ? body['data']
            : (body is Map && body['items'] is List)
                ? body['items']
                : <dynamic>[];

    return (items as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Create a new product
  Future<Product> create(Product payload) async {
    final token = await _auth.getToken();

    http.Response res;
    try {
      res = await http.post(Uri.parse('$_base/api/products'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload.toJson()));
    } catch (e) {
      throw Exception('Network error while creating product: $e');
    }

    final data = _decode(res);

    if (data.validationErrors != null && data.validationErrors!.isNotEmpty) {
      throw ValidationException(data.validationErrors!, data.message ?? 'Validation failed');
    }
    if (!data.ok) {
      throw Exception('Create product failed: ${data.message} (status ${res.statusCode})');
    }

    final body = data.body;
    final obj = (body is Map && body['data'] != null) ? body['data'] : body;

    return Product.fromJson(Map<String, dynamic>.from(obj as Map));
  }

  /// Update an existing product
  /// accepts numeric or string id
  Future<Product> update(dynamic id, Product payload) async {
    final token = await _auth.getToken();
    final idStr = id.toString();

    http.Response res;
    try {
      res = await http.put(Uri.parse('$_base/api/products/$idStr'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload.toJson()));
    } catch (e) {
      throw Exception('Network error while updating product: $e');
    }

    final data = _decode(res);

    if (data.validationErrors != null && data.validationErrors!.isNotEmpty) {
      throw ValidationException(data.validationErrors!, data.message ?? 'Validation failed');
    }
    if (!data.ok) {
      throw Exception('Update product failed: ${data.message} (status ${res.statusCode})');
    }

    final body = data.body;
    final obj = (body is Map && body['data'] != null) ? body['data'] : body;

    return Product.fromJson(Map<String, dynamic>.from(obj as Map));
  }

  /// Delete a product
  Future<void> delete(dynamic id) async {
    final token = await _auth.getToken();
    final idStr = id.toString();

    http.Response res;
    try {
      res = await http.delete(Uri.parse('$_base/products/$idStr'), headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
    } catch (e) {
      throw Exception('Network error while deleting product: $e');
    }

    final data = _decode(res);

    if (!data.ok) {
      throw Exception('Delete product failed: ${data.message} (status ${res.statusCode})');
    }
  }

  // ---------- helpers ----------

  /// Decode response body to either Map or List
  _Resp _decode(http.Response res) {
    dynamic parsed;
    try {
      parsed = res.body.isEmpty ? {} : jsonDecode(res.body);
    } catch (e) {
      // if JSON parsing fails, log raw body for debugging
      if (kDebugMode) debugPrint('[ProductService] JSON parse error: $e — body: ${res.body}');
      parsed = {'raw': res.body};
    }

    if (kDebugMode) {
      debugPrint('[ProductService] ${res.request?.method ?? 'HTTP'} ${res.request?.url} status=${res.statusCode} body=${res.body}');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // success: parsed can be Map or List
      return _Resp(true, parsed, null, null);
    }

    // handle validation errors (422)
    if (res.statusCode == 422) {
      final errors = <String, List<String>>{};
      if (parsed is Map && parsed['errors'] is Map) {
        (parsed['errors'] as Map).forEach((k, v) {
          try {
            errors[k.toString()] = List<String>.from(v as List);
          } catch (_) {
            errors[k.toString()] = [v.toString()];
          }
        });
      }
      final msg = (parsed is Map && parsed['message'] != null) ? parsed['message'].toString() : 'Validation error';
      return _Resp(false, parsed is Map ? parsed : {'body': parsed}, msg, errors);
    }

    // generic error
    final msg = (parsed is Map && parsed['message'] != null) ? parsed['message'].toString() : 'Request failed';
    return _Resp(false, parsed is Map ? parsed : {'body': parsed}, msg, null);
  }
}

class _Resp {
  final bool ok;
  final dynamic body; // can be Map or List or other
  final String? message;
  final Map<String, List<String>>? validationErrors;

  _Resp(this.ok, this.body, this.message, this.validationErrors);
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;
  final String message;

  ValidationException(this.errors, this.message);

  @override
  String toString() => 'ValidationException: $message — errors: $errors';
}
