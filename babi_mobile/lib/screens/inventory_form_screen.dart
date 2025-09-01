import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory.dart';

class InventoryFormScreen extends StatefulWidget {
  static const routeName = '/inventory-form';
  @override
  _InventoryFormScreenState createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _warehouseIdController = TextEditingController();
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _warehouseIdController.dispose();
    _productIdController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Add Inventory Item', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _warehouseIdController,
                        decoration: const InputDecoration(labelText: 'Warehouse ID'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Enter warehouse ID' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _productIdController,
                        decoration: const InputDecoration(labelText: 'Product ID'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Enter product ID' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Save'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final newItem = Inventory(
                                warehouseId: int.parse(_warehouseIdController.text),
                                productId: int.parse(_productIdController.text),
                                quantity: int.parse(_quantityController.text),
                              );
                              await Provider.of<InventoryProvider>(context, listen: false)
                                  .addInventory(newItem);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
