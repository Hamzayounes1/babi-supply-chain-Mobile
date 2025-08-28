// lib/screens/product_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  static const String routeName = '/product-form';
  final Product? existing;

  const ProductFormScreen({super.key, this.existing});

  @override
  ProductFormScreenState createState() => ProductFormScreenState();
}

class ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _sku, _description;
  late double _price;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _name = widget.existing!.name;
      _sku = widget.existing!.sku;
      _description = widget.existing!.description;
      _price = widget.existing!.price;
    } else {
      _name = '';
      _sku = '';
      _description = '';
      _price = 0.0;
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final provider = Provider.of<ProductProvider>(context, listen: false);

    try {
      if (widget.existing == null) {
        // Create new product via API-backed provider.create(...)
        final newProduct = Product(
          // If your Product model accepts nullable id, pass null. 
          // If it requires an int, pass 0 (backend should ignore/assign id).
          id: '', // For new product, id is empty or null as per your model
          name: _name,
          sku: _sku,
          description: _description,
          price: _price,
        );

        await provider.create(newProduct); // <-- uses backend POST /products
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added')),
        );
      } else {
        // Update via provider.update(...)
        final updated = Product(
          id: widget.existing!.id,
          name: _name,
          sku: _sku,
          description: _description,
          price: _price,
        );
        await provider.update(updated);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated')),
        );
      }

      // Return to previous screen and signal success
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('[ProductFormScreen] save error: $e');
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null ? 'Add Product' : 'Edit Product';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveForm,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
                    onSaved: (val) => _name = val ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _sku,
                    decoration: const InputDecoration(labelText: 'SKU'),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter SKU' : null,
                    onSaved: (val) => _sku = val ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onSaved: (val) => _description = val ?? '',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _price.toString(),
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter price';
                      if (double.tryParse(val) == null) return 'Invalid number';
                      return null;
                    },
                    onSaved: (val) => _price = double.tryParse(val ?? '0') ?? 0.0,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
