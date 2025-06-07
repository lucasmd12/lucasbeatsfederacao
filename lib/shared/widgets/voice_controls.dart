// lib/widgets/voice_controls.dart

import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/services/voice_service.dart';
import 'package:provider/provider.dart';

class VoiceControls extends StatelessWidget {
  const VoiceControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceService>(
      builder: (context, voiceService, child) {
        if (!voiceService.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de conexão
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              
              // Texto de status
              const Text(
                'Conectado',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              
              // Botão de mudo
              IconButton(
                icon: Icon(
                  voiceService.isMuted ? Icons.mic_off : Icons.mic,
                  color: voiceService.isMuted ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  voiceService.toggleMute();
                },
                tooltip: voiceService.isMuted ? 'Ativar microfone' : 'Desativar microfone',
              ),
              
              // Botão de surdo
              IconButton(
                icon: Icon(
                  voiceService.isDeafened ? Icons.hearing_disabled : Icons.hearing,
                  color: voiceService.isDeafened ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  voiceService.toggleDeafen();
                },
                tooltip: voiceService.isDeafened ? 'Ativar áudio' : 'Desativar áudio',
              ),
              
              // Botão de desconectar
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: () {
                  voiceService.leaveChannel();
                },
                tooltip: 'Desconectar',
              ),
            ],
          ),
        );
      },
    );
  }
}

