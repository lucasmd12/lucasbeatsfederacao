import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/voip_service.dart';
import '../models/user_model.dart';

class CallScreen extends StatefulWidget {
  final UserModel targetUser;
  final bool isIncoming;

  const CallScreen({
    Key? key,
    required this.targetUser,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late VoipService _voipService;
  Duration _callDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _voipService = Provider.of<VoipService>(context, listen: false);
    
    if (!widget.isIncoming) {
      _startCall();
    }
    
    _startTimer();
  }

  void _startCall() async {
    await _voipService.startCall(widget.targetUser.id!);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_voipService.isConnected) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Consumer<VoipService>(
        builder: (context, voipService, child) {
          return SafeArea(
            child: Column(
              children: [
                // Header com informações do usuário
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar do usuário
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Nome do usuário
                        Text(
                          widget.targetUser.nome ?? widget.targetUser.username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        
                        // Status da chamada
                        Text(
                          _getCallStatus(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        
                        // Duração da chamada
                        if (voipService.isConnected) ...[
                          SizedBox(height: 16),
                          Text(
                            _formatDuration(_callDuration),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Controles da chamada
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Primeira linha de controles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Botão mute
                            _buildControlButton(
                              icon: voipService.isMuted ? Icons.mic_off : Icons.mic,
                              onPressed: () => voipService.toggleMute(),
                              backgroundColor: voipService.isMuted ? Colors.red : Colors.grey.shade800,
                            ),
                            
                            // Botão speaker (placeholder)
                            _buildControlButton(
                              icon: Icons.volume_up,
                              onPressed: () {
                                // Implementar toggle speaker
                              },
                              backgroundColor: Colors.grey.shade800,
                            ),
                          ],
                        ),
                        
                        // Segunda linha - botão encerrar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Botões de chamada entrante
                            if (widget.isIncoming && !voipService.isConnected) ...[
                              // Botão recusar
                              _buildControlButton(
                                icon: Icons.call_end,
                                onPressed: () {
                                  voipService.endCall();
                                  Navigator.of(context).pop();
                                },
                                backgroundColor: Colors.red,
                                size: 60,
                              ),
                              SizedBox(width: 40),
                              // Botão aceitar
                              _buildControlButton(
                                icon: Icons.call,
                                onPressed: () {
                                  // Implementar aceitar chamada
                                },
                                backgroundColor: Colors.green,
                                size: 60,
                              ),
                            ] else ...[
                              // Botão encerrar chamada
                              _buildControlButton(
                                icon: Icons.call_end,
                                onPressed: () {
                                  voipService.endCall();
                                  Navigator.of(context).pop();
                                },
                                backgroundColor: Colors.red,
                                size: 60,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.grey,
    double size = 50,
  }) {
    return Container(
      width: size + 10,
      height: size + 10,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.6),
        onPressed: onPressed,
      ),
    );
  }

  String _getCallStatus() {
    final voipService = Provider.of<VoipService>(context, listen: false);
    
    if (widget.isIncoming && !voipService.isConnected) {
      return 'Chamada entrante...';
    } else if (voipService.isConnected) {
      return 'Conectado';
    } else if (voipService.isCalling) {
      return 'Chamando...';
    } else {
      return 'Conectando...';
    }
  }
}

