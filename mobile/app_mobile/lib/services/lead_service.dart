import '../models/lead.dart';
import 'api_service.dart';

class LeadService {
  final ApiService _apiService = ApiService();

  Future<List<Lead>> getLeads() async {
    try {
      final data = await _apiService.get('/leads');
      if (data is List) {
        return data.map((json) => Lead.fromJson(json)).toList();
      }
      throw Exception('Formato de resposta inválido para lista de leads.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Lead> triageLead(int leadId) async {
    try {
      final data = await _apiService.post('/leads/$leadId/triage', {});
      if (data != null) {
        return Lead.fromJson(data);
      }
      throw Exception('Falha ao processar triagem.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Lead> createLead(String name, String email, String phone, String documento) async {
    try {
      final data = await _apiService.post(
        '/leads',
        {
          'name': name,
          'email': email,
          'phone': phone,
          'documento': documento,
        },
      );
      if (data != null) {
        return Lead.fromJson(data);
      }
      throw Exception('Falha ao criar lead.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> convertLead(int leadId) async {
    try {
      await _apiService.post(
        '/leads/$leadId/convert',
        {'create_user': true},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Lead> getLead(int leadId) async {
    try {
      final data = await _apiService.get('/leads/$leadId');
      if (data != null) {
        return Lead.fromJson(data);
      }
      throw Exception('Lead não encontrado.');
    } catch (e) {
      rethrow;
    }
  }
}
