import '../models/processo.dart';
import 'api_service.dart';

class ProcessoService {
  final ApiService _apiService = ApiService();

  Future<List<Processo>> getProcessos() async {
    try {
      final data = await _apiService.get('/processos');
      if (data is List) {
        return data.map((e) => Processo.fromJson(e)).toList();
      }
      throw Exception('Formato de resposta inválido para lista de processos.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Processo> getProcesso(int id) async {
    try {
      final data = await _apiService.get('/processos/$id');
      if (data != null) {
        return Processo.fromJson(data);
      }
      throw Exception('Processo não encontrado.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Processo> createProcesso(int leadId, String title, String? description) async {
    try {
      final data = await _apiService.post(
        '/processos',
        {
          'lead_id': leadId,
          'title': title,
          'description': description ?? '',
        },
      );
      if (data != null) {
        return Processo.fromJson(data);
      }
      throw Exception('Falha ao criar processo.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Movimentacao> addMovimentacao(int processoId, String description) async {
    try {
      final data = await _apiService.post(
        '/processos/$processoId/movimentacoes',
        {'description': description},
      );
      if (data != null) {
        return Movimentacao.fromJson(data);
      }
      throw Exception('Falha ao adicionar movimentação.');
    } catch (e) {
      rethrow;
    }
  }
}
