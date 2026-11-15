import '../models/plot.dart';
import 'api_service.dart';

class PlotService {
  final ApiService _api = ApiService();

  Future<List<Plot>> getPlots() async {
    final response = await _api.get('plots');

    final List<dynamic> data = response is List ? response : response['data'];

    return data.map((item) => Plot.fromJson(item)).toList();
  }

  Future<void> createPlot(String name, double areaHa) async {
    await _api.post('plots', {'name': name, 'area_ha': areaHa});
  }

  Future<void> updatePlot(int id, String name, double areaHa) async {
    await _api.put('plots/$id', {'name': name, 'area_ha': areaHa});
  }

  Future<void> deletePlot(int id) async {
    await _api.delete('plots/$id');
  }
}
