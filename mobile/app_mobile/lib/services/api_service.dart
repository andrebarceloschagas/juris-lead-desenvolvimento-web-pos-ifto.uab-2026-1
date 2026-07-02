import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';
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
  
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    
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
      // Não logar corpo da resposta se for muito grande ou se quisermos evitar leaks
      // No login, o corpo contém o access_token, então vamos filtrar se possível ou omitir
      if (response.request?.url.path.contains('/auth/login') ?? false) {
        print('Body: [CONTEÚDO SENSÍVEL OMITIDO]');
      } else {
        print('Body: ${response.body}');
      }
      print('====================');
    }

    if (response.statusCode == 401) {
      await _storage.deleteToken();
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
        final safeHeaders = Map<String, String>.from(headers);
        if (safeHeaders.containsKey('Authorization')) {
          safeHeaders['Authorization'] = 'Bearer [REDACTED]';
        }
        print('=== API GET ===');
        print('URL: $url');
        print('Headers: $safeHeaders');
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
        final safeHeaders = Map<String, String>.from(headers);
        if (safeHeaders.containsKey('Authorization')) {
          safeHeaders['Authorization'] = 'Bearer [REDACTED]';
        }
        
        final safeBody = Map<String, dynamic>.from(body);
        if (safeBody.containsKey('password')) {
          safeBody['password'] = '********';
        }

        print('=== API POST ===');
        print('URL: $url');
        print('Headers: $safeHeaders');
        print('Body: $safeBody');
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
