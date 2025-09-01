import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier.dart';

class SupplierService {
  final String baseUrl = 'http://127.0.0.1:8000'; // replace with your API base URL

  Future<List<Supplier>> fetchSuppliers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/suppliers'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Supplier.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load suppliers');
    }
  }

  Future<void> createSupplier(Supplier supplier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/suppliers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(supplier.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create supplier');
    }
  }
}
