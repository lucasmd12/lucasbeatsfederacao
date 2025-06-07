import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../models/chat_channel_model.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

class CallProvider with ChangeNotifier {
  final AuthService _authService;
  final SocketService _socketService;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isInCall = false;
  ChatChannelModel? _currentChannel;
  List<UserModel> _participants = [];
  
  CallProvider({
    required AuthService authService,
    required SocketService socketService,
  }) : _authService = authService,
       _socketService = socketService {
    _initializeCallHandlers();
  }

  // Getters
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isInCall => _isInCall;
  ChatChannelModel? get currentChannel => _currentChannel;
  List<UserModel> get participants => List.unmodifiable(_participants);
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  void _initializeCallHandlers() {
    _socketService.onCallReceived = _handleIncomingCall;
    _socketService.onCallEnded = _handleCallEnded;
    _socketService.onUserJoinedChannel = _handleUserJoinedChannel;
    _socketService.onUserLeftChannel = _handleUserLeftChannel;
  }

  Future<void> joinVoiceChannel(ChatChannelModel channel) async {
    try {
      Logger.info('Entrando no canal de voz: ${channel.id}');
      
      await _initializeLocalStream();
      await _createPeerConnection();
      
      _currentChannel = channel;
      _isInCall = true;
      
      // Enviar sinal para o servidor que entrou no canal
      _socketService.joinVoiceChannel(channel.id);
      
      notifyListeners();
      Logger.info('Conectado ao canal de voz com sucesso');
    } catch (e) {
      Logger.error('Erro ao entrar no canal de voz: $e');
      rethrow;
    }
  }

  Future<void> leaveVoiceChannel() async {
    try {
      if (_currentChannel != null) {
        _socketService.leaveVoiceChannel(_currentChannel!.id);
      }
      
      await _disposeCall();
      
      _currentChannel = null;
      _isInCall = false;
      _participants.clear();
      
      notifyListeners();
      Logger.info('Saiu do canal de voz');
    } catch (e) {
      Logger.error('Erro ao sair do canal de voz: $e');
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
    notifyListeners();
  }

  void toggleCamera() {
    _isCameraOff = !_isCameraOff;
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !_isCameraOff;
    });
    notifyListeners();
  }

  Future<void> _initializeLocalStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': false, // Para VoIP, geralmente só áudio
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  Future<void> _createPeerConnection() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);
    
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    }

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        notifyListeners();
      }
    };

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _socketService.sendIceCandidate(candidate.toMap());
    };
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    Logger.info('Chamada recebida: $data');
    // Implementar lógica para chamadas recebidas
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    Logger.info('Chamada encerrada: $data');
    leaveVoiceChannel();
  }

  void _handleUserJoinedChannel(Map<String, dynamic> data) {
    try {
      final user = UserModel.fromJson(data['user']);
      if (!_participants.any((p) => p.id == user.id)) {
        _participants.add(user);
        notifyListeners();
      }
      Logger.info('Usuário ${user.name} entrou no canal');
    } catch (e) {
      Logger.error('Erro ao processar usuário que entrou: $e');
    }
  }

  void _handleUserLeftChannel(Map<String, dynamic> data) {
    try {
      final userId = data['userId'];
      _participants.removeWhere((p) => p.id == userId);
      notifyListeners();
      Logger.info('Usuário $userId saiu do canal');
    } catch (e) {
      Logger.error('Erro ao processar usuário que saiu: $e');
    }
  }

  Future<void> _disposeCall() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
  }

  @override
  void dispose() {
    _disposeCall();
    super.dispose();
  }
}
