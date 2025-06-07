// lib/screens/tabs/chat_tab.dart

import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/global_channel_model.dart';
import 'package:lucasbeatsfederacao/services/global_channel_service.dart';
import 'package:lucasbeatsfederacao/services/socket_service.dart';
import 'package:lucasbeatsfederacao/services/voice_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:provider/provider.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  String? _selectedChannelId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    final globalChannelService = Provider.of<GlobalChannelService>(context, listen: false);
    await globalChannelService.fetchGlobalChannels();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<GlobalChannelService, VoiceService>(
      builder: (context, globalChannelService, voiceService, child) {
        final textChannels = globalChannelService.textChannels;
        final voiceChannels = globalChannelService.voiceChannels;

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar com canais
                  Container(
                    width: 200,
                    color: Colors.grey[900],
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'CANAIS DE TEXTO',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ...textChannels.map((channel) => _buildChannelTile(
                              channel,
                              isSelected: _selectedChannelId == channel.id,
                              isVoice: false,
                            )),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'CANAIS DE VOZ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ...voiceChannels.map((channel) => _buildChannelTile(
                              channel,
                              isSelected: voiceService.activeChannelId == channel.id,
                              isVoice: true,
                              isConnected: voiceService.isConnected && 
                                          voiceService.activeChannelId == channel.id,
                              isMuted: voiceService.isMuted,
                              isDeafened: voiceService.isDeafened,
                            )),
                      ],
                    ),
                  ),
                  // Área de chat
                  Expanded(
                    child: _selectedChannelId != null
                        ? _buildChatArea()
                        : const Center(
                            child: Text(
                              'Selecione um canal para começar a conversar',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChannelTile(
    GlobalChannelModel channel, {
    required bool isSelected,
    required bool isVoice,
    bool isConnected = false,
    bool isMuted = false,
    bool isDeafened = false,
  }) {
    return ListTile(
      leading: Icon(
        isVoice ? Icons.headset : Icons.tag,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      title: Text(
        channel.name,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: isVoice
          ? Text(
              '${channel.activeUsers.length}/${channel.userLimit ?? 15} usuários',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: isVoice && isConnected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMuted)
                  const Icon(Icons.mic_off, color: Colors.red, size: 16),
                if (isDeafened)
                  const Icon(Icons.hearing_disabled, color: Colors.red, size: 16),
              ],
            )
          : null,
      selected: isSelected,
      selectedTileColor: Colors.blueGrey[800],
      onTap: () {
        if (isVoice) {
          _handleVoiceChannelTap(channel);
        } else {
          setState(() {
            _selectedChannelId = channel.id;
          });
          // Aqui você pode carregar as mensagens do canal selecionado
        }
      },
    );
  }

  void _handleVoiceChannelTap(GlobalChannelModel channel) async {
    final voiceService = Provider.of<VoiceService>(context, listen: false);
    
    if (voiceService.activeChannelId == channel.id) {
      // Se já estiver conectado a este canal, desconectar
      await voiceService.leaveChannel();
    } else {
      // Se não estiver conectado ou estiver em outro canal, conectar a este
      await voiceService.joinChannel(channel.id);
    }
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        // Cabeçalho do canal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            border: Border(
              bottom: BorderSide(color: Colors.grey[900]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.tag, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'canal-global',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        // Área de mensagens
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: 10, // Placeholder
            itemBuilder: (context, index) {
              return _buildMessageItem(index);
            },
          ),
        ),
        // Campo de entrada de mensagem
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            border: Border(
              top: BorderSide(color: Colors.grey[900]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enviar mensagem...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(int index) {
    // Placeholder para mensagens
    final bool isMe = index % 2 == 0;
    final String username = isMe ? 'Você' : 'Usuário ${index + 1}';
    final String message = 'Esta é uma mensagem de exemplo $index';
    final String time = '12:${index.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isMe ? Colors.blue : Colors.green,
            child: Text(
              username.substring(0, 1),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        color: isMe ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    // Aqui você enviaria a mensagem para o servidor
    Logger.info('Enviando mensagem: ${_messageController.text}');
    
    // Limpar o campo após enviar
    _messageController.clear();
    
    // Rolar para o final da lista
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

