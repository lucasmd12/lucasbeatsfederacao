import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String username;
  final String? nome;
  final String? telefone;
  final String? token;
  final bool? isOnline;
  final DateTime? lastSeen;
  final List<String>? contatos;

  UserModel({
    this.id,
    required this.username,
    this.nome,
    this.telefone,
    this.token,
    this.isOnline,
    this.lastSeen,
    this.contatos,
  });

  // Construtor nomeado para criar instância a partir do Firestore
  UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        username = doc.data()?['username'] ?? '',
        nome = doc.data()?['nome'],
        telefone = doc.data()?['telefone'],
        token = doc.data()?['token'],
        isOnline = doc.data()?['isOnline'],
        lastSeen = doc.data()?['lastSeen']?.toDate(),
        contatos = List<String>.from(doc.data()?['contatos'] ?? []);

  // Construtor nomeado para criar instância a partir de JSON
  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'] ?? '',
        nome = json['nome'],
        telefone = json['telefone'],
        token = json['token'],
        isOnline = json['isOnline'],
        lastSeen = json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
        contatos = List<String>.from(json['contatos'] ?? []);

  // Método para converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'nome': nome,
      'telefone': telefone,
      'token': token,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'contatos': contatos ?? [],
    };
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nome': nome,
      'telefone': telefone,
      'token': token,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'contatos': contatos ?? [],
    };
  }

  // Método copyWith para atualizações
  UserModel copyWith({
    String? id,
    String? username,
    String? nome,
    String? telefone,
    String? token,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? contatos,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      token: token ?? this.token,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      contatos: contatos ?? this.contatos,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, nome: $nome, telefone: $telefone, isOnline: $isOnline)';
  }
}

