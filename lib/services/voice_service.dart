// lib/services/voice_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lucasbeatsfederacao/services/socket_service.dart';
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';

class VoiceService extends ChangeNotifier {
  final SocketService _socketService;
  final AuthService _authService;
  
  // WebRTC
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  
  // Estado
  String? _activeChannelId;
  bool _isMuted = false;
  bool _isDeafened = false;
  bool _isConnecting = false;
  String? _error;
  
  // Streams
  StreamSubscription? _socketSubscription;
  
  // Getters
  bool get isMuted => _isMuted;
  bool get isDeafened => _isDeafened;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _activeChannelId != null;
  String? get activeChannelId => _activeChannelId;
  String? get error => _error;
  Map<String, MediaStream> get remoteStreams => _remoteStreams;
  MediaStream? get localStream => _localStream;
  
  VoiceService(this._socketService, this._authService) {
    _setupSocketListeners();
  }
  
  void _setupSocketListeners() {
    _socketSubscription = _socketService.signalStream.listen(_handleSignal);
  }
  
  void _handleSignal(Map<String, dynamic> data) {
    final String? type = data['signalData']?['type'];
    final String? fromUserId = data['userId'];
    
    if (fromUserId == null) return;
    
    Logger.info('Received signal: $type from $fromUserId');
    
    switch (type) {
      case 'offer':
        _handleOffer(fromUserId, data['signalData']);
        break;
      case 'answer':
        _handleAnswer(fromUserId, data['signalData']);
        break;
      case 'candidate':
        _handleCandidate(fromUserId, data['signalData']);
        break;
      case 'leave':
        _handlePeerLeave(fromUserId);
        break;
    }
  }
  
  Future<void> joinChannel(String channelId) async {
    if (_activeChannelId != null) {
      await leaveChannel();
    }
    
    _isConnecting = true;
    _error = null;
    notifyListeners();
    
    try {
      // Inicializar stream local
      _localStream = await _createLocalStream();
      
      // Entrar no canal via socket
      _socketService.emit('join_voice_channel', {'channelId': channelId}, (response) async {
        if (response['status'] == 'ok') {
          _activeChannelId = channelId;
          
          // Conectar com peers existentes
          final peers = response['peers'] as List<dynamic>;
          for (var peer in peers) {
            final peerId = peer['_id'];
            await _createPeerConnection(peerId);
            await _createOffer(peerId);
          }
          
          _isConnecting = false;
          notifyListeners();
        } else {
          _error = response['message'] ?? 'Erro ao entrar no canal de voz';
          _isConnecting = false;
          _localStream?.dispose();
          _localStream = null;
          notifyListeners();
        }
      });
    } catch (e) {
      Logger.error('Erro ao entrar no canal de voz: $e');
      _error = 'Erro ao inicializar áudio: $e';
      _isConnecting = false;
      _localStream?.dispose();
      _localStream = null;
      notifyListeners();
    }
  }
  
  Future<void> leaveChannel() async {
    if (_activeChannelId == null) return;
    
    try {
      // Notificar servidor
      _socketService.emit('leave_voice_channel', {'channelId': _activeChannelId});
      
      // Limpar conexões
      for (var pc in _peerConnections.values) {
        await pc.close();
      }
      _peerConnections.clear();
      
      // Limpar streams
      for (var stream in _remoteStreams.values) {
        stream.dispose();
      }
      _remoteStreams.clear();
      
      // Limpar stream local
      _localStream?.dispose();
      _localStream = null;
      
      // Resetar estado
      _activeChannelId = null;
      _isMuted = false;
      _isDeafened = false;
      
      notifyListeners();
    } catch (e) {
      Logger.error('Erro ao sair do canal de voz: $e');
    }
  }
  
  Future<void> toggleMute() async {
    if (_localStream == null) return;
    
    _isMuted = !_isMuted;
    _localStream!.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
    
    notifyListeners();
  }
  
  Future<void> toggleDeafen() async {
    _isDeafened = !_isDeafened;
    
    // Mutar áudio local se estiver ensurdecido
    if (_isDeafened && !_isMuted) {
      await toggleMute();
    }
    
    // Mutar/desmutar áudio remoto
    for (var stream in _remoteStreams.values) {
      stream.getAudioTracks().forEach((track) {
        track.enabled = !_isDeafened;
      });
    }
    
    notifyListeners();
  }
  
  Future<MediaStream> _createLocalStream() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': false
    };
    
    try {
      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      return stream;
    } catch (e) {
      Logger.error('Erro ao obter stream local: $e');
      throw Exception('Não foi possível acessar o microfone: $e');
    }
  }
  
  Future<void> _createPeerConnection(String peerId) async {
    if (_peerConnections.containsKey(peerId)) return;
    
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };
    
    final pc = await createPeerConnection(configuration);
    
    // Adicionar tracks locais
    _localStream?.getTracks().forEach((track) {
      pc.addTrack(track, _localStream!);
    });
    
    // Lidar com ICE candidates
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      if (_activeChannelId == null) {
        Logger.warning('Cannot send ICE candidate: No active channel.');
        return;
      }
      _socketService.sendSignal(
        _activeChannelId!,
        {
          'type': 'candidate',
          'targetId': peerId,
          'candidate': {
            'sdpMLineIndex': candidate.sdpMLineIndex,
            'sdpMid': candidate.sdpMid,
            'candidate': candidate.candidate,
          }
        },
      );
    };
    
    // Lidar com streams remotos
    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStreams[peerId] = event.streams[0];
        notifyListeners();
      }
    };
    
    _peerConnections[peerId] = pc;
  }
  
  Future<void> _createOffer(String peerId) async {
    final pc = _peerConnections[peerId];
    if (pc == null) return;
    
    try {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      
      if (_activeChannelId == null) {
        Logger.warning('Cannot send offer: No active channel.');
        return;
      }
      _socketService.sendSignal(
        _activeChannelId!,
        {
          'type': 'offer',
          'targetId': peerId,
          'sdp': {
            'type': offer.type,
            'sdp': offer.sdp,
          }
        },
      );
    } catch (e) {
      Logger.error('Erro ao criar oferta: $e');
    }
  }
  
  Future<void> _handleOffer(String peerId, Map<String, dynamic> data) async {
    if (_activeChannelId == null) return;
    
    try {
      await _createPeerConnection(peerId);
      final pc = _peerConnections[peerId];
      if (pc == null) return;
      
      await pc.setRemoteDescription(
        RTCSessionDescription(
          data['sdp']['sdp'],
          data['sdp']['type'],
        ),
      );
      
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      
      if (_activeChannelId == null) {
        Logger.warning('Cannot send answer: No active channel.');
        return;
      }
      _socketService.sendSignal(
        _activeChannelId!,
        {
          'type': 'answer',
          'targetId': peerId,
          'sdp': {
            'type': answer.type,
            'sdp': answer.sdp,
          }
        },
      );
    } catch (e) {
      Logger.error('Erro ao processar oferta: $e');
    }
  }
  
  Future<void> _handleAnswer(String peerId, Map<String, dynamic> data) async {
    final pc = _peerConnections[peerId];
    if (pc == null) return;
    
    try {
      await pc.setRemoteDescription(
        RTCSessionDescription(
          data['sdp']['sdp'],
          data['sdp']['type'],
        ),
      );
    } catch (e) {
      Logger.error('Erro ao processar resposta: $e');
    }
  }
  
  Future<void> _handleCandidate(String peerId, Map<String, dynamic> data) async {
    final pc = _peerConnections[peerId];
    if (pc == null) return;
    
    try {
      await pc.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ),
      );
    } catch (e) {
      Logger.error('Erro ao adicionar candidato ICE: $e');
    }
  }
  
  void _handlePeerLeave(String peerId) {
    // Fechar conexão
    _peerConnections[peerId]?.close();
    _peerConnections.remove(peerId);
    
    // Limpar stream
    _remoteStreams[peerId]?.dispose();
    _remoteStreams.remove(peerId);
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    leaveChannel();
    _socketSubscription?.cancel();
    super.dispose();
  }
}


