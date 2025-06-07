// lib/models/global_channel_model.dart

class GlobalChannelModel {
  final String id;
  final String name;
  final String? description;
  final String type; // "text" ou "voice"
  final int? userLimit; // Limite de usuários para canais de voz
  final List<String> activeUsers; // IDs dos usuários ativos no canal
  final String createdBy; // ID do usuário que criou o canal
  final DateTime? createdAt;

  GlobalChannelModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.userLimit,
    this.activeUsers = const [],
    required this.createdBy,
    this.createdAt,
  });

  factory GlobalChannelModel.fromJson(Map<String, dynamic> json) {
    return GlobalChannelModel(
      id: json["_id"] ?? json["id"] ?? "",
      name: json["name"] ?? "Canal Sem Nome",
      description: json["description"],
      type: json["type"] ?? "text",
      userLimit: json["userLimit"],
      activeUsers: List<String>.from(json["activeUsers"] ?? []),
      createdBy: json["createdBy"] ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "type": type,
      "userLimit": userLimit,
      "activeUsers": activeUsers,
      "createdBy": createdBy,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}

