import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/clan_model.dart';

class ClanList extends StatelessWidget {
  final List<ClanModel> clans;

  const ClanList({Key? key, required this.clans}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
              child: const Text('Entrar'),
            ),
          ),
        );
      },
    );
  }
}


