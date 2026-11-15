import '../models/application.dart';
import '../models/plot.dart';
import '../models/product.dart';
import 'api_service.dart';

class ApplicationService {
  final ApiService _api = ApiService();

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;

    if (response is Map && response['data'] is List) {
      return response['data'];
    }

    throw Exception('Formato de resposta inesperado da API.');
  }

  Future<List<AgriculturalApplication>> getApplications() async {
    final response = await _api.get('applications');

    return _extractList(
      response,
    ).map((item) => AgriculturalApplication.fromJson(item)).toList();
  }

  Future<List<Plot>> getPlots() async {
    final response = await _api.get('plots');

    return _extractList(response).map((item) => Plot.fromJson(item)).toList();
  }

  Future<List<Product>> getProducts() async {
    final response = await _api.get('products');

    return _extractList(
      response,
    ).map((item) => Product.fromJson(item)).toList();
  }

  Future<void> createApplication(Map<String, dynamic> data) async {
    await _api.post('applications', data);
  }

  Future<void> updateApplication(int id, Map<String, dynamic> data) async {
    await _api.put('applications/$id', data);
  }

  Future<void> deleteApplication(int id) async {
    await _api.delete('applications/$id');
  }
}
