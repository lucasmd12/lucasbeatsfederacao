// lib/widgets/voice_channel_card.dart

import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/global_channel_model.dart';
import 'package:lucasbeatsfederacao/services/voice_service.dart';
import 'package:provider/provider.dart';

class VoiceChannelCard extends StatelessWidget {
  final GlobalChannelModel channel;
  
  const VoiceChannelCard({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceService>(
      builder: (context, voiceService, child) {
        final bool isActive = voiceService.activeChannelId == channel.id;
        
        return Card(
          color: isActive ? Colors.blueGrey[700] : Colors.grey[850],
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: () => _handleChannelTap(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do canal
                  Row(
                    children: [
                      Icon(
                        Icons.headset,
                        color: isActive ? Colors.green : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          channel.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.grey[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Conectado' : '${channel.activeUsers.length}/${channel.userLimit ?? 15}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (channel.description != null && channel.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        channel.description!,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  
                  // Botões de ação
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Botão de mudo
                          IconButton(
                            icon: Icon(
                              voiceService.isMuted ? Icons.mic_off : Icons.mic,
                              color: voiceService.isMuted ? Colors.red : Colors.white,
                              size: 20,
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
                              size: 20,
                            ),
                            onPressed: () {
                              voiceService.toggleDeafen();
                            },
                            tooltip: voiceService.isDeafened ? 'Ativar áudio' : 'Desativar áudio',
                          ),
                          
                          // Botão de desconectar
                          IconButton(
                            icon: const Icon(Icons.call_end, color: Colors.red, size: 20),
                            onPressed: () {
                              voiceService.leaveChannel();
                            },
                            tooltip: 'Desconectar',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _handleChannelTap(BuildContext context) {
    final voiceService = Provider.of<VoiceService>(context, listen: false);
    
    if (voiceService.activeChannelId == channel.id) {
      // Se já estiver conectado a este canal, desconectar
      voiceService.leaveChannel();
    } else {
      // Se não estiver conectado ou estiver em outro canal, conectar a este
      voiceService.joinChannel(channel.id);
    }
  }
}

