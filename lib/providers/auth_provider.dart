import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart';
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService; // Injetar AuthService
  final Logger _logger = Logger();

  UserModel? _currentUser;
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider(this._authService) { // Construtor que recebe AuthService
    _authService.initialize(); // Inicializa o AuthService
    _currentUser = _authService.currentUser; // Define o usuário inicial
  }

  Future<bool> signIn(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.login(username, password);
      if (result['success']) {
        _currentUser = result['user'];
        _logger.info('Login successful for user: ${_currentUser?.username}');
        return true;
      } else {
        _logger.error('Login failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      _logger.error('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.register(username, password);
      if (result['success']) {
        _currentUser = result['user'];
        _logger.info('Registration successful for user: ${_currentUser?.username}');
        return true;
      } else {
        _logger.error('Registration failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      _logger.error('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _logger.info('User logged out');
    } catch (e) {
      _logger.error('Sign out error: $e');
    } finally {
      notifyListeners();
    }
  }
}


