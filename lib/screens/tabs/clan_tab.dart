// lib/screens/tabs/clan_tab.dart

import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/clan_model.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart';
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/services/clan_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:provider/provider.dart';

class ClanTab extends StatefulWidget {
  const ClanTab({Key? key}) : super(key: key);

  @override
  State<ClanTab> createState() => _ClanTabState();
}

class _ClanTabState extends State<ClanTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  final TextEditingController _clanNameController = TextEditingController();
  final TextEditingController _clanTagController = TextEditingController();
  final TextEditingController _clanDescriptionController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadClanData();
  }

  Future<void> _loadClanData() async {
    final clanService = Provider.of<ClanService>(context, listen: false);
    await clanService.fetchUserClan();
    await clanService.fetchAllClans();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<ClanService, AuthService>(
      builder: (context, clanService, authService, child) {
        if (_isLoading || clanService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final userClan = clanService.userClan;
        final currentUser = authService.currentUser;

        if (userClan == null) {
          return _buildNoClanView(clanService, currentUser);
        } else {
          return _buildClanView(clanService, userClan, currentUser);
        }
      },
    );
  }

  Widget _buildNoClanView(ClanService clanService, UserModel? currentUser) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Você não pertence a nenhum clã',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateClanDialog(clanService),
            child: const Text('Criar um Clã'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ou entre em um clã existente:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildClansList(clanService),
          ),
        ],
      ),
    );
  }

  Widget _buildClansList(ClanService clanService) {
    final clans = clanService.allClans;
    
    if (clans.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum clã encontrado',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: clans.length,
      itemBuilder: (context, index) {
        final clan = clans[index];
        return Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: clan.banner != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(clan.banner!),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey[700],
                    child: Text(
                      clan.tag,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
            title: Text(
              clan.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'TAG: ${clan.tag} • Membros: ${clan.members.length}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: ElevatedButton(
              onPressed: () => _joinClan(clanService, clan.id),
              child: const Text('Entrar'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClanView(ClanService clanService, ClanModel clan, UserModel? currentUser) {
    final isLeader = currentUser != null && clan.leader.id == currentUser.id;
    final isSubLeader = currentUser != null && clan.subLeaders.any((subLeader) => subLeader.id == currentUser.id);
    
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                Row(
                  children: [
                    clan.banner != null
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(clan.banner!),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[700],
                            child: Text(
                              clan.tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'TAG: ${clan.tag}',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          if (clan.federationName != null)
                            Text(
                              'Federação: ${clan.federationName}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                        ],
                      ),
                    ),
                    if (isLeader || isSubLeader)
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => _showClanSettingsDialog(clanService, clan),
                      ),
                  ],
                ),
                if (clan.description != null && clan.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      clan.description!,
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
              ],
            ),
          ),
          TabBar(
            tabs: const [
              Tab(text: 'Membros'),
              Tab(text: 'Cargos'),
              Tab(text: 'Alianças'),
              Tab(text: 'Regras'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            indicatorColor: Colors.red,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMembersTab(clanService, clan, isLeader, isSubLeader),
                _buildRolesTab(clanService, clan, isLeader),
                _buildAlliancesTab(clanService, clan, isLeader),
                _buildRulesTab(clan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(ClanService clanService, ClanModel clan, bool isLeader, bool isSubLeader) {
    final allMembers = [clan.leader, ...clan.subLeaders, ...clan.members.where((member) => 
      member.id != clan.leader.id && !clan.subLeaders.any((subLeader) => subLeader.id == member.id)
    )];
    
    return ListView.builder(
      itemCount: allMembers.length,
      itemBuilder: (context, index) {
        final member = allMembers[index];
        final isLeaderMember = member.id == clan.leader.id;
        final isSubLeaderMember = clan.subLeaders.any((subLeader) => subLeader.id == member.id);
        
        // Encontrar cargo personalizado
        String? customRole;
        for (var memberRole in clan.memberRoles) {
          if (memberRole.userId == member.id) {
            customRole = memberRole.role;
            break;
          }
        }
        
        return Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: member.avatar != null
                  ? NetworkImage(member.avatar!)
                  : null,
              child: member.avatar == null
                  ? Text(member.username.substring(0, 1).toUpperCase())
                  : null,
            ),
            title: Row(
              children: [
                Text(
                  member.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (isLeaderMember)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Líder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (isSubLeaderMember)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sub-Líder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (customRole != null)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getColorFromHex(
                        clan.customRoles.firstWhere((role) => role.name == customRole).color,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      customRole,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              member.status == 'online' ? 'Online' : 'Offline',
              style: TextStyle(
                color: member.status == 'online' ? Colors.green : Colors.grey,
              ),
            ),
            trailing: (isLeader || isSubLeader) && !isLeaderMember && member.id != Provider.of<AuthService>(context, listen: false).currentUser?.id
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      switch (value) {
                        case 'promote':
                          if (isLeader && !isSubLeaderMember) {
                            _promoteMember(clanService, member.id);
                          }
                          break;
                        case 'demote':
                          if (isLeader && isSubLeaderMember) {
                            _demoteMember(clanService, member.id);
                          }
                          break;
                        case 'kick':
                          if ((isLeader) || (isSubLeader && !isSubLeaderMember)) {
                            _kickMember(clanService, member.id);
                          }
                          break;
                        case 'transfer':
                          if (isLeader) {
                            _transferLeadership(clanService, member.id);
                          }
                          break;
                        case 'assign_role':
                          if (isLeader) {
                            _showAssignRoleDialog(clanService, member.id, clan.customRoles);
                          }
                          break;
                        case 'remove_role':
                          if (isLeader && customRole != null) {
                            _removeRole(clanService, member.id);
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (isLeader && !isSubLeaderMember)
                        const PopupMenuItem<String>(
                          value: 'promote',
                          child: Text('Promover a Sub-Líder'),
                        ),
                      if (isLeader && isSubLeaderMember)
                        const PopupMenuItem<String>(
                          value: 'demote',
                          child: Text('Rebaixar a Membro'),
                        ),
                      if ((isLeader) || (isSubLeader && !isSubLeaderMember))
                        const PopupMenuItem<String>(
                          value: 'kick',
                          child: Text('Expulsar do Clã'),
                        ),
                      if (isLeader)
                        const PopupMenuItem<String>(
                          value: 'transfer',
                          child: Text('Transferir Liderança'),
                        ),
                      if (isLeader)
                        const PopupMenuItem<String>(
                          value: 'assign_role',
                          child: Text('Atribuir Cargo'),
                        ),
                      if (isLeader && customRole != null)
                        const PopupMenuItem<String>(
                          value: 'remove_role',
                          child: Text('Remover Cargo'),
                        ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildRolesTab(ClanService clanService, ClanModel clan, bool isLeader) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cargos Personalizados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isLeader)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showCreateRoleDialog(clanService),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: clan.customRoles.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum cargo personalizado criado',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: clan.customRoles.length,
                    itemBuilder: (context, index) {
                      final role = clan.customRoles[index];
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColorFromHex(role.color),
                            child: Text(
                              role.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            role.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            _getRolePermissionsText(role.permissions),
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          trailing: isLeader
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRole(clanService, index),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlliancesTab(ClanService clanService, ClanModel clan, bool isLeader) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aliados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isLeader)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showAddAllyDialog(clanService, clan),
                ),
            ],
          ),
          const SizedBox(height: 8),
          clan.allies.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Nenhum clã aliado',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: clan.allies.length,
                    itemBuilder: (context, index) {
                      final allyId = clan.allies[index];
                      final allyClan = clanService.allClans.firstWhere(
                        (c) => c.id == allyId,
                        orElse: () => ClanModel(
                          id: allyId,
                          name: 'Clã Desconhecido',
                          tag: '???',
                          leader: UserModel(
                            id: '',
                            username: 'Desconhecido',
                            email: '',
                          ),
                        ),
                      );
                      
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: Text(
                              allyClan.tag.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            allyClan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'TAG: ${allyClan.tag}',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          trailing: isLeader
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeAlly(clanService, allyId),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inimigos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isLeader)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showAddEnemyDialog(clanService, clan),
                ),
            ],
          ),
          const SizedBox(height: 8),
          clan.enemies.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Nenhum clã inimigo',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: clan.enemies.length,
                    itemBuilder: (context, index) {
                      final enemyId = clan.enemies[index];
                      final enemyClan = clanService.allClans.firstWhere(
                        (c) => c.id == enemyId,
                        orElse: () => ClanModel(
                          id: enemyId,
                          name: 'Clã Desconhecido',
                          tag: '???',
                          leader: UserModel(
                            id: '',
                            username: 'Desconhecido',
                            email: '',
                          ),
                        ),
                      );
                      
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red[700],
                            child: Text(
                              enemyClan.tag.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            enemyClan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'TAG: ${enemyClan.tag}',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          trailing: isLeader
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeEnemy(clanService, enemyId),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRulesTab(ClanModel clan) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Regras do Clã',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            clan.rules != null && clan.rules!.isNotEmpty
                ? Text(
                    clan.rules!,
                    style: const TextStyle(color: Colors.white),
                  )
                : const Text(
                    'Nenhuma regra definida para este clã.',
                    style: TextStyle(color: Colors.white70),
                  ),
          ],
        ),
      ),
    );
  }

  void _showCreateClanDialog(ClanService clanService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Criar Novo Clã',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _clanNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome do Clã',
                labelStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _clanTagController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'TAG do Clã (máx. 5 caracteres)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLength: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _clanDescriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clanNameController.clear();
              _clanTagController.clear();
              _clanDescriptionController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createClan(clanService);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showClanSettingsDialog(ClanService clanService, ClanModel clan) {
    final TextEditingController nameController = TextEditingController(text: clan.name);
    final TextEditingController descriptionController = TextEditingController(text: clan.description);
    final TextEditingController rulesController = TextEditingController(text: clan.rules);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Configurações do Clã',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome do Clã',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rulesController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Regras do Clã',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Implementar upload de bandeira
                },
                icon: const Icon(Icons.upload),
                label: const Text('Alterar Bandeira do Clã'),
              ),
              const SizedBox(height: 8),
              if (clanService.isUserClanLeader)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteClanConfirmation(clanService);
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Deletar Clã'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateClan(
                clanService,
                name: nameController.text,
                description: descriptionController.text,
                rules: rulesController.text,
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showCreateRoleDialog(ClanService clanService) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController colorController = TextEditingController(text: '#FF0000');
    bool manageMembers = false;
    bool manageChannels = false;
    bool manageRoles = false;
    bool kickMembers = false;
    bool muteMembers = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Criar Novo Cargo',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nome do Cargo',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: colorController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Cor (formato hex: #RRGGBB)',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getColorFromHex(colorController.text),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Permissões:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Gerenciar Membros',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: manageMembers,
                  onChanged: (value) {
                    setState(() {
                      manageMembers = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Gerenciar Canais',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: manageChannels,
                  onChanged: (value) {
                    setState(() {
                      manageChannels = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Gerenciar Cargos',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: manageRoles,
                  onChanged: (value) {
                    setState(() {
                      manageRoles = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Expulsar Membros',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: kickMembers,
                  onChanged: (value) {
                    setState(() {
                      kickMembers = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
                CheckboxListTile(
                  title: const Text(
                    'Mutar Membros',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: muteMembers,
                  onChanged: (value) {
                    setState(() {
                      muteMembers = value ?? false;
                    });
                  },
                  activeColor: Colors.red,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createRole(
                  clanService,
                  name: nameController.text,
                  color: colorController.text,
                  permissions: RolePermissions(
                    manageMembers: manageMembers,
                    manageChannels: manageChannels,
                    manageRoles: manageRoles,
                    kickMembers: kickMembers,
                    muteMembers: muteMembers,
                  ),
                );
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignRoleDialog(ClanService clanService, String userId, List<CustomRole> roles) {
    String? selectedRole;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Atribuir Cargo',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecione um cargo para atribuir:',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role.name,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getColorFromHex(role.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(role.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedRole == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _assignRole(clanService, userId, selectedRole!);
                    },
              child: const Text('Atribuir'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAllyDialog(ClanService clanService, ClanModel clan) {
    final availableClans = clanService.allClans.where((c) => 
      c.id != clan.id && 
      !clan.allies.contains(c.id) && 
      !clan.enemies.contains(c.id)
    ).toList();
    
    String? selectedClanId;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Adicionar Clã Aliado',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecione um clã para adicionar como aliado:',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              availableClans.isEmpty
                  ? const Text(
                      'Não há clãs disponíveis para adicionar como aliados.',
                      style: TextStyle(color: Colors.white70),
                    )
                  : DropdownButtonFormField<String>(
                      value: selectedClanId,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: availableClans.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text('${c.name} [${c.tag}]'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClanId = value;
                        });
                      },
                    ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedClanId == null || availableClans.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _addAlly(clanService, selectedClanId!);
                    },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEnemyDialog(ClanService clanService, ClanModel clan) {
    final availableClans = clanService.allClans.where((c) => 
      c.id != clan.id && 
      !clan.allies.contains(c.id) && 
      !clan.enemies.contains(c.id)
    ).toList();
    
    String? selectedClanId;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Adicionar Clã Inimigo',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecione um clã para adicionar como inimigo:',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              availableClans.isEmpty
                  ? const Text(
                      'Não há clãs disponíveis para adicionar como inimigos.',
                      style: TextStyle(color: Colors.white70),
                    )
                  : DropdownButtonFormField<String>(
                      value: selectedClanId,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: availableClans.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text('${c.name} [${c.tag}]'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClanId = value;
                        });
                      },
                    ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedClanId == null || availableClans.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _addEnemy(clanService, selectedClanId!);
                    },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteClanConfirmation(ClanService clanService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Deletar Clã',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja deletar o clã? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteClan(clanService);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createClan(ClanService clanService) async {
    if (_clanNameController.text.isEmpty || _clanTagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e TAG do clã são obrigatórios')),
      );
      return;
    }

    final result = await clanService.createClan(
      name: _clanNameController.text,
      tag: _clanTagController.text,
      description: _clanDescriptionController.text.isNotEmpty
          ? _clanDescriptionController.text
          : null,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clã criado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao criar clã')),
      );
    }

    _clanNameController.clear();
    _clanTagController.clear();
    _clanDescriptionController.clear();
  }

  Future<void> _joinClan(ClanService clanService, String clanId) async {
    final result = await clanService.joinClan(clanId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você entrou no clã com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao entrar no clã')),
      );
    }
  }

  Future<void> _updateClan(
    ClanService clanService, {
    required String name,
    String? description,
    String? rules,
  }) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome do clã é obrigatório')),
      );
      return;
    }

    final result = await clanService.updateClan(
      name: name,
      description: description,
      rules: rules,
    );

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clã atualizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao atualizar clã')),
      );
    }
  }

  Future<void> _promoteMember(ClanService clanService, String userId) async {
    final result = await clanService.promoteMember(userId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membro promovido com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao promover membro')),
      );
    }
  }

  Future<void> _demoteMember(ClanService clanService, String userId) async {
    final result = await clanService.demoteMember(userId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membro rebaixado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao rebaixar membro')),
      );
    }
  }

  Future<void> _kickMember(ClanService clanService, String userId) async {
    final result = await clanService.kickMember(userId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membro expulso com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao expulsar membro')),
      );
    }
  }

  Future<void> _transferLeadership(ClanService clanService, String userId) async {
    final result = await clanService.transferLeadership(userId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liderança transferida com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao transferir liderança')),
      );
    }
  }

  Future<void> _createRole(
    ClanService clanService, {
    required String name,
    required String color,
    required RolePermissions permissions,
  }) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome do cargo é obrigatório')),
      );
      return;
    }

    final result = await clanService.createCustomRole(
      name: name,
      color: color,
      permissions: permissions,
    );

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargo criado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao criar cargo')),
      );
    }
  }

  Future<void> _deleteRole(ClanService clanService, int roleIndex) async {
    // Implementar
  }

  Future<void> _assignRole(ClanService clanService, String userId, String role) async {
    final result = await clanService.assignRole(
      userId: userId,
      role: role,
    );

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargo atribuído com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao atribuir cargo')),
      );
    }
  }

  Future<void> _removeRole(ClanService clanService, String userId) async {
    final result = await clanService.removeRole(userId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargo removido com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao remover cargo')),
      );
    }
  }

  Future<void> _addAlly(ClanService clanService, String clanId) async {
    final result = await clanService.addAlly(clanId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aliado adicionado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao adicionar aliado')),
      );
    }
  }

  Future<void> _addEnemy(ClanService clanService, String clanId) async {
    final result = await clanService.addEnemy(clanId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inimigo adicionado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao adicionar inimigo')),
      );
    }
  }

  Future<void> _removeAlly(ClanService clanService, String clanId) async {
    final result = await clanService.removeAlly(clanId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aliado removido com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao remover aliado')),
      );
    }
  }

  Future<void> _removeEnemy(ClanService clanService, String clanId) async {
    final result = await clanService.removeEnemy(clanId);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inimigo removido com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao remover inimigo')),
      );
    }
  }

  Future<void> _deleteClan(ClanService clanService) async {
    final result = await clanService.deleteClan();

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clã deletado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clanService.error ?? 'Erro ao deletar clã')),
      );
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _getRolePermissionsText(RolePermissions permissions) {
    final List<String> permissionsList = [];
    
    if (permissions.manageMembers) permissionsList.add('Gerenciar Membros');
    if (permissions.manageChannels) permissionsList.add('Gerenciar Canais');
    if (permissions.manageRoles) permissionsList.add('Gerenciar Cargos');
    if (permissions.kickMembers) permissionsList.add('Expulsar Membros');
    if (permissions.muteMembers) permissionsList.add('Mutar Membros');
    
    return permissionsList.isEmpty
        ? 'Sem permissões especiais'
        : permissionsList.join(', ');
  }

  @override
  void dispose() {
    _clanNameController.dispose();
    _clanTagController.dispose();
    _clanDescriptionController.dispose();
    super.dispose();
  }
}

