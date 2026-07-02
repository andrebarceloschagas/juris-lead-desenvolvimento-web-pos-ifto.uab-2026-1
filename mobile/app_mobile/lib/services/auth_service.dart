import 'storage_service.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  Future<User?> login(String email, String password) async {
    try {
      final data = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (data != null && data['access_token'] != null) {
        final token = data['access_token'];
        final userData = data['user'];

        await _storage.saveToken(token);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> isAuthenticated() async {
    return await _storage.hasToken();
  }

  Future<User?> getPerfil() async {
    try {
      final data = await _apiService.get('/perfil');
      if (data != null) {
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> register(String name, String email, String password, String? bio) async {
    try {
      final data = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'bio': bio,
      });
      return data != null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> updatePerfil(String name, String? bio) async {
    try {
      final data = await _apiService.post('/perfil', {
        'name': name,
        'bio': bio,
      });
      if (data != null) {
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
