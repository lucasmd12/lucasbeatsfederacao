import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clan_model.dart';
import '../services/logger_service.dart';
import '../models/chat_channel_model.dart';

class ClanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  Future<List<ClanModel>> getUserClans(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('clans')
          .where('members', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => ClanModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _logger.logError('Error getting user clans: $e');
      return [];
    }
  }

  Future<ClanModel?> getClan(String clanId) async {
    try {
      final doc = await _firestore.collection('clans').doc(clanId).get();
      if (doc.exists) {
        return ClanModel.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      _logger.logError('Error getting clan: $e');
      return null;
    }
  }

  Future<bool> createClan(ClanModel clan) async {
    try {
      await _firestore.collection('clans').doc(clan.id).set(clan.toJson());
      return true;
    } catch (e) {
      _logger.logError('Error creating clan: $e');
      return false;
    }
  }

  Future<bool> joinClan(String clanId, String userId) async {
    try {
      await _firestore.collection('clans').doc(clanId).update({
        'members': FieldValue.arrayUnion([userId])
      });
      return true;
    } catch (e) {
      _logger.logError('Error joining clan: $e');
      return false;
    }
  }

  Future<bool> leaveClan(String clanId, String userId) async {
    try {
      await _firestore.collection('clans').doc(clanId).update({
        'members': FieldValue.arrayRemove([userId])
      });
      return true;
    } catch (e) {
      _logger.logError('Error leaving clan: $e');
      return false;
    }
  }

  Future<List<ClanModel>> getAllClans() async {
    try {
      final snapshot = await _firestore.collection("clans").get();
      return snapshot.docs
          .map((doc) => ClanModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _logger.logError("Error getting all clans: $e");
      return [];
    }
  }

  Future<bool> updateClan(ClanModel clan) async {
    try {
      await _firestore.collection("clans").doc(clan.id).update(clan.toJson());
      return true;
    } catch (e) {
      _logger.logError("Error updating clan: $e");
      return false;
    }
  }

  Future<bool> deleteClan(String clanId) async {
    try {
      await _firestore.collection("clans").doc(clanId).delete();
      return true;
    } catch (e) {
      _logger.logError("Error deleting clan: $e");
      return false;
    }
  }

  Future<List<ClanModel>> searchClans(String query) async {
    try {
      final snapshot = await _firestore
          .collection("clans")
          .where("name", isGreaterThanOrEqualTo: query)
          .where("name", isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs
          .map((doc) => ClanModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _logger.logError("Error searching clans: $e");
      return [];
    }
  }
}

