import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/logger.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Section: Account
        Text(
          'Conta',
          style: textTheme.headlineSmall?.copyWith(color: theme.primaryColor),
        ),
        const SizedBox(height: 10),
        Card(
          color: theme.cardColor,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person, color: theme.iconTheme.color),
                title: Text('Configurações da Conta', style: textTheme.titleMedium),
                trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navegar para Configurações da Conta')),
                  );
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.lock, color: theme.iconTheme.color),
                title: Text('Privacidade e Segurança', style: textTheme.titleMedium),
                trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navegar para Privacidade e Segurança')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section: App Settings
        Text(
          'Configurações do Aplicativo',
          style: textTheme.headlineSmall?.copyWith(color: theme.primaryColor),
        ),
        const SizedBox(height: 10),
        Card(
          color: theme.cardColor,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.notifications, color: theme.iconTheme.color),
                title: Text('Notificações', style: textTheme.titleMedium),
                trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navegar para Configurações de Notificação')),
                  );
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.palette, color: theme.iconTheme.color),
                title: Text('Tema', style: textTheme.titleMedium),
                trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navegar para Configurações de Tema')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Logout Button
        ElevatedButton(
          onPressed: () async {
            try {
              final authService = Provider.of<AuthService>(context, listen: false);
              Logger.info("Attempting logout via AuthService...");
              await authService.logout();
              Logger.info("Logout successful via AuthService.");
            } catch (e) {
              Logger.error("Error during logout", error: e);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao fazer logout: ${e.toString()}')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent, // Cor de destaque para logout
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}


