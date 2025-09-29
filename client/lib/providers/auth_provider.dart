import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _isAuthenticated = true;
      _apiService.setAuthToken(_token!);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      _token = response.data['token'];
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _apiService.setAuthToken(_token!);
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _apiService.clearAuthToken();
    notifyListeners();
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _apiService.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}