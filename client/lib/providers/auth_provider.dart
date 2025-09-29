import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../router_singleton.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _token;
  String? _refreshToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  int? get userId => _decodeUid(_token);
  ApiService get apiService => _apiService;

  AuthProvider() {
    _apiService.onTokenUpdate = (access, refresh) async {
      _token = access;
      _refreshToken = refresh;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', access);
      if (refresh != null) {
        await prefs.setString('refresh_token', refresh);
      }
      notifyListeners();
    };
    _apiService.onAuthFailure = () async {
      await logout();
      // Ensure redirect to login
      globalRouter?.go('/login');
    };
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
    if (_token != null) {
      _isAuthenticated = true;
      _apiService.setAuthToken(_token!);
      if (_refreshToken != null) {
        _apiService.setRefreshToken(_refreshToken!);
      }
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.post('/api/auth/login', options: Options(extra: {'skipAuth': true}), data: {
        'email': email,
        'password': password,
      });

      _token = response.data['token'];
      _refreshToken = response.data['refresh_token'];
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      if (_refreshToken != null) {
        await prefs.setString('refresh_token', _refreshToken!);
      }

      _apiService.setAuthToken(_token!);
      if (_refreshToken != null) {
        _apiService.setRefreshToken(_refreshToken!);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');

    _apiService.clearAuthToken();
    _apiService.clearRefreshToken();
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

int? _decodeUid(String? token) {
  if (token == null) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = json.decode(utf8.decode(base64Url.decode(base64.normalize(parts[1]))));
    final uid = (payload as Map)['uid'];
    if (uid is int) return uid;
    if (uid is num) return uid.toInt();
    if (uid is String) return int.tryParse(uid);
    return null;
  } catch (_) {
    return null;
  }
}
