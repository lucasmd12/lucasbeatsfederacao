import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _usuarios = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Buscar todos os usuários
  Future<void> buscarUsuarios() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore.collection('usuarios').get();
      
      _usuarios = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao buscar usuários: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar novo usuário
  Future<bool> criarUsuario(UserModel usuario) async {
    try {
      await _firestore.collection('usuarios').add(usuario.toMap());
      await buscarUsuarios(); // Atualizar lista
      return true;
    } catch (e) {
      _error = 'Erro ao criar usuário: $e';
      notifyListeners();
      return false;
    }
  }

  // Atualizar usuário
  Future<bool> atualizarUsuario(String id, UserModel usuario) async {
    try {
      await _firestore.collection('usuarios').doc(id).update(usuario.toMap());
      await buscarUsuarios(); // Atualizar lista
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar usuário: $e';
      notifyListeners();
      return false;
    }
  }

  // Limpar erro
  void limparError() {
    _error = null;
    notifyListeners();
  }
}

