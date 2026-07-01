import 'dart:convert';
import 'api_client.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getMetrics() async {
    final response = await _apiClient.get('/metrics');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar métricas');
    }
  }
}
