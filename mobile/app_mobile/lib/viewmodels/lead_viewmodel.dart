import 'package:flutter/material.dart';
import '../models/lead.dart';
import '../services/lead_service.dart';

class LeadViewModel extends ChangeNotifier {
  final LeadService _leadService = LeadService();

  List<Lead> _leads = [];
  List<Lead> get leads => _leads;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLeads() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _leads = await _leadService.getLeads();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> triageLead(int leadId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedLead = await _leadService.triageLead(leadId);
      final index = _leads.indexWhere((l) => l.id == leadId);
      if (index != -1) {
        _leads[index] = updatedLead;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLead(String name, String email, String phone, String documento) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final lead = await _leadService.createLead(name, email, phone, documento);
      _leads.insert(0, lead);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> convertLead(int leadId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _leadService.convertLead(leadId);
      final index = _leads.indexWhere((l) => l.id == leadId);
      if (index != -1) {
        await fetchLeads(); 
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
