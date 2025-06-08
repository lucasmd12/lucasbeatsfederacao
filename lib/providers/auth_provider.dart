import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/services/socket_service.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart'; // Corrected import
import 'package:lucasbeatsfederacao/utils/logger.dart'; // Corrected import

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final SocketService _socketService;

  AuthStatus _authStatus = AuthStatus.unknown;
  AuthStatus get authStatus => _authStatus;

  // Adicionando o getter isInitializing
  bool get isInitializing => _authStatus == AuthStatus.unknown;

  // Adicionando o getter isAuthenticated
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;

  // CORREÇÃO: Usar UserModel
  UserModel? get currentUser => _authService.currentUser;

  AuthProvider(this._authService, this._socketService) {
    // CORREÇÃO: Usar Logger
    Logger.info('AuthProvider initialized. Listening to AuthService changes.');
    _authService.addListener(_authListener);
    _updateAuthStatus();
  }

  void _authListener() {
    // CORREÇÃO: Usar Logger
    Logger.info('AuthProvider received notification from AuthService.');
    _updateAuthStatus();
  }

  void _updateAuthStatus() {
    if (_authService.isAuthenticated) {
      if (_authStatus != AuthStatus.authenticated) {
        // CORREÇÃO: Usar Logger
        Logger.info('AuthProvider: Status changed to Authenticated.');
        _authStatus = AuthStatus.authenticated;
        Logger.info('AuthProvider: Connecting SocketService...');
        _socketService.connect();
        notifyListeners();
      }
    } else {
      if (_authStatus != AuthStatus.unauthenticated) {
        // CORREÇÃO: Usar Logger
        Logger.info('AuthProvider: Status changed to Unauthenticated.');
        _authStatus = AuthStatus.unauthenticated;
        Logger.info('AuthProvider: Disconnecting SocketService...');
        _socketService.disconnect();
        notifyListeners();
      }
    }
    if (_authStatus == AuthStatus.unknown && !_authService.isAuthenticated) {
       // CORREÇÃO: Usar Logger
       Logger.info('AuthProvider: Initial status resolved to Unauthenticated.');
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final success = await _authService.login(email, password);
      return success;
    } catch (e) {
      // CORREÇÃO: Usar Logger
      Logger.error('AuthProvider login failed: ${e.toString()}');
      rethrow;
    }
  }

  // CORREÇÃO: Assumindo que o registro não precisa mais de email, conforme contexto anterior
  Future<bool> register(String username, String password) async {
    try {
      // CORREÇÃO: Chamar register apenas com username e password
      final success = await _authService.register(username, password);
      return success;
    } catch (e) {
      // CORREÇÃO: Usar Logger
      Logger.error('AuthProvider register failed: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> logout() async {
    // CORREÇÃO: Usar Logger
    Logger.info('AuthProvider: Initiating logout.');
    await _authService.logout();
  }

  @override
  void dispose() {
    // CORREÇÃO: Usar Logger
    Logger.info('Disposing AuthProvider.');
    _authService.removeListener(_authListener);
    super.dispose();
  }
}


