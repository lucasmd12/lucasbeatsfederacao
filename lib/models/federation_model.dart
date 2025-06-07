// lib/models/federation_model.dart

import 'package:lucasbeatsfederacao/models/clan_model.dart';
import 'package:lucasbeatsfederacao/models/user_model.dart';

class FederationModel {
  final String id;
  final String name;
  final String? description;
  final String? banner;
  final UserModel leader;
  final List<UserModel> subLeaders;
  final List<ClanModel> clans;
  final String? rules;
  final List<String> allies;
  final List<String> enemies;
  final DateTime? createdAt;

  FederationModel({
    required this.id,
    required this.name,
    this.description,
    this.banner,
    required this.leader,
    this.subLeaders = const [],
    this.clans = const [],
    this.rules,
    this.allies = const [],
    this.enemies = const [],
    this.createdAt,
  });

  factory FederationModel.fromJson(Map<String, dynamic> json) {
    // Processar líder
    final leaderJson = json['leader'] ?? {};
    final UserModel leader = leaderJson is Map
        ? UserModel.fromJson(leaderJson)
        : UserModel(
            id: leaderJson.toString(),
            username: 'Desconhecido',
            email: '',
          );

    // Processar sub-líderes
    List<UserModel> subLeaders = [];
    if (json['subLeaders'] != null) {
      subLeaders = (json['subLeaders'] as List)
          .map((subLeader) => subLeader is Map
              ? UserModel.fromJson(subLeader)
              : UserModel(
                  id: subLeader.toString(),
                  username: 'Desconhecido',
                  email: '',
                ))
          .toList();
    }

    // Processar clãs
    List<ClanModel> clans = [];
    if (json['clans'] != null) {
      clans = (json['clans'] as List).map((clan) {
        if (clan is Map) {
          return ClanModel(
            id: clan['_id'] ?? clan['id'] ?? '',
            name: clan['name'] ?? 'Clã Sem Nome',
            tag: clan['tag'] ?? '',
            leader: clan['leader'] is Map
                ? UserModel.fromJson(clan['leader'])
                : UserModel(
                    id: clan['leader'].toString(),
                    username: 'Desconhecido',
                    email: '',
                  ),
          );
        } else {
          return ClanModel(
            id: clan.toString(),
            name: 'Clã Desconhecido',
            tag: '',
            leader: UserModel(
              id: '',
              username: 'Desconhecido',
              email: '',
            ),
          );
        }
      }).toList();
    }

    // Processar aliados e inimigos
    List<String> allies = [];
    if (json['allies'] != null) {
      allies = (json['allies'] as List)
          .map((ally) => ally is Map ? ally['_id'] ?? ally['id'] : ally.toString())
          .cast<String>()
          .toList();
    }

    List<String> enemies = [];
    if (json['enemies'] != null) {
      enemies = (json['enemies'] as List)
          .map((enemy) => enemy is Map ? enemy['_id'] ?? enemy['id'] : enemy.toString())
          .cast<String>()
          .toList();
    }

    return FederationModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Federação Sem Nome',
      description: json['description'],
      banner: json['banner'],
      leader: leader,
      subLeaders: subLeaders,
      clans: clans,
      rules: json['rules'],
      allies: allies,
      enemies: enemies,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'banner': banner,
      'leader': leader.id,
      'subLeaders': subLeaders.map((subLeader) => subLeader.id).toList(),
      'clans': clans.map((clan) => clan.id).toList(),
      'rules': rules,
      'allies': allies,
      'enemies': enemies,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

