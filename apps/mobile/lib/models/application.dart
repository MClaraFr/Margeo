import 'plot.dart';

class ApplicationProduct {
  final int productId;
  final String name;
  final String unit;
  final double quantityPerHa;
  final double unitPrice;

  const ApplicationProduct({
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantityPerHa,
    required this.unitPrice,
  });

  factory ApplicationProduct.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] ?? json;

    return ApplicationProduct(
      productId: json['id'] ?? pivot['product_id'],
      name: json['name'] ?? 'Produto',
      unit: json['unit'] ?? '',
      quantityPerHa: double.parse(pivot['quantity_per_ha'].toString()),
      unitPrice: double.parse(pivot['unit_price_at_application'].toString()),
    );
  }
}

class AgriculturalApplication {
  final int id;
  final DateTime applicationDate;
  final double areaHa;
  final Plot? plot;
  final List<ApplicationProduct> products;

  const AgriculturalApplication({
    required this.id,
    required this.applicationDate,
    required this.areaHa,
    required this.plot,
    required this.products,
  });

  factory AgriculturalApplication.fromJson(Map<String, dynamic> json) {
    return AgriculturalApplication(
      id: json['id'],
      applicationDate: DateTime.parse(json['application_date']),
      areaHa: double.parse(json['area_ha'].toString()),
      plot: json['plot'] != null ? Plot.fromJson(json['plot']) : null,
      products: (json['products'] as List<dynamic>? ?? [])
          .map((item) => ApplicationProduct.fromJson(item))
          .toList(),
    );
  }

  double get totalCost {
    return products.fold(
      0,
      (total, product) =>
          total + areaHa * product.quantityPerHa * product.unitPrice,
    );
  }
}
