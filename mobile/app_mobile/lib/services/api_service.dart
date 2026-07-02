import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static final StreamController<void> _unauthorizedController = StreamController<void>.broadcast();
  static Stream<void> get onUnauthorized => _unauthorizedController.stream;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _processResponse(http.Response response) async {
    if (kDebugMode) {
      print('=== API RESPONSE ===');
      print('URL: ${response.request?.url}');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('====================');
    }

    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      _unauthorizedController.add(null);
      throw UnauthorizedException('Sessão expirada. Por favor, faça login novamente.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String errorMessage = 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map && errorData.containsKey('error')) {
        errorMessage = errorData['error'];
      }
    } catch (_) {}

    throw Exception(errorMessage);
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      
      if (kDebugMode) {
        print('=== API GET ===');
        print('URL: $url');
        print('Headers: $headers');
        print('===============');
      }

      final response = await http.get(url, headers: headers).timeout(AppConfig.timeout);
      return await _processResponse(response);
    } on SocketException {
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão.');
    } on TimeoutException {
      throw Exception('A requisição excedeu o tempo limite. Tente novamente.');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');

      if (kDebugMode) {
        print('=== API POST ===');
        print('URL: $url');
        print('Headers: $headers');
        print('Body: $body');
        print('================');
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(AppConfig.timeout);
      
      return await _processResponse(response);
    } on SocketException {
      throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão.');
    } on TimeoutException {
      throw Exception('A requisição excedeu o tempo limite. Tente novamente.');
    } catch (e) {
      rethrow;
    }
  }
}
