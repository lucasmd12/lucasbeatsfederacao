// lib/services/global_channel_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lucasbeatsfederacao/models/global_channel_model.dart';
import 'package:lucasbeatsfederacao/services/auth_service.dart';
import 'package:lucasbeatsfederacao/utils/constants.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';

class GlobalChannelService extends ChangeNotifier {
  final AuthService _authService;
  List<GlobalChannelModel> _textChannels = [];
  List<GlobalChannelModel> _voiceChannels = [];
  bool _isLoading = false;
  String? _error;

  GlobalChannelService(this._authService);

  List<GlobalChannelModel> get textChannels => _textChannels;
  List<GlobalChannelModel> get voiceChannels => _voiceChannels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGlobalChannels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token == null) {
        _error = "Não autenticado";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Buscar canais de texto
      final textResponse = await http.get(
        Uri.parse('$backendBaseUrl/api/global-channels/text'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Buscar canais de voz
      final voiceResponse = await http.get(
        Uri.parse('$backendBaseUrl/api/global-channels/voice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (textResponse.statusCode == 200) {
        final List<dynamic> textData = json.decode(textResponse.body);
        _textChannels = textData
            .map((channel) => GlobalChannelModel.fromJson(channel))
            .toList();
      } else {
        Logger.error(
            'Erro ao buscar canais de texto: ${textResponse.statusCode}');
        _error = "Erro ao buscar canais de texto";
      }

      if (voiceResponse.statusCode == 200) {
        final List<dynamic> voiceData = json.decode(voiceResponse.body);
        _voiceChannels = voiceData
            .map((channel) => GlobalChannelModel.fromJson(channel))
            .toList();
      } else {
        Logger.error(
            'Erro ao buscar canais de voz: ${voiceResponse.statusCode}');
        _error = "Erro ao buscar canais de voz";
      }
    } catch (e) {
      Logger.error('Erro ao buscar canais globais: $e');
      _error = "Erro ao buscar canais: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<GlobalChannelModel?> createGlobalChannel({
    required String name,
    String? description,
    required String type,
    int? userLimit,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        _error = "Não autenticado";
        notifyListeners();
        return null;
      }

      final response = await http.post(
        Uri.parse('$backendBaseUrl/api/global-channels'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'type': type,
          'userLimit': userLimit,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final channelData = json.decode(response.body);
        final newChannel = GlobalChannelModel.fromJson(channelData);
        
        if (type == 'text') {
          _textChannels.add(newChannel);
        } else if (type == 'voice') {
          _voiceChannels.add(newChannel);
        }
        
        notifyListeners();
        return newChannel;
      } else {
        Logger.error(
            'Erro ao criar canal global: ${response.statusCode} - ${response.body}');
        _error = "Erro ao criar canal";
        notifyListeners();
        return null;
      }
    } catch (e) {
      Logger.error('Erro ao criar canal global: $e');
      _error = "Erro ao criar canal: $e";
      notifyListeners();
      return null;
    }
  }

  Future<bool> joinVoiceChannel(String channelId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        _error = "Não autenticado";
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse('$backendBaseUrl/api/global-channels/$channelId/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final channelData = json.decode(response.body);
        final updatedChannel = GlobalChannelModel.fromJson(channelData);
        
        // Atualizar o canal na lista
        final index = _voiceChannels.indexWhere((c) => c.id == channelId);
        if (index != -1) {
          _voiceChannels[index] = updatedChannel;
          notifyListeners();
        }
        
        return true;
      } else {
        Logger.error(
            'Erro ao entrar no canal de voz: ${response.statusCode} - ${response.body}');
        _error = "Erro ao entrar no canal de voz";
        notifyListeners();
        return false;
      }
    } catch (e) {
      Logger.error('Erro ao entrar no canal de voz: $e');
      _error = "Erro ao entrar no canal de voz: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveVoiceChannel(String channelId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        _error = "Não autenticado";
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse('$backendBaseUrl/api/global-channels/$channelId/leave'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final channelData = json.decode(response.body);
        final updatedChannel = GlobalChannelModel.fromJson(channelData);
        
        // Atualizar o canal na lista
        final index = _voiceChannels.indexWhere((c) => c.id == channelId);
        if (index != -1) {
          _voiceChannels[index] = updatedChannel;
          notifyListeners();
        }
        
        return true;
      } else {
        Logger.error(
            'Erro ao sair do canal de voz: ${response.statusCode} - ${response.body}');
        _error = "Erro ao sair do canal de voz";
        notifyListeners();
        return false;
      }
    } catch (e) {
      Logger.error('Erro ao sair do canal de voz: $e');
      _error = "Erro ao sair do canal de voz: $e";
      notifyListeners();
      return false;
    }
  }
}

