import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clan_provider.dart';
import '../../models/user_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    // Carregar dados do clan se necessário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clanProvider = Provider.of<ClanProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        clanProvider.loadUserClan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final clanProvider = Provider.of<ClanProvider>(context);
    final UserModel? currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Nenhum usuário logado.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nome de Usuário: ${currentUser.username}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('ID: ${currentUser.id}'),
                  const SizedBox(height: 8),
                  Text('Status: ${currentUser.status ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text('Online: ${currentUser.isOnline ? 'Sim' : 'Não'}'),
                  const SizedBox(height: 20),
                  const Text(
                    'Informações do Clã:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (clanProvider.isLoading)
                    const CircularProgressIndicator()
                  else if (clanProvider.error != null)
                    Text('Erro ao carregar clã: ${clanProvider.error}', style: const TextStyle(color: Colors.red))
                  else if (clanProvider.userClan != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nome do Clã: ${clanProvider.userClan!.name}'),
                        Text('Descrição: ${clanProvider.userClan!.description ?? 'N/A'}'),
                        Text('Membros: ${clanProvider.userClan!.members.length}'),
                      ],
                    )
                  else
                    const Text('Não pertence a nenhum clã.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      clanProvider.loadUserClan(); // Recarregar informações do clã
                    },
                    child: const Text('Recarregar Informações do Clã'),
                  ),
                ],
              ),
            ),
    );
  }
}


