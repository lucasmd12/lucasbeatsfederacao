import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/clan_service.dart';
import '../../providers/call_provider.dart';
import '../../utils/logger.dart';
import '../../models/chat_channel_model.dart';

class ChatListTab extends StatefulWidget {
  const ChatListTab({super.key});

  @override
  State<ChatListTab> createState() => _ChatListTabState();
}

class _ChatListTabState extends State<ChatListTab> {
  ClanService? _clanService;
  AuthService? _authService;
  CallProvider? _callProvider;

  String? _currentVoiceChannelId;
  bool _isLoadingChannels = false;
  List<ChatChannelModel> _voiceChannels = [];
  String? _errorLoadingChannels;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initServicesAndLoadData();
        _callProvider?.addListener(_updateCurrentChannelState);
      }
    });
  }

  void _initServicesAndLoadData() {
    if (!mounted) return;
    _authService = Provider.of<AuthService>(context, listen: false);
    _clanService = Provider.of<ClanService>(context, listen: false);
    _callProvider = Provider.of<CallProvider>(context, listen: false);
    _updateCurrentChannelState();
    _loadVoiceChannels();
  }

  @override
  void dispose() {
    _callProvider?.removeListener(_updateCurrentChannelState);
    super.dispose();
  }

  void _updateCurrentChannelState() {
    if (!mounted) return;
    final newChannelId = _callProvider?.currentChannelId;
    if (_currentVoiceChannelId != newChannelId) {
      setState(() {
        _currentVoiceChannelId = newChannelId;
        Logger.info("ChatListTab updated current channel ID: $_currentVoiceChannelId");
      });
    }
  }

  Future<void> _loadVoiceChannels() async {
    if (_isLoadingChannels || _clanService == null || _authService == null || !mounted) return;

    setState(() {
      _isLoadingChannels = true;
      _errorLoadingChannels = null;
    });

    try {
      List<ChatChannelModel> fetchedChannels = [];
      final UserModel? currentUser = _authService!.currentUser;

      // Always add a global chat channel
      fetchedChannels.add(ChatChannelModel(
        id: 'global_chat_channel',
        nome: 'Chat Global',
        descricao: 'Canal de chat para todos os usuários.',
        tipo: 'text',
        membros: [], // Members can be dynamic or fetched if needed
      ));

      // If user is in a clan, fetch clan-specific voice channels
      if (currentUser?.clanId != null) {
        final String clanId = currentUser!.clanId!;
        try {
          final List<ChatChannelModel> clanVoiceChannels = await _clanService!.getClanChannels(clanId, type: 'voice');
          fetchedChannels.addAll(clanVoiceChannels);
          Logger.info("Loaded ${clanVoiceChannels.length} voice channels for clan $clanId.");
        } catch (e, s) {
          Logger.error("Erro ao carregar canais de voz do clã", error: e, stackTrace: s);
          // Do not set _errorLoadingChannels here, as global chat is still available
        }
      }

      if (mounted) {
        setState(() {
          _voiceChannels = fetchedChannels;
        });
      }
    } catch (e, s) {
      Logger.error("Erro geral ao carregar canais", error: e, stackTrace: s);
      if (mounted) {
        setState(() {
          _errorLoadingChannels = "Erro ao carregar canais: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChannels = false;
        });
      }
    }
  }

  Future<void> _entrarNoCanal(String channelId, String channelName) async {
    if (_callProvider == null || !mounted) return;
    Logger.info("Attempting to join voice channel: $channelId ($channelName)");
    try {
      // For global chat, we might not use joinChannel if it's voice-specific.
      // Assuming joinChannel can handle text channels or a generic chat connection.
      await _callProvider!.joinChannel(channelId); // This might need adjustment based on backend for text chat
    } catch (e) {
      Logger.error("Error joining channel $channelId from UI", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao entrar no canal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sairDoCanal() async {
    if (_callProvider == null || !mounted) return;
    Logger.info("Attempting to leave current voice channel: $_currentVoiceChannelId");
    try {
      await _callProvider!.leaveChannel();
    } catch (e) {
      Logger.error("Error leaving channel $_currentVoiceChannelId from UI", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair do canal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingChannels) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorLoadingChannels != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorLoadingChannels!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.redAccent), textAlign: TextAlign.center),
      ));
    }

    if (_voiceChannels.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Nenhum canal de chat disponível.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
      ));
    }

    return RefreshIndicator(
      onRefresh: _loadVoiceChannels,
      child: ListView.builder(
        itemCount: _voiceChannels.length,
        itemBuilder: (context, index) {
          final canal = _voiceChannels[index];
          final bool estouNesteCanal = canal.id == _currentVoiceChannelId;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: estouNesteCanal ? theme.primaryColor.withOpacity(0.3) : theme.cardColor,
            child: ListTile(
              leading: Icon(
                canal.tipo == 'text' ? Icons.chat : Icons.headset_mic, // Use chat icon for text channels
                color: estouNesteCanal ? theme.primaryColor : theme.iconTheme.color,
              ),
              title: Text(canal.nome, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
              trailing: estouNesteCanal
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text("Sair"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: _sairDoCanal,
                    )
                  : ElevatedButton(
                      child: const Text("Entrar"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _entrarNoCanal(canal.id, canal.nome),
                    ),
            ),
          );
        },
      ),
    );
  }
}


