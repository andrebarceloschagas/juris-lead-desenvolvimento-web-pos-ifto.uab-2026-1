import 'dart:convert';
import '../models/lead.dart';
import 'api_client.dart';

class LeadService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Lead>> getLeads() async {
    final response = await _apiClient.get('/leads');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lead.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar leads: ${response.body}');
    }
  }

  Future<Lead> triageLead(int leadId) async {
    final response = await _apiClient.post('/leads/$leadId/triage', {});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Aqui só recebemos os dados da triagem atualizados, mas podemos usar getLeads para recarregar ou mapear a resposta
      return Lead.fromJson(data);
    } else {
      throw Exception('Falha na triagem do lead: ${response.body}');
    }
  }
}
