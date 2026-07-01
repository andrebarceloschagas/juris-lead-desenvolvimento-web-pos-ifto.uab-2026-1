import 'dart:convert';
import '../models/processo.dart';
import 'api_client.dart';

class ProcessoService {
  final ApiClient _apiClient = ApiClient();

  // NOTA: O endpoint /processos geral não está em api_routes.py, apenas para criacao. 
  // Podemos precisar dele, mas por enquanto fazemos requisições especificas ou mocamos
  // Para fins do dashboard vamos ler as metricas
}
