class ChatChannelModel {
  final String id;
  final String name;
  final String? description;
  final String type;
  final DateTime createdAt;
  final List<String> members;

  ChatChannelModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.createdAt,
    required this.members,
  });

  factory ChatChannelModel.fromMap(Map<String, dynamic> map) {
    return ChatChannelModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      type: map['type'] ?? 'text',
      createdAt: (map['createdAt']).toDate(),
      members: List<String>.from(map['members'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'createdAt': createdAt,
      'members': members,
    };
  }
}

