// lib/models/product.dart

class Product {
  final String id; // always stored as String in the app
  final String name;
  final String sku;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
  });

  /// Create Product from a JSON map coming from your API.
  /// Handles id being int or string, and price being int/double/string.
  factory Product.fromJson(Map<String, dynamic> json) {
    // id might be int or string or nested under 'data'—callers should pass the correct map.
    final rawId = json['id'] ?? json['ID'] ?? json['product_id'];
    final id = rawId != null ? rawId.toString() : '';

    // handle price numeric or string
    double parsePrice(dynamic p) {
      if (p == null) return 0.0;
      if (p is num) return p.toDouble();
      if (p is String) return double.tryParse(p) ?? 0.0;
      return 0.0;
    }

    return Product(
      id: id,
      name: (json['name'] ?? json['title'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: parsePrice(json['price'] ?? json['cost'] ?? json['amount']),
    );
  }

  /// Convert Product to JSON for sending to API.
  /// Note: id is included; if your backend expects no id on create, omit it before sending.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'price': price,
    };
  }

  /// Handy copyWith for updates
  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? description,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }
}
