class Inventory {
  final int warehouseId;
  final int productId;
  final int quantity;

  Inventory({
    required this.warehouseId,
    required this.productId,
    required this.quantity,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      warehouseId: json['warehouse_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouse_id': warehouseId,
      'product_id': productId,
      'quantity': quantity,
    };
  }
}
