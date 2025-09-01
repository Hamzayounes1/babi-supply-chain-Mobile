import 'package:flutter/material.dart';
import '../models/inventory.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<Inventory> _inventories = [];
  List<Inventory> get inventories => _inventories;

  final InventoryService _service = InventoryService();

  Future<void> fetchInventories() async {
    try {
      _inventories = await _service.fetchInventories();
      notifyListeners();
    } catch (e) {
      print('Error fetching inventories: $e');
    }
  }

  Future<void> addInventory(Inventory inventory) async {
    await _service.createInventory(inventory);
    await fetchInventories();  // refresh list
  }
}
