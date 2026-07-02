import 'package:flutter/material.dart';
import '../models/consulta.dart';
import '../services/consulta_service.dart';

class ConsultaViewModel extends ChangeNotifier {
  final ConsultaService _consultaService = ConsultaService();
  
  List<Consulta> _consultas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Consulta> get consultas => _consultas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchConsultas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _consultas = await _consultaService.getConsultas();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Consulta?> createConsulta(int leadId, DateTime scheduledAt) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final consulta = await _consultaService.createConsulta(leadId, scheduledAt);
      _consultas.add(consulta);
      return consulta;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelConsulta(int consultaId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedConsulta = await _consultaService.cancelConsulta(consultaId);
      final index = _consultas.indexWhere((c) => c.id == consultaId);
      if (index != -1) {
        _consultas[index] = updatedConsulta;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
