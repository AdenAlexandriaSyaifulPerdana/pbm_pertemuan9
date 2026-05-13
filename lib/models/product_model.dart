class Product {
  final int id;
  final String name;
  final int price;
  final String description;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: _parsePrice(json['price']),
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static int _parsePrice(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) {
      final cleanedValue = value
          .replaceAll('Rp', '')
          .replaceAll('rp', '')
          .replaceAll(' ', '')
          .replaceAll(',', '');

      final parsedDouble = double.tryParse(cleanedValue);

      if (parsedDouble != null) {
        return parsedDouble.toInt();
      }

      final parsedInt = int.tryParse(cleanedValue);

      if (parsedInt != null) {
        return parsedInt;
      }
    }

    return 0;
  }
}
