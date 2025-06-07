import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class SocketService extends ChangeNotifier {
  WebSocket? _socket;
  bool _isConnected = false;
  String? _error;
  
  bool get isConnected => _isConnected;
  String? get error => _error;
  
  // Conectar ao servidor WebSocket
  Future<void> connect(String url, {String? token}) async {
    try {
      _socket = await WebSocket.connect(url);
      _isConnected = true;
      _error = null;
      
      // Autenticar se token fornecido
      if (token != null) {
        _socket!.add(jsonEncode({
          'type': 'auth',
          'token': token,
        }));
      }
      
      // Escutar mensagens
      _socket!.listen(
        (data) => _handleMessage(data),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnection(),
      );
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao conectar: $e';
      _isConnected = false;
      notifyListeners();
    }
  }
  
  // Enviar mensagem
  void sendMessage(Map<String, dynamic> message) {
    if (_socket != null && _isConnected) {
      final jsonMessage = jsonEncode(message);
      _socket!.add(jsonMessage);
    }
  }
  
  // Gerenciar mensagens recebidas
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data);
      
      switch (message['type']) {
        case 'call_invite':
          _handleCallInvite(message);
          break;
        case 'call_answer':
          _handleCallAnswer(message);
          break;
        case 'call_end':
          _handleCallEnd(message);
          break;
        case 'user_status':
          _handleUserStatus(message);
          break;
        default:
          debugPrint('Mensagem não reconhecida: $message');
      }
    } catch (e) {
      debugPrint('Erro ao processar mensagem: $e');
    }
  }
  
  // Gerenciar convite para chamada
  void _handleCallInvite(Map<String, dynamic> message) {
    // Implementar lógica de convite para chamada
    debugPrint('Convite para chamada recebido: $message');
  }
  
  // Gerenciar resposta da chamada
  void _handleCallAnswer(Map<String, dynamic> message) {
    // Implementar lógica de resposta da chamada
    debugPrint('Resposta da chamada: $message');
  }
  
  // Gerenciar fim da chamada
  void _handleCallEnd(Map<String, dynamic> message) {
    // Implementar lógica de fim da chamada
    debugPrint('Chamada encerrada: $message');
  }
  
  // Gerenciar status do usuário
  void _handleUserStatus(Map<String, dynamic> message) {
    // Implementar lógica de status do usuário
    debugPrint('Status do usuário: $message');
  }
  
  // Gerenciar erros
  void _handleError(dynamic error) {
    _error = 'Erro no WebSocket: $error';
    _isConnected = false;
    notifyListeners();
  }
  
  // Gerenciar desconexão
  void _handleDisconnection() {
    _isConnected = false;
    notifyListeners();
  }
  
  // Desconectar
  void disconnect() {
    _socket?.close();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

