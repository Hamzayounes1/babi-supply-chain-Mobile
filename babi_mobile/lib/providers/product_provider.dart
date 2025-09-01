// lib/providers/product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

/// ProductProvider: API-backed provider for products.
/// Exposes addProduct(...) because your UI expects that exact name.
class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  String? lastError;

  /// Fetch products from backend and populate local list
  Future<void> fetchProducts({int page = 1, String? search}) async {
    lastError = null;
    try {
      debugPrint('[ProductProvider] fetchProducts page=$page search=$search');
      final items = await _service.list(page: page, search: search);
      _products
        ..clear()
        ..addAll(items);
      notifyListeners();
    } catch (e, st) {
      lastError = e.toString();
      debugPrint('[ProductProvider] fetchProducts error: $e\n$st');
      rethrow;
    }
  }

  /// Low-level create: calls ProductService.create and returns created Product
  Future<Product> create(Product payload) async {
    lastError = null;
    try {
      debugPrint('[ProductProvider] create payload=${payload.toJson()}');
      final created = await _service.create(payload);
      _products.add(created);
      notifyListeners();
      debugPrint('[ProductProvider] created product id=${created.id}');
      return created;
    } catch (e, st) {
      lastError = e.toString();
      debugPrint('[ProductProvider] create error: $e\n$st');
      rethrow;
    }
  }

  /// **Public method your UI expects**:
  /// Adds product by calling the API-backed create(...) above.
  Future<void> addProduct(Product product) async {
    await create(product);
  }

  /// Update existing product (PUT) and update local list
  Future<Product> update(Product payload) async {
    lastError = null;
    try {
      debugPrint('[ProductProvider] update id=${payload.id} payload=${payload.toJson()}');
      final updated = await _service.update(payload.id, payload);
      final idx = _products.indexWhere((p) => p.id == updated.id);
      if (idx >= 0) _products[idx] = updated;
      notifyListeners();
      return updated;
    } catch (e, st) {
      lastError = e.toString();
      debugPrint('[ProductProvider] update error: $e\n$st');
      rethrow;
    }
  }

  /// Delete product (DELETE) and remove from local list
  Future<void> delete(String id) async {
    lastError = null;
    try {
      debugPrint('[ProductProvider] delete id=$id');
      await _service.delete(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e, st) {
      lastError = e.toString();
      debugPrint('[ProductProvider] delete error: $e\n$st');
      rethrow;
    }
  }
}
