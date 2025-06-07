import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'usuarios';

  // Criar usuário
  Future<String?> criarUsuario(UserModel usuario) async {
    try {
      final docRef = await _firestore.collection(_collection).add(usuario.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  // Buscar usuário por ID
  Future<UserModel?> buscarUsuarioPorId(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  // Buscar usuário por username
  Future<UserModel?> buscarUsuarioPorUsername(String username) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário por username: $e');
    }
  }

  // Listar todos os usuários
  Future<List<UserModel>> listarUsuarios() async {
    try {
      final query = await _firestore.collection(_collection).get();
      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erro ao listar usuários: $e');
    }
  }

  // Atualizar usuário
  Future<void> atualizarUsuario(String id, UserModel usuario) async {
    try {
      await _firestore.collection(_collection).doc(id).update(usuario.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }
}

