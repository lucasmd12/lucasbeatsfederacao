import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lucasbeatsfederacao/services/socket_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart'; // Corrected: Added semicolon

// Corrected: Class declaration moved to a new line
class SignalingService with ChangeNotifier {
  final SocketService _socketService;
  StreamSubscription? _signalSubscription;
  String? userId;

  // Stream controller to broadcast received signals to the UI/Call logic
  final _receivedSignalController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get receivedSignalStream => _receivedSignalController.stream;

  // Stream controllers para eventos específicos
  final _offerController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onOfferReceived => _offerController.stream;

  final _answerController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onAnswerReceived => _answerController.stream;

  final _candidateController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onCandidateReceived => _candidateController.stream;

  final _peerJoinedController = StreamController<String>.broadcast();
  Stream<String> get onPeerJoined => _peerJoinedController.stream;

  final _peerLeftController = StreamController<String>.broadcast();
  Stream<String> get onPeerLeft => _peerLeftController.stream;

  String? _currentChannelId;

  // Construtor com injeção de dependência
  SignalingService(this._socketService) {
    // Listen to incoming signals from SocketService
    _signalSubscription = _socketService.signalStream.listen(_handleIncomingSignal);
  }

  // Construtor alternativo para inicialização com ID do usuário
  SignalingService.withUserId(this._socketService, this.userId) {
    _signalSubscription = _socketService.signalStream.listen(_handleIncomingSignal);
  }

  void _handleIncomingSignal(Map<String, dynamic> signalData) {
    // Check if the signal is for the current active call/channel if necessary
    // For now, just forward it
    Logger.info('Received signal via SignalingService: $signalData');
    _receivedSignalController.add(signalData);
    
    // Processar o sinal com base no tipo
    final type = signalData['type'] as String?;
    if (type == 'offer') {
      _offerController.add(signalData);
    } else if (type == 'answer') {
      _answerController.add(signalData);
    } else if (type == 'candidate') {
      _candidateController.add(signalData);
    } else if (type == 'peer_joined') {
      final peerId = signalData['peerId'] as String?;
      if (peerId != null) {
        _peerJoinedController.add(peerId);
      }
    } else if (type == 'peer_left') {
      final peerId = signalData['peerId'] as String?;
      if (peerId != null) {
        _peerLeftController.add(peerId);
      }
    }
  }

  // Call this when entering a channel where signaling might occur
  void setActiveChannel(String channelId) {
    _currentChannelId = channelId;
    Logger.info('SignalingService active for channel: $channelId');
    // No specific action needed here for socket connection, as ChatService handles joining the room.
    // Ensure SocketService is connected via AuthService/AuthProvider.
  }

  // Call this when leaving a channel
  void clearActiveChannel() {
    Logger.info('SignalingService cleared active channel: $_currentChannelId');
    _currentChannelId = null;
  }

  // Método para conectar ao canal
  void connect(String channelId) {
    setActiveChannel(channelId);
    // Implementação adicional se necessário
  }

  // Método para desconectar
  void disconnect() {
    clearActiveChannel();
    // Implementação adicional se necessário
  }

  // Send WebRTC signal (offer, answer, candidate)
  void sendSignal(dynamic signalData) {
    if (_currentChannelId == null) {
      Logger.warning('Cannot send signal: No active channel set in SignalingService.');
      return;
    }
    if (!_socketService.isConnected) {
       Logger.warning('Cannot send signal: SocketService is not connected.');
       return;
    }
    Logger.info('Sending signal for channel $_currentChannelId');
    _socketService.sendSignal({"channelId": _currentChannelId!, "signalData": signalData});
  }

  // Métodos específicos para enviar diferentes tipos de sinais
  void sendOffer(String peerId, dynamic offer) {
    sendSignal({
      'type': 'offer',
      'targetId': peerId,
      'sdp': offer.toMap(), // Assuming offer has toMap()
    });
  }

  void sendAnswer(String peerId, dynamic answer) {
    sendSignal({
      'type': 'answer',
      'targetId': peerId,
      'sdp': answer.toMap(), // Assuming answer has toMap()
    });
  }

  void sendCandidate(String peerId, dynamic candidate) {
    sendSignal({
      'type': 'candidate',
      'targetId': peerId,
      'candidate': candidate.toMap(), // Assuming candidate has toMap()
    });
  }

  @override
  void dispose() {
    Logger.info('Disposing SignalingService...');
    _signalSubscription?.cancel();
    _receivedSignalController.close();
    _offerController.close();
    _answerController.close();
    _candidateController.close();
    _peerJoinedController.close();
    _peerLeftController.close();
    super.dispose();
  }
}

