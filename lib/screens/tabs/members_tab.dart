import 'package:flutter/material.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final List<Map<String, String>> members = [
      {
        'name': 'Membro Alpha',
        'role': 'Líder',
        'status': 'Online',
        'avatar': 'assets/images/app_logo.png'
      },
      {
        'name': 'Membro Beta',
        'role': 'Oficial',
        'status': 'Offline',
        'avatar': 'assets/images/app_logo.png'
      },
      {
        'name': 'Membro Gamma',
        'role': 'Recruta',
        'status': 'Online',
        'avatar': 'assets/images/app_logo.png'
      },
      {
        'name': 'Membro Delta',
        'role': 'Oficial',
        'status': 'Ausente',
        'avatar': 'assets/images/app_logo.png'
      },
      {
        'name': 'Membro Epsilon',
        'role': 'Recruta',
        'status': 'Online',
        'avatar': 'assets/images/app_logo.png'
      },
    ];

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Theme.of(context).cardColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(member['avatar']!),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            title: Text(member['name']!, style: textTheme.titleLarge?.copyWith(fontSize: 16)),
            subtitle: Text('${member['role']} - ${member['status']}', style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).iconTheme.color, size: 16),
            onTap: () {
              // TODO: Implement navigation to member detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detalhes de ${member['name']}')), 
              );
            },
          ),
        );
      },
    );
  }
}


