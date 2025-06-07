import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_channel_model.dart';
import '../../utils/logger.dart';

class VoiceChannelsTab extends StatefulWidget {
  const VoiceChannelsTab({Key? key}) : super(key: key);

  @override
  State<VoiceChannelsTab> createState() => _VoiceChannelsTabState();
}

class _VoiceChannelsTabState extends State<VoiceChannelsTab> {
  final List<ChatChannelModel> _voiceChannels = [
    ChatChannelModel(
      id: 'voice_1',
      name: 'Canal de Voz Geral',
      description: 'Canal principal para conversas de voz',
      tipo: 'voice',
    ),
    ChatChannelModel(
      id: 'voice_2',
      name: 'Jogos',
      description: 'Canal para jogar e conversar',
      tipo: 'voice',
    ),
    ChatChannelModel(
      id: 'voice_3',
      name: 'Música',
      description: 'Canal para ouvir música juntos',
      tipo: 'voice',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<CallProvider, AuthProvider>(
      builder: (context, callProvider, authProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Canais de Voz',
              style: TextStyle(color: Colors.white),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              // Status da chamada atual
              if (callProvider.isInCall) _buildCurrentCallStatus(callProvider),
              
              // Lista de canais de voz
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _voiceChannels.length,
                  itemBuilder: (context, index) {
                    final channel = _voiceChannels[index];
                    final isCurrentChannel = callProvider.currentChannel?.id == channel.id;
                    
                    return _buildVoiceChannelCard(
                      channel, 
                      isCurrentChannel, 
                      callProvider,
                      authProvider,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentCallStatus(CallProvider callProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF00C851),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conectado ao: ${callProvider.currentChannel?.name ?? 'Canal desconhecido'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${callProvider.participants.length} participante(s)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _leaveVoiceChannel(callProvider),
            icon: const Icon(Icons.call_end, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceChannelCard(
    ChatChannelModel channel,
    bool isCurrentChannel,
    CallProvider callProvider,
    AuthProvider authProvider,
  ) {
    final participantsCount = isCurrentChannel ? callProvider.participants.length : 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCurrentChannel ? const Color(0xFF00C851) : const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCurrentChannel ? Colors.white.withOpacity(0.2) : const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.volume_up,
            color: isCurrentChannel ? Colors.white : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          channel.name,
          style: TextStyle(
            color: isCurrentChannel ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              channel.description,
              style: TextStyle(
                color: isCurrentChannel ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
            if (participantsCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$participantsCount participante(s) conectado(s)',
                style: TextStyle(
                  color: isCurrentChannel ? Colors.white : Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: isCurrentChannel
            ? const Icon(Icons.phone, color: Colors.white)
            : const Icon(Icons.phone_disabled, color: Colors.grey),
        onTap: () => _toggleVoiceChannel(channel, callProvider, authProvider),
      ),
    );
  }

  void _toggleVoiceChannel(
    ChatChannelModel channel,
    CallProvider callProvider,
    AuthProvider authProvider,
  ) async {
    try {
      if (callProvider.currentChannel?.id == channel.id) {
        // Se já está no canal, sair
        await _leaveVoiceChannel(callProvider);
      } else {
        // Entrar no canal
        await _joinVoiceChannel(channel, callProvider, authProvider);
      }
    } catch (e) {
      Logger.error('Erro ao alternar canal de voz: $e');
      _showErrorSnackBar('Erro ao conectar ao canal de voz');
    }
  }

  Future<void> _joinVoiceChannel(
    ChatChannelModel channel,
    CallProvider callProvider,
    AuthProvider authProvider,
  ) async {
    try {
      // Se já estiver em outro canal, sair primeiro
      if (callProvider.isInCall) {
        await callProvider.leaveCall();
      }

      // Entrar no novo canal
      final success = await callProvider.joinVoiceChannel(channel);
      
      if (success) {
        Logger.info('Conectado ao canal de voz: ${channel.name}');
        _showSuccessSnackBar('Conectado ao ${channel.name}');
      } else {
        _showErrorSnackBar('Falha ao conectar ao canal de voz');
      }
    } catch (e) {
      Logger.error('Erro ao entrar no canal de voz: $e');
      _showErrorSnackBar('Erro ao conectar ao canal de voz');
    }
  }

  Future<void> _leaveVoiceChannel(CallProvider callProvider) async {
    try {
      await callProvider.leaveCall();
      Logger.info('Desconectado do canal de voz');
      _showSuccessSnackBar('Desconectado do canal de voz');
    } catch (e) {
      Logger.error('Erro ao sair do canal de voz: $e');
      _showErrorSnackBar('Erro ao desconectar do canal de voz');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}