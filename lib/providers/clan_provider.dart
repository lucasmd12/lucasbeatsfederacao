import 'package:flutter/foundation.dart';
import 'package:lucasbeatsfederacao/models/clan_model.dart';
import 'package:lucasbeatsfederacao/services/clan_service.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:lucasbeatsfederacao/providers/auth_provider.dart'; // Import AuthProvider

class ClanProvider with ChangeNotifier {
  final ClanService _clanService;
  final AuthProvider _authProvider; // Injetar AuthProvider
  
  Clan? _userClan;
  List<Clan> _allClans = [];
  bool _isLoading = false;
  String? _error;

  ClanProvider(this._clanService, this._authProvider); // Construtor que recebe AuthProvider

  // Getters
  Clan? get userClan => _userClan;
  List<Clan> get allClans => _allClans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUserClan => _userClan != null;

  // Load user's clan
  Future<void> loadUserClan() async {
    try {
      _setLoading(true);
      _error = null;
      
      final userId = _authProvider.currentUser?.id; // Obter userId do AuthProvider
      if (userId == null) {
        _logger.warning('loadUserClan: User ID is null. Cannot load user clan.');
        _userClan = null;
        return;
      }

      final clans = await _clanService.getUserClans(userId);
      _userClan = clans.isNotEmpty ? clans.first : null; // Assume user has at most one clan
      Logger.info('User clan loaded: ${_userClan?.name ?? 'None'}');
    } catch (e) {
      _error = 'Error loading user clan: $e';
      Logger.error(_error!);
    } finally {
      _setLoading(false);
    }
  }

  // Load all clans
  Future<void> loadAllClans() async {
    try {
      _setLoading(true);
      _error = null;
      
      _allClans = await _clanService.getAllClans();
      Logger.info('Loaded ${_allClans.length} clans');
    } catch (e) {
      _error = 'Error loading clans: $e';
      Logger.error(_error!);
    } finally {
      _setLoading(false);
    }
  }

  // Create a new clan
  Future<bool> createClan(String name, String description) async {
    try {
      _setLoading(true);
      _error = null;
      
      final userId = _authProvider.currentUser?.id;
      if (userId == null) {
        _logger.warning('createClan: User ID is null. Cannot create clan.');
        _error = 'User not authenticated.';
        return false;
      }

      final newClan = Clan(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Gerar um ID simples
        name: name,
        description: description,
        members: [userId],
        ownerId: userId,
        createdAt: DateTime.now(),
      );

      final success = await _clanService.createClan(newClan);
      
      if (success) {
        await loadUserClan(); // Reload user clan
        await loadAllClans(); // Reload all clans
        Logger.info('Clan created successfully: $name');
      }
      
      return success;
    } catch (e) {
      _error = 'Error creating clan: $e';
      Logger.error(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Join a clan
  Future<bool> joinClan(String clanId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final userId = _authProvider.currentUser?.id;
      if (userId == null) {
        _logger.warning('joinClan: User ID is null. Cannot join clan.');
        _error = 'User not authenticated.';
        return false;
      }

      final success = await _clanService.joinClan(clanId, userId);
      
      if (success) {
        await loadUserClan(); // Reload user clan
        Logger.info('Joined clan successfully');
      }
      
      return success;
    } catch (e) {
      _error = 'Error joining clan: $e';
      Logger.error(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Leave clan
  Future<bool> leaveClan() async {
    try {
      _setLoading(true);
      _error = null;
      
      final userId = _authProvider.currentUser?.id;
      if (userId == null) {
        _logger.warning('leaveClan: User ID is null. Cannot leave clan.');
        _error = 'User not authenticated.';
        return false;
      }

      final clanId = _userClan?.id;
      if (clanId == null) {
        _logger.warning('leaveClan: User is not in a clan. No clan to leave.');
        _error = 'User is not in a clan.';
        return false;
      }

      final success = await _clanService.leaveClan(clanId, userId);
      
      if (success) {
        _userClan = null; // Clear user clan
        Logger.info('Left clan successfully');
      }
      
      return success;
    } catch (e) {
      _error = 'Error leaving clan: $e';
      Logger.error(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update clan
  Future<bool> updateClan(Clan clan) async {
    try {
      _setLoading(true);
      _error = null;
      
      final success = await _clanService.updateClan(clan);
      
      if (success) {
        await loadUserClan(); // Reload user clan
        await loadAllClans(); // Reload all clans
        Logger.info('Clan updated successfully');
      }
      
      return success;
    } catch (e) {
      _error = 'Error updating clan: $e';
      Logger.error(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete clan
  Future<bool> deleteClan(String clanId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final success = await _clanService.deleteClan(clanId);
      
      if (success) {
        _userClan = null; // Clear user clan if it was deleted
        await loadAllClans(); // Reload all clans
        Logger.info('Clan deleted successfully');
      }
      
      return success;
    } catch (e) {
      _error = 'Error deleting clan: $e';
      Logger.error(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search clans
  Future<List<Clan>> searchClans(String query) async {
    try {
      _setLoading(true);
      _error = null;
      
      final results = await _clanService.searchClans(query);
      Logger.info('Found ${results.length} clans matching "$query"');
      
      return results;
    } catch (e) {
      _error = 'Error searching clans: $e';
      Logger.error(_error!);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await Future.wait([
      loadUserClan(),
      loadAllClans(),
    ]);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}


