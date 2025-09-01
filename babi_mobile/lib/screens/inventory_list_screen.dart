import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class InventoryListScreen extends StatefulWidget {
  static const routeName = '/inventories';
  @override
  createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch inventory items when screen is initialized
    Provider.of<InventoryProvider>(context, listen: false).fetchInventories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Inventory Items', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          final inventories = provider.inventories;
          if (inventories.isEmpty) {
            return const Center(child: Text('No inventory items found.'));
          }
          return ListView.builder(
            itemCount: inventories.length,
            itemBuilder: (context, index) {
              final item = inventories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('Warehouse: ${item.warehouseId}, Product: ${item.productId}'),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.indigo),
                    onPressed: () {
                      Navigator.pushNamed(context, '/inventory_form', arguments: item);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade600,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/inventory_form');
        },
      ),
    );
  }
}
