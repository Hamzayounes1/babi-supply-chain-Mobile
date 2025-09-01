import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory.dart';

class InventoryService {
  final String baseUrl = 'http://127.0.0.1:8000'; // replace with your API base URL

  Future<List<Inventory>> fetchInventories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/inventories'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inventories');
    }
  }

  Future<void> createInventory(Inventory inventory) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(inventory.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create inventory item');
    }
  }
}
