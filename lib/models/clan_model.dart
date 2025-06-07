import 'package:cloud_firestore/cloud_firestore.dart';

class ClanModel {
  final String? id;
  final String? nome;
  final String? descricao;
  final String? lider;
  final List<String> membros;
  final DateTime? criadoEm;
  final bool? ativo;

  ClanModel({
    this.id,
    this.nome,
    this.descricao,
    this.lider,
    required this.membros,
    this.criadoEm,
    this.ativo,
  });

  // Construtor factory do documento Firestore
  factory ClanModel.fromDocument(DocumentSnapshot doc) {
    return ClanModel(
      id: doc.id,
      nome: doc.data()?["nome"],
      descricao: doc.data()?["descricao"],
      lider: doc.data()?["lider"],
      membros: List<String>.from(doc.data()?["membros"] ?? []),
      criadoEm: doc.data()?["criadoEm"]?.toDate(),
      ativo: doc.data()?["ativo"] ?? true,
    );
  }

  // Construtor factory do JSON
  factory ClanModel.fromJson(Map<String, dynamic> json) {
    return ClanModel(
      id: json["id"],
      nome: json["nome"],
      descricao: json["descricao"],
      lider: json["lider"],
      membros: List<String>.from(json["membros"] ?? []),
      criadoEm: json["criadoEm"] != null ? DateTime.parse(json["criadoEm"]) : null,
      ativo: json["ativo"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'lider': lider,
      'membros': membros,
      'criadoEm': criadoEm?.toIso8601String(),
      'ativo': ativo,
    };
  }
}

