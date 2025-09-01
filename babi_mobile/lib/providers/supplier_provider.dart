import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  final SupplierService _service = SupplierService();

  Future<void> fetchSuppliers() async {
    try {
      _suppliers = await _service.fetchSuppliers();
      notifyListeners();
    } catch (e) {
      print('Error fetching suppliers: $e');
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _service.createSupplier(supplier);
      await fetchSuppliers(); // refresh list after adding
    } catch (e) {
      print('Error adding supplier: $e');
    } finally {
      notifyListeners(); // 🔑 ensure UI rebuilds even if something went wrong
    }
  }
}
