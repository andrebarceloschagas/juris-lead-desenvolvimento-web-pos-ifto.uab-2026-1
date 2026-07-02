import '../models/consulta.dart';
import 'api_service.dart';

class ConsultaService {
  final ApiService _apiService = ApiService();

  Future<List<Consulta>> getConsultas() async {
    try {
      final data = await _apiService.get('/consultas');
      if (data is List) {
        return data.map((e) => Consulta.fromJson(e)).toList();
      }
      throw Exception('Formato de resposta inválido para lista de consultas.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Consulta> createConsulta(int leadId, DateTime scheduledAt) async {
    try {
      final data = await _apiService.post(
        '/consultas',
        {
          'lead_id': leadId,
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        },
      );
      if (data != null) {
        return Consulta.fromJson(data);
      }
      throw Exception('Falha ao agendar consulta.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Consulta> cancelConsulta(int consultaId) async {
    try {
      final data = await _apiService.post('/consultas/$consultaId/cancel', {});
      if (data != null) {
        return Consulta.fromJson(data);
      }
      throw Exception('Falha ao cancelar consulta.');
    } catch (e) {
      rethrow;
    }
  }
}
