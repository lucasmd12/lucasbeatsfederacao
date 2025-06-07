// lib/services/federation_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:lucasbeatsfederacao/models/user_model.dart';
// CORREÇÃO: Usar caminhos de pacote para todos os imports
import 'package:lucasbeatsfederacao/models/federation_model.dart';
import 'package:lucasbeatsfederacao/models/clan_model.dart';
import 'package:lucasbeatsfederacao/models/role_model.dart';
import 'package:lucasbeatsfederacao/services/api_service.dart'; // Corrigido para package path
import 'package:lucasbeatsfederacao/services/auth_service.dart'; // Corrigido para package path
// Logger não é usado neste arquivo, então não precisa importar

class FederationService {
  final ApiService _apiService;
  final AuthService _authService;

  FederationService(this._apiService, this._authService);

  Future<Federation?> getFederationDetails(String federationId) async {
    try {
      final response = await _apiService.get('federations/$federationId');
      if (response != null) {
        return Federation.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching federation details: $e');
    }
    return null;
  }

  Future<Clan?> createClan(String federationId, Map<String, dynamic> clanData) async {
    // CORREÇÃO: Garantir que UserModel é reconhecido
    final UserModel? currentUser = _authService.currentUser;
    final Federation? federation = await getFederationDetails(federationId);

    if (currentUser == null || federation == null || currentUser.id != federation.adminUserId) {
       debugPrint('Permission Denied: Only Federation Admin (${federation?.adminUserId}) can create clans. Current user ID: ${currentUser?.id}');
       return null;
    }

    if (!federation.canAddClan()) {
      debugPrint('Cannot create clan: Federation max clan limit reached.');
      return null;
    }

    try {
      final response = await _apiService.post('federations/$federationId/clans', clanData);
      if (response != null) {
        return Clan.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error creating clan: $e');
    }
    return null;
  }

  Future<bool> deleteClan(String federationId, String clanId) async {
    final UserModel? currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.id != 'idcloned') { // Replace 'idcloned' if needed
       debugPrint('Permission Denied: Only Federation Admin can delete clans.');
       return false;
    }

    try {
      final success = await _apiService.delete('federations/$federationId/clans/$clanId');
      return success;
    } catch (e) {
      debugPrint('Error deleting clan: $e');
      return false;
    }
  }

  Future<bool> assignClanLeader(String federationId, String clanId, String userId) async {
    final UserModel? currentUser = _authService.currentUser;
     if (currentUser == null || currentUser.id != 'idcloned') { // Replace 'idcloned' if needed
       debugPrint('Permission Denied: Only Federation Admin can assign clan leaders.');
       return false;
    }

    try {
      final response = await _apiService.put(
        'federations/$federationId/clans/$clanId/assign-leader',
        {'userId': userId}
      );
      return response != null;
    } catch (e) {
      debugPrint('Error assigning clan leader: $e');
      return false;
    }
  }
}

