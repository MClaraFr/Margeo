class Product {
  final int id;
  final String name;
  final String unit;
  final double pricePerUnit;

  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.pricePerUnit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      pricePerUnit: double.parse(json['price_per_unit'].toString()),
    );
  }
}
