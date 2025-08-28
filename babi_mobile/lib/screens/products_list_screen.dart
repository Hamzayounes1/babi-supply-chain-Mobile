// lib/screens/products_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends StatefulWidget {
  static const String routeName = '/products';
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([Product? existing]) async {
    final created = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => ProductFormScreen(existing: existing)),
    );
    if (created == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final products = provider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(onPressed: () => _openForm(), icon: const Icon(Icons.add)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error loading products', style: TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : products.isEmpty
                  ? Center(child: Text('No products found.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (ctx, i) {
                          final p = products[i];
                          return ListTile(
                            title: Text(p.name),
                            subtitle: Text('${p.sku}\n${p.description}'),
                            trailing: Text('\$${p.price.toStringAsFixed(2)}'),
                            isThreeLine: true,
                            onTap: () => _openForm(p),
                          );
                        },
                      ),
                    ),
    );
  }
}
