import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mission_model.dart';

class MissionsTab extends StatelessWidget {
  const MissionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    // Simulated mission data
    final List<MissionModel> missions = [
      MissionModel(
        id: 'm1',
        title: 'Coletar Recursos Raros',
        description: 'Encontre e colete 50 unidades de minério raro na Zona de Perigo.',
        createdBy: 'Líder Alpha',
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        status: 'in_progress',
        assignedTo: ['Membro Beta', 'Membro Gamma'],
        dueDate: DateTime.now().add(const Duration(days: 7)),
        reward: 500,
      ),
      MissionModel(
        id: 'm2',
        title: 'Derrotar Chefe da Facção',
        description: 'Elimine o Chefe da Facção na Fortaleza Abandonada.',
        createdBy: 'Líder Alpha',
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        status: 'completed',
        assignedTo: ['Membro Alpha'],
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        reward: 1500,
      ),
      MissionModel(
        id: 'm3',
        title: 'Explorar Setor Desconhecido',
        description: 'Mapeie o Setor 7 e identifique pontos de interesse.',
        createdBy: 'Líder Beta',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        status: 'pending',
        assignedTo: [],
        dueDate: DateTime.now().add(const Duration(days: 14)),
        reward: 750,
      ),
    ];

    if (missions.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma missão disponível no momento.',
          style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        final dateFormat = DateFormat('dd/MM/yyyy');

        Color statusColor;
        switch (mission.status) {
          case 'in_progress':
            statusColor = Colors.blueAccent;
            break;
          case 'completed':
            statusColor = Colors.green;
            break;
          case 'pending':
            statusColor = Colors.orange;
            break;
          default:
            statusColor = Colors.grey;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: theme.cardColor,
          child: ListTile(
            title: Text(mission.title, style: textTheme.titleLarge?.copyWith(fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mission.description, style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text('Criado por: ${mission.createdBy}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
                Text('Status: ${mission.status.replaceAll('_', ' ').toUpperCase()}', style: theme.textTheme.bodySmall?.copyWith(color: statusColor)),
                if (mission.dueDate != null)
                  Text('Prazo: ${dateFormat.format(mission.dueDate!)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
                Text('Recompensa: ${mission.reward}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.greenAccent)),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color, size: 16),
            onTap: () {
              // TODO: Implement navigation to mission detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detalhes da missão: ${mission.title}')),
              );
            },
          ),
        );
      },
    );
  }
}


