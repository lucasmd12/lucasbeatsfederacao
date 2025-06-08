import 'dart:async';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/services/socket_service.dart';
import 'package:lucasbeatsfederacao/services/signaling_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart'; // Corrected import

enum CallState { idle, joining, leaving, connected, error }

class CallProvider extends ChangeNotifier {
  // --- Dependências ---
  final AuthService _authService;
  // CORREÇÃO: Remover campo não utilizado
  // final SocketService _socketService;
  final SignalingService _signalingService;

  // --- Estado da Conexão WebRTC ---
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  String? _currentChannelId;
  CallState _callState = CallState.idle;
  String? _errorMessage;
  bool _isMicMuted = false;
  bool _isSpeakerOn = true;

  // --- Getters ---
  CallState get callState => _callState;
  MediaStream? get localStream => _localStream;
  Map<String, MediaStream> get remoteStreams => _remoteStreams;
  String? get errorMessage => _errorMessage;
  bool get isMicMuted => _isMicMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  String? get currentChannelId => _currentChannelId;

  // --- Configuração WebRTC ---
  final Map<String, dynamic> _rtcConfiguration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };
  final Map<String, dynamic> _rtcConstraints = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _candidateSubscription;
  StreamSubscription? _peerJoinedSubscription;
  StreamSubscription? _peerLeftSubscription;

  // --- Constructor ---
  CallProvider({
    required AuthService authService,
    required SocketService socketService, // Keep here for injection if needed later
    required SignalingService signalingService,
  }) : 
    _authService = authService,
    // _socketService = socketService, // Assign if used
    _signalingService = signalingService {
    _initializeOnAuth();
  }

  void _initializeOnAuth() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _initialize(currentUser);
    } else {
      Logger.warning("CallProvider initialized but user is not logged in yet.");
    }
  }

  // CORREÇÃO: Usar UserModel
  void _initialize(UserModel currentUser) {
    Logger.info("Initializing CallProvider for user: ${currentUser.id}");
  }

  @override
  void dispose() {
    Logger.info('Disposing CallProvider...');
    _cleanUpCurrentCall();
    super.dispose();
  }

  Future<void> _cleanUpCurrentCall() async {
    Logger.info('Cleaning up current call resources...');
    _updateCallState(CallState.leaving);

    await _closeMediaStream();

    await Future.forEach(_peerConnections.entries, (entry) async {
      await _closePeerConnection(entry.key, notify: false);
    });
    _peerConnections.clear();
    _remoteStreams.clear();
    _cancelSignalingSubscriptions();
    _signalingService.disconnect();
    _currentChannelId = null;
    _updateCallState(CallState.idle);
    Logger.info('Call cleanup complete.');
    notifyListeners();
  }

  void _cancelSignalingSubscriptions() {
     _offerSubscription?.cancel();
     _answerSubscription?.cancel();
     _candidateSubscription?.cancel();
     _peerJoinedSubscription?.cancel();
     _peerLeftSubscription?.cancel();
     _offerSubscription = null;
     _answerSubscription = null;
     _candidateSubscription = null;
     _peerJoinedSubscription = null;
     _peerLeftSubscription = null;
     Logger.info('Signaling subscriptions cancelled.');
  }

  Future<void> joinChannel(String channelId) async {
    if (_callState != CallState.idle) {
      Logger.warning('Cannot join channel: State is not idle.');
      return;
    }
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
       Logger.error('Cannot join channel: User not logged in.');
       _updateCallState(CallState.error, 'Usuário não autenticado.');
       return;
    }
    
    Logger.info('Joining channel: $channelId');
    _updateCallState(CallState.joining);
    _currentChannelId = channelId;

    try {
      await _getLocalMedia();
      _signalingService.connect(channelId);
      _listenToSignalingEvents();
      _updateCallState(CallState.connected);
      Logger.info('Successfully joined channel: $channelId');
    } catch (e, stackTrace) {
      Logger.error('Error joining channel $channelId', error: e, stackTrace: stackTrace);
      _updateCallState(CallState.error, 'Erro ao entrar no canal.');
      await _cleanUpCurrentCall();
    }
  }

  Future<void> leaveChannel() async {
    if (_callState == CallState.idle || _callState == CallState.leaving) {
      Logger.info('Already idle or leaving channel.');
      return;
    }
    Logger.info('Leaving channel: $_currentChannelId');
    await _cleanUpCurrentCall();
  }

  // --- Placeholder Methods (Keep for now, remove unused later) ---
  // These might be called internally or by signaling service

  Future<void> _handleIncomingSignal(Map<String, dynamic> signalData) async {
    Logger.info("[Placeholder] Handling incoming signal: $signalData");
  }

  Future<void> atualizarStatusPresenca(String userId, bool isOnline) async {
    Logger.info("[Placeholder] Updating presence for user $userId to ${isOnline ? 'online' : 'offline'}");
  }

  Future<void> _initializeWebRTC() async {
    Logger.info("[Placeholder] Initializing WebRTC components.");
  }

  Future<void> _hangUp() async {
    Logger.info("[Placeholder] Hanging up the call.");
    await leaveChannel();
  }

  Future<RTCPeerConnection> _createPeerConnection(String peerId) async {
    Logger.info("[Placeholder] Creating Peer Connection for $peerId.");
    RTCPeerConnection pc = await createPeerConnection(_rtcConfiguration, _rtcConstraints);
    _registerPeerConnectionListeners(pc, peerId);
    return pc;
  }

  void _registerPeerConnectionListeners(RTCPeerConnection pc, String peerId) {
    Logger.info("[Placeholder] Registering listeners for Peer Connection $peerId.");
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      // CORREÇÃO: Usar Logger.info ou warning, debug não existe
      Logger.info('[Placeholder] onIceCandidate for $peerId');
      _signalingService.sendCandidate(peerId, candidate);
    };
    pc.onTrack = (RTCTrackEvent event) {
      Logger.info('[Placeholder] onTrack received from $peerId');
      if (event.streams.isNotEmpty) {
        _remoteStreams[peerId] = event.streams[0];
        notifyListeners();
      }
    };
  }

  Future<void> _setRemoteDescription(String peerId, RTCSessionDescription description) async {
    Logger.info("[Placeholder] Setting remote description for $peerId.");
    final pc = _peerConnections[peerId];
    if (pc != null) {
      await pc.setRemoteDescription(description);
    }
  }

  Future<void> _addCandidate(String peerId, RTCIceCandidate candidate) async {
    Logger.info("[Placeholder] Adding ICE candidate for $peerId.");
    final pc = _peerConnections[peerId];
    if (pc != null) {
      await pc.addCandidate(candidate);
    }
  }

  Future<void> _createOffer(String peerId) async {
    Logger.info("[Placeholder] Creating offer for $peerId.");
    final pc = await _getOrCreatePeerConnection(peerId);
    final offer = await pc.createOffer({'offerToReceiveAudio': 1});
    await pc.setLocalDescription(offer);
    _signalingService.sendOffer(peerId, offer);
  }

  Future<void> _createAnswer(String peerId, RTCSessionDescription offer) async {
    Logger.info("[Placeholder] Creating answer for $peerId.");
    final pc = await _getOrCreatePeerConnection(peerId);
    await pc.setRemoteDescription(offer);
    final answer = await pc.createAnswer({'offerToReceiveAudio': 1});
    await pc.setLocalDescription(answer);
    _signalingService.sendAnswer(peerId, answer);
  }

  // CORREÇÃO: Remover método não referenciado _getMedia
  // Future<void> _getMedia() async { ... }

  Future<void> _closeMediaStream() async {
    Logger.info("[Placeholder] Closing local media stream.");
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        await track.stop();
      }
      await _localStream!.dispose();
      _localStream = null;
      Logger.info('Local stream stopped and disposed.');
    }
  }

  Future<void> _closePeerConnection(String peerId, {bool notify = true}) async {
    Logger.info("[Placeholder] Closing peer connection for $peerId.");
    final pc = _peerConnections.remove(peerId);
    if (pc != null) {
      await pc.close();
      Logger.info('Peer connection closed and removed for $peerId');
    }
    final stream = _remoteStreams.remove(peerId);
    if (stream != null) {
       await stream.dispose();
       Logger.info('Remote stream disposed for $peerId');
    }
    if (notify) notifyListeners();
  }

  // CORREÇÃO: Remover método não referenciado _notifyListeners
  // void _notifyListeners() { ... }

  Future<void> _getLocalMedia() async {
     if (_localStream != null) return;
     Logger.info('Getting local media stream...');
     try {
       final Map<String, dynamic> mediaConstraints = {
         'audio': true,
         'video': false
       };
       _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
       if (_localStream!.getAudioTracks().isNotEmpty) {
          _localStream!.getAudioTracks()[0].enabled = !_isMicMuted;
       }
       Logger.info('Local media stream obtained: ${_localStream!.id}');
       notifyListeners();
     } catch (e, stackTrace) {
       Logger.error('Error getting local media', error: e, stackTrace: stackTrace);
       _updateCallState(CallState.error, 'Erro ao acessar microfone.');
       // CORREÇÃO: Usar rethrow
       rethrow;
     }
   }

  Future<RTCPeerConnection> _getOrCreatePeerConnection(String peerId) async {
    RTCPeerConnection? pc = _peerConnections[peerId];
    if (pc != null) {
      return pc;
    }

    Logger.info('Creating new Peer Connection for peer: $peerId');
    pc = await _createPeerConnection(peerId);
    _peerConnections[peerId] = pc;

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        pc!.addTrack(track, _localStream!); 
        // CORREÇÃO: Usar Logger.info ou warning
        Logger.info('Local track ${track.kind} added to PC for $peerId');
      });
    } else {
      Logger.warning('Local stream is null when creating PC for $peerId');
    }
    return pc;
  }

  void _listenToSignalingEvents() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      Logger.error("Cannot listen to signaling events: User not logged in.");
      return;
    }

    _cancelSignalingSubscriptions();

    _offerSubscription = _signalingService.onOfferReceived.listen(_handleOffer);
    _answerSubscription = _signalingService.onAnswerReceived.listen(_handleAnswer);
    _candidateSubscription = _signalingService.onCandidateReceived.listen(_handleCandidate);

    _peerJoinedSubscription = _signalingService.onPeerJoined.listen((peerId) {
      if (peerId != currentUser.id) {
        Logger.info('Peer $peerId joined the channel. Initiating connection.');
        _initiateConnection(peerId);
      }
    });

    _peerLeftSubscription = _signalingService.onPeerLeft.listen((peerId) {
      if (peerId != currentUser.id) {
        Logger.info('Peer $peerId left the channel. Closing connection.');
        _closePeerConnection(peerId);
      }
    });
     Logger.info('Listening to signaling events.');
  }

  Future<void> _initiateConnection(String peerId) async {
    if (_peerConnections.containsKey(peerId)) {
      Logger.info('Connection already exists or being initiated for peer $peerId');
      return;
    }
    try {
      await _createOffer(peerId);
    } catch (e, stackTrace) {
      Logger.error('Error initiating connection with $peerId', error: e, stackTrace: stackTrace);
      _closePeerConnection(peerId);
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    final senderId = data['senderId'] as String?;
    final sdpData = data['sdp'] as Map?;
    if (senderId == null || sdpData == null) return;

    Logger.info('Received offer from $senderId');
    try {
      final offer = RTCSessionDescription(sdpData['sdp'], sdpData['type']);
      await _createAnswer(senderId, offer);
    } catch (e, stackTrace) {
      Logger.error('Error handling offer from $senderId', error: e, stackTrace: stackTrace);
      _closePeerConnection(senderId);
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    final senderId = data['senderId'] as String?;
    final sdpData = data['sdp'] as Map?;
    if (senderId == null || sdpData == null) return;

    Logger.info('Received answer from $senderId');
    try {
      final answer = RTCSessionDescription(sdpData['sdp'], sdpData['type']);
      await _setRemoteDescription(senderId, answer);
    } catch (e, stackTrace) {
      Logger.error('Error handling answer from $senderId', error: e, stackTrace: stackTrace);
      _closePeerConnection(senderId);
    }
  }

  Future<void> _handleCandidate(Map<String, dynamic> data) async {
    final senderId = data['senderId'] as String?;
    final candidateData = data['candidate'] as Map?;
    if (senderId == null || candidateData == null) return;

    Logger.info('Received ICE candidate from $senderId');
    try {
      final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );
      await _addCandidate(senderId, candidate);
    } catch (e, stackTrace) {
      Logger.error('Error handling candidate from $senderId', error: e, stackTrace: stackTrace);
    }
  }

  // --- Controle de Mídia ---

  void toggleMicMute() {
    _isMicMuted = !_isMicMuted;
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      _localStream!.getAudioTracks()[0].enabled = !_isMicMuted;
      Logger.info('Microphone ${!_isMicMuted ? "unmuted" : "muted"}');
    }
    notifyListeners();
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    MediaStreamTrack? audioTrack;
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      audioTrack = _localStream!.getAudioTracks()[0];
    }
    // Note: Enabling/disabling speaker typically involves platform-specific code
    // or a package like `flutter_webrtc` might handle it via `setSpeakerphoneOn`
    // For now, just update the state.
    Helper.setSpeakerphoneOn(_isSpeakerOn);
    Logger.info('Speaker ${_isSpeakerOn ? "on" : "off"}');
    notifyListeners();
  }

  // --- Helpers ---

  void _updateCallState(CallState newState, [String? message]) {
    if (_callState != newState) {
      _callState = newState;
      _errorMessage = message;
      Logger.info('Call state changed: $newState ${message != null ? "($message)" : ""}');
      notifyListeners();
    }
  }
}

