import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  int _totalLeads = 0;
  int _pendingConsultas = 0;
  int _openProcessos = 0;

  int get totalLeads => _totalLeads;
  int get pendingConsultas => _pendingConsultas;
  int get openProcessos => _openProcessos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final metrics = await _dashboardService.getMetrics();
      _totalLeads = metrics['total_leads'] ?? 0;
      _pendingConsultas = metrics['consultas_agendadas'] ?? metrics['pending_consultas'] ?? 0;
      _openProcessos = metrics['open_processos'] ?? 0;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
