import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  static const routeName = '/product-form';
  final Product? existing;
  const ProductFormScreen({super.key, this.existing});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _sku, _description;
  late double _price;
  bool _saving = false;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);

    try {
      if (widget.existing == null) {
        final newProduct = Product(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _name, sku: _sku, description: _description, price: _price);
        await provider.create(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product created')));
      } else {
        final updated = Product(id: widget.existing!.id, name: _name, sku: _sku, description: _description, price: _price);
        await provider.update(updated);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated')));
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null ? 'Add Product' : 'Edit Product';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save), onPressed: _saving ? null : _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(initialValue: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null, onSaved: (v) => _name = v ?? ''),
              const SizedBox(height: 8),
              TextFormField(initialValue: _sku, decoration: const InputDecoration(labelText: 'SKU'), validator: (v) => v == null || v.isEmpty ? 'Required' : null, onSaved: (v) => _sku = v ?? ''),
              const SizedBox(height: 8),
              TextFormField(initialValue: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, onSaved: (v) => _description = v ?? ''),
              const SizedBox(height: 8),
              TextFormField(initialValue: _price.toString(), decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : (double.tryParse(v) == null ? 'Invalid' : null), onSaved: (v) => _price = double.tryParse(v ?? '0') ?? 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
