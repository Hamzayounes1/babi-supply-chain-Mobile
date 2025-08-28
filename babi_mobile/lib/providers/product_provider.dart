import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  final List<Product> _products = [];

  List<Product> get products => [..._products];

  String? lastError;

  /// Fetch products from backend
  Future<void> fetchProducts({int page = 1, String? search}) async {
    lastError = null;
    try {
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

  /// Low-level create (returns created Product)
  Future<Product> create(Product payload) async {
    lastError = null;
    try {
      final created = await _service.create(payload);
      _products.add(created);
      notifyListeners();
      return created;
    } catch (e, st) {
      lastError = e.toString();
      debugPrint('[ProductProvider] create error: $e\n$st');
      rethrow;
    }
  }

  /// Public method your UI expects: addProduct
  /// Calls the API-backed create and returns when done.
  Future<void> addProduct(Product product) async {
    await create(product);
  }

  /// Update existing product (API + local list)
  Future<Product> update(Product payload) async {
    lastError = null;
    try {
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

  /// Delete product (API + local list)
  Future<void> delete(String id) async {
    lastError = null;
    try {
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
