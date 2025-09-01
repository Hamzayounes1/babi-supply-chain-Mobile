class Supplier {
  final String name;
  final String contactEmail;
  final String phone;
  final String address;

  Supplier({
    required this.name,
    required this.contactEmail,
    required this.phone,
    required this.address,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      name: json['name']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact_email': contactEmail,
      'phone': phone,
      'address': address,
    };
  }
}
