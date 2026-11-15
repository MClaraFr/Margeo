import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _api = ApiService();

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;

    if (response is Map && response['data'] is List) {
      return response['data'];
    }

    throw Exception('Formato de resposta inesperado da API.');
  }

  Future<List<Product>> getProducts() async {
    final response = await _api.get('products');

    return _extractList(
      response,
    ).map((item) => Product.fromJson(item)).toList();
  }

  Future<void> createProduct(
    String name,
    String unit,
    double pricePerUnit,
  ) async {
    await _api.post('products', {
      'name': name,
      'unit': unit,
      'price_per_unit': pricePerUnit,
    });
  }

  Future<void> updateProduct(
    int id,
    String name,
    String unit,
    double pricePerUnit,
  ) async {
    await _api.put('products/$id', {
      'name': name,
      'unit': unit,
      'price_per_unit': pricePerUnit,
    });
  }

  Future<void> deleteProduct(int id) async {
    await _api.delete('products/$id');
  }
}
