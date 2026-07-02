import 'package:flutter/material.dart';
import '../models/processo.dart';
import '../services/processo_service.dart';

class ProcessoViewModel extends ChangeNotifier {
  final ProcessoService _processoService = ProcessoService();
  
  List<Processo> _processos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Processo> get processos => _processos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProcessos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _processos = await _processoService.getProcessos();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Processo?> getProcesso(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final processo = await _processoService.getProcesso(id);
      return processo;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Processo?> createProcesso(int leadId, String title, String? description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final processo = await _processoService.createProcesso(leadId, title, description);
      _processos.insert(0, processo);
      return processo;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMovimentacao(int processoId, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _processoService.addMovimentacao(processoId, description);
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
