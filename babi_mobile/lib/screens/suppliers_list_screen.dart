import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';

class SuppliersListScreen extends StatefulWidget {
  static const routeName = '/suppliers';
  @override
  _SuppliersListScreenState createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends State<SuppliersListScreen> {
  final Color accentColor = Colors.indigo.shade600;

  @override
  void initState() {
    super.initState();
    // Fetch suppliers when screen is initialized
    Provider.of<SupplierProvider>(context, listen: false).fetchSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Suppliers', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, provider, child) {
          final suppliers = provider.suppliers;
          if (suppliers.isEmpty) {
            return const Center(child: Text('No suppliers found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(supplier.name),
                  subtitle: Text('${supplier.contactEmail}\n${supplier.phone}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/supplier-form');
        },
      ),
    );
  }
}
