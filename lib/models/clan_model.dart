import 'package:cloud_firestore/cloud_firestore.dart';

class ClanModel {
  final String? id;
  final String nome;
  final String? descricao;
  final String? lider;
  final List<String> membros;
  final DateTime? criadoEm;
  final bool? ativo;

  ClanModel({
    this.id,
    required this.nome,
    this.descricao,
    this.lider,
    this.membros = const [],
    this.criadoEm,
    this.ativo = true,
  });

  // Construtor a partir do Firestore
  ClanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        nome = doc.data()?["nome"] ?? "";
        descricao = doc.data()?["descricao"],
        lider = doc.data()?["lider"],
        membros = List<String>.from(doc.data()?["membros"] ?? []),
        criadoEm = doc.data()?["criadoEm"]?.toDate(),
        ativo = doc.data()?["ativo"] ?? true;

  // Construtor a partir de JSON
  ClanModel.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        nome = json["nome"] ?? "";
        descricao = json["descricao"],
        lider = json["lider"],
        membros = List<String>.from(json["membros"] ?? []),
        criadoEm = json["criadoEm"] != null ? DateTime.parse(json["criadoEm"]) : null,
        ativo = json["ativo"] ?? true;

  // Converter para Map
  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "descricao": descricao,
      "lider": lider,
      "membros": membros,
      "criadoEm": criadoEm != null ? Timestamp.fromDate(criadoEm!) : null,
      "ativo": ativo,
    };
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "descricao": descricao,
      "lider": lider,
      "membros": membros,
      "criadoEm": criadoEm?.toIso8601String(),
      "ativo": ativo,
    };
  }

  // Método copyWith
  ClanModel copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? lider,
    List<String>? membros,
    DateTime? criadoEm,
    bool? ativo,
  }) {
    return ClanModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      lider: lider ?? this.lider,
      membros: membros ?? this.membros,
      criadoEm: criadoEm ?? this.criadoEm,
      ativo: ativo ?? this.ativo,
    );
  }
}

