import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Image/Banner
          Image.asset(
            'assets/images/backgrounds/loading_background.png', // Using the new background image as a banner example
            fit: BoxFit.cover,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo à FEDERACAOMAD!',
                  style: textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aqui você encontra tudo para a comunicação e organização do seu clã. Explore as abas para gerenciar membros, missões e conversar com outros jogadores.',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Text(
                  'Destaques:',
                  style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Example of a list of features
                _buildFeatureItem(context, Icons.group, 'Gerenciamento de Clãs', 'Organize seus membros e suas funções.'),
                _buildFeatureItem(context, Icons.assignment, 'Missões e Tarefas', 'Acompanhe o progresso e as recompensas.'),
                _buildFeatureItem(context, Icons.chat, 'Chat Global e do Clã', 'Comunique-se com todos ou apenas com seu clã.'),
                _buildFeatureItem(context, Icons.settings, 'Configurações Personalizadas', 'Ajuste o aplicativo ao seu gosto.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


