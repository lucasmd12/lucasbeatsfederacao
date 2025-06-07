import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class VoipService extends ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _isCalling = false;
  bool _isConnected = false;
  String? _error;

  bool get isCalling => _isCalling;
  bool get isConnected => _isConnected;
  String? get error => _error;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  // Configurações ICE
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  // Inicializar VOIP
  Future<bool> initialize() async {
    try {
      // Verificar permissões
      final microphoneStatus = await Permission.microphone.request();
      if (!microphoneStatus.isGranted) {
        _error = 'Permissão de microfone negada';
        notifyListeners();
        return false;
      }

      // Criar peer connection
      _peerConnection = await createPeerConnection(_iceServers);
      
      // Configurar eventos
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        // Enviar candidate via WebSocket
        _sendIceCandidate(candidate);
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteStream = stream;
        notifyListeners();
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        _isConnected = state == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
        notifyListeners();
      };

      return true;
    } catch (e) {
      _error = 'Erro ao inicializar VOIP: $e';
      notifyListeners();
      return false;
    }
  }

  // Iniciar chamada
  Future<void> startCall(String targetUserId) async {
    try {
      _isCalling = true;
      _error = null;
      notifyListeners();

      // Obter stream local (apenas áudio)
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false, // Apenas VOIP, sem vídeo
      });

      // Adicionar stream ao peer connection
      _peerConnection!.addStream(_localStream!);

      // Criar offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Enviar offer via WebSocket
      _sendOffer(offer, targetUserId);

    } catch (e) {
      _error = 'Erro ao iniciar chamada: $e';
      _isCalling = false;
      notifyListeners();
    }
  }

  // Responder chamada
  Future<void> answerCall(RTCSessionDescription offer) async {
    try {
      _isCalling = true;
      notifyListeners();

      // Obter stream local
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      _peerConnection!.addStream(_localStream!);

      // Definir remote description
      await _peerConnection!.setRemoteDescription(offer);

      // Criar answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Enviar answer via WebSocket
      _sendAnswer(answer);

    } catch (e) {
      _error = 'Erro ao responder chamada: $e';
      notifyListeners();
    }
  }

  // Encerrar chamada
  Future<void> endCall() async {
    try {
      // Parar streams
      _localStream?.getTracks().forEach((track) => track.stop());
      _remoteStream?.getTracks().forEach((track) => track.stop());

      // Fechar peer connection
      await _peerConnection?.close();

      // Reset estado
      _localStream = null;
      _remoteStream = null;
      _isCalling = false;
      _isConnected = false;

      notifyListeners();
    } catch (e) {
      _error = 'Erro ao encerrar chamada: $e';
      notifyListeners();
    }
  }

  // Alternar mute
  void toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final isEnabled = audioTracks.first.enabled;
        audioTracks.first.enabled = !isEnabled;
        notifyListeners();
      }
    }
  }

  // Verificar se está mutado
  bool get isMuted {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        return !audioTracks.first.enabled;
      }
    }
    return false;
  }

  // Métodos para envio via WebSocket (implementar conforme seu SocketService)
  void _sendOffer(RTCSessionDescription offer, String targetUserId) {
    // Implementar envio via WebSocket
    debugPrint('Enviando offer para $targetUserId');
  }

  void _sendAnswer(RTCSessionDescription answer) {
    // Implementar envio via WebSocket
    debugPrint('Enviando answer');
  }

  void _sendIceCandidate(RTCIceCandidate candidate) {
    // Implementar envio via WebSocket
    debugPrint('Enviando ICE candidate');
  }

  // Processar answer recebido
  Future<void> processAnswer(RTCSessionDescription answer) async {
    try {
      await _peerConnection!.setRemoteDescription(answer);
    } catch (e) {
      _error = 'Erro ao processar answer: $e';
      notifyListeners();
    }
  }

  // Processar ICE candidate recebido
  Future<void> processIceCandidate(RTCIceCandidate candidate) async {
    try {
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      _error = 'Erro ao processar ICE candidate: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    endCall();
    super.dispose();
  }
}

