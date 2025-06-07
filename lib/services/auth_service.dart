import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';
import '../utils/constants.dart'; // Importa o novo arquivo de constantes

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  
  UserModel? _currentUser;
  String? _token;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _token != null;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);

      if (token != null && userJson != null) {
        _token = token;
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        Logger.info('User restored from preferences: ${_currentUser?.username}'); // Usar username
      }
    } catch (e) {
      Logger.error('Error initializing auth service: $e');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${ApiConstants.login}'), // Usar AppConstants e ApiConstants
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        
        await _saveToPreferences();
        
        Logger.info('Login successful for user: ${_currentUser?.username}'); // Usar username
        return {
          'success': true,
          'user': _currentUser,
          'token': _token,
        };
      } else {
        Logger.error('Login failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      Logger.error('Login error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${ApiConstants.register}'), // Usar AppConstants e ApiConstants
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        
        await _saveToPreferences();
        
        Logger.info('Registration successful for user: ${_currentUser?.username}');
        return {
          'success': true,
          'user': _currentUser,
          'token': _token,
        };
      } else {
        Logger.error('Registration failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      Logger.error('Registration error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('${AppConstants.baseUrl}${ApiConstants.logout}'), // Usar AppConstants e ApiConstants
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      Logger.error('Logout error: $e');
    } finally {
      await _clearPreferences();
      _currentUser = null;
      _token = null;
      Logger.info('User logged out');
    }
  }

  Future<String?> getToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    }
    return _token;
  }

  Future<void> refreshToken() async {
    try {
      if (_token == null) return;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${ApiConstants.refreshToken}'), // Usar AppConstants e ApiConstants
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        await _saveToPreferences();
        Logger.info('Token refreshed successfully');
      }
    } catch (e) {
      Logger.error('Token refresh error: $e');
    }
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }
      if (_currentUser != null) {
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      }
    } catch (e) {
      Logger.error('Error saving to preferences: $e');
    }
  }

  Future<void> _clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      Logger.error('Error clearing preferences: $e');
    }
  }
}


