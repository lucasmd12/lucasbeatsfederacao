import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../utils/logger.dart'; // Assuming logger is in utils

/// Provider para monitorar o estado da conexão com a internet.
class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = true;
  // CORREÇÃO: Tipo do StreamSubscription ajustado para List<ConnectivityResult> conforme log de erro.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Retorna `true` se o dispositivo estiver conectado à internet.
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    Logger.info('ConnectivityProvider Initialized.');
    _checkInitialConnection();
    _listenToConnectivityChanges();
  }

  /// Verifica a conexão inicial.
  Future<void> _checkInitialConnection() async {
    try {
      // checkConnectivity retorna List<ConnectivityResult> a partir da v4.0.0
      final result = await Connectivity().checkConnectivity();
      _updateStatus(result); // Passa a lista diretamente
      Logger.info('Initial connectivity check result: $result');
    } catch (e, stackTrace) {
      Logger.error('Error checking initial connectivity', error: e, stackTrace: stackTrace);
      // Assume offline if check fails
      _updateStatus([ConnectivityResult.none]); // Passa uma lista com none
    }
  }

  /// Ouve as mudanças no estado da conectividade.
  void _listenToConnectivityChanges() {
    // CORREÇÃO: Assinatura do callback ajustada para List<ConnectivityResult> conforme log de erro.
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      Logger.info('Connectivity changed: $result');
      _updateStatus(result); // Passa a lista diretamente
    }, onError: (e, stackTrace) {
      Logger.error('Error listening to connectivity changes', error: e, stackTrace: stackTrace);
      // Assume offline on error
      _updateStatus([ConnectivityResult.none]); // Passa uma lista com none
    });
  }

  /// Atualiza o status da conexão e notifica os listeners se houver mudança.
  void _updateStatus(List<ConnectivityResult> result) {
    // Considera online se a lista não contiver 'none' e não estiver vazia.
    // Ou se contiver outras conexões além de 'none'.
    bool newStatus = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    // Lógica alternativa: está online se houver qualquer conexão diferente de 'none'.
    // bool newStatus = result.any((status) => status != ConnectivityResult.none);

    if (_isOnline != newStatus) {
      _isOnline = newStatus;
      Logger.info('Connectivity status changed: ${_isOnline ? 'Online' : 'Offline'}');
      notifyListeners();
    }
  }

  /// Cancela a inscrição do listener ao descartar o provider.
  @override
  void dispose() {
    Logger.info('Disposing ConnectivityProvider.');
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

