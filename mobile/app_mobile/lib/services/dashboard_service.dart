import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getMetrics() async {
    try {
      final data = await _apiService.get('/dashboard/metricas');
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Formato de resposta de métricas inválido.');
    } catch (e) {
      rethrow;
    }
  }
}
