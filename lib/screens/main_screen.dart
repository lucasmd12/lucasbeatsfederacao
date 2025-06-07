import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/clan_provider.dart';
import '../providers/chat_provider.dart';
import '../components/clan_list.dart';
import '../components/chat_widget.dart';
import '../utils/logger.dart';
import '../models/message_model.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      await context.read<ClanProvider>().loadUserClan();
      await context.read<ClanProvider>().loadAllClans();
      // ChatProvider.loadMessages() não existe mais, o chat agora usa StreamBuilder
    } catch (e) {
      Logger.error('Error loading initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lucas Beats Federação'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout(); // Usar logout do AuthProvider
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.group), text: 'Clãs'),
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildClansTab(),
          _buildChatTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Clãs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo, ${user?.username ?? 'Usuário'}!', // Usar username
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações do Usuário',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text('Nome de Usuário: ${user?.username ?? 'N/A'}'),
                      Text('ID: ${user?.id ?? 'N/A'}'),
                      Text('Status: ${user?.status ?? 'N/A'}'),
                      Text('Online: ${user?.isOnline ?? false ? 'Sim' : 'Não'}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClansTab() {
    return Consumer<ClanProvider>(
      builder: (context, clanProvider, _) {
        if (clanProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await clanProvider.loadAllClans();
          },
          child: ClanList(clans: clanProvider.allClans),
        );
      },
    );
  }

  Widget _buildChatTab() {
    return Consumer2<ChatProvider, AuthProvider>(
      builder: (context, chatProvider, authProvider, _) {
        final currentUser = authProvider.currentUser;
        final currentChannel = chatProvider.currentChannel; // Obter o canal atual

        if (currentUser == null) {
          return const Center(child: Text('Faça login para acessar o chat.'));
        }

        if (currentChannel == null) {
          return const Center(child: Text('Selecione um canal de chat.'));
        }

        return StreamBuilder<List<MessageModel>>(
          stream: chatProvider.getMessages(currentChannel.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar mensagens: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma mensagem ainda.'));
            }

            final messages = snapshot.data!;

            return ChatWidget(
              messages: messages,
              isLoading: chatProvider.isLoading,
              onSendMessage: (messageContent) {
                chatProvider.sendMessage(currentChannel.id, messageContent, currentUser);
              },
              onRefresh: () {
                // A atualização do chat é via Stream, então este onRefresh pode ser para outros fins ou removido
                Logger.info('Chat refresh triggered, but messages are stream-based.');
              },
            );
          },
        );
      },
    );
  }
}


