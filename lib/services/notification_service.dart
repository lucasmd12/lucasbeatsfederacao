import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import '../utils/logger.dart';
import './permission_service.dart';
import './api_service.dart';
import './auth_service.dart';

// Background message handling needs a completely different mechanism
// if not using Firebase Messaging (e.g., background fetch, workmanager with API calls).
// This placeholder function will not be called without FCM.
// @pragma("vm:entry-point")
// Future<void> _backgroundMessageHandler(Map<String, dynamic> message) async {
//   Logger.info("Handling a background message (Non-FCM): $message");
// }

class NotificationService {
  // PermissionService only has static methods, no instance needed.
  final ApiService _apiService; // Inject ApiService
  final AuthService _authService; // Inject AuthService

  // Subscriptions for alternative notification mechanisms (e.g., WebSockets) would go here
  // StreamSubscription? _notificationSubscription;

  NotificationService(this._apiService, this._authService);

  /// Initializes the service, requests permissions.
  Future<void> initialize() async {
    Logger.info("Initializing NotificationService (Non-FCM)...");

    // 1. Solicitar Permissão (iOS, Web e Android 13+)
    bool permissionGranted = await _requestNotificationPermissions();
    if (!permissionGranted) {
      Logger.warning("Notification permission not granted.");
    }

    // 2. Setup alternative notification mechanism (e.g., connect WebSocket)
    await _setupPushTokenAndListener(); // Placeholder

    Logger.info("NotificationService initialized (Non-FCM).");
  }

  /// Solicita permissão para receber notificações.
  Future<bool> _requestNotificationPermissions() async {
    // Corrected static call
    bool notificationPermission = await PermissionService.requestNotificationPermission();
    if (notificationPermission) {
      Logger.info("Notification permission granted.");
      return true;
    } else {
      Logger.warning("Notification permission denied.");
      return false;
    }
  }

  /// Placeholder: Gets a device token (if needed for another service) and saves it via API.
  Future<void> _setupPushTokenAndListener() async {
    // Corrected: Get user ID directly from AuthService.currentUser
    final String? userId = _authService.currentUser?.id;
    if (userId == null) {
      Logger.warning("Cannot setup push token: User not logged in.");
      return;
    }

    try {
      // --- Placeholder: Get token from a non-FCM service ---
      // String? token = await getNonFcmPushToken(); // e.g., APNS, custom
      String? token = "placeholder_non_fcm_token"; // Example

      // Simplified token logging based on analysis feedback
      final String tokenLog = token == null
          ? "null"
          : (token.length > 15 ? "${token.substring(0, 15)}..." : token);
      Logger.info("Non-FCM Push Token: $tokenLog");

      // Check token is not null before proceeding (Analyzer might warn if using placeholder, but keep for real usage)
      if (token != null) {
        await _saveTokenToBackend(token, userId);
      }

      // --- Placeholder: Listen for notifications from the alternative service ---
      // _notificationSubscription = listenForNonFcmNotifications().listen((message) {
      //   Logger.info("Foreground message received (Non-FCM)!");
      //   _handleDataPayload(message.data);
      // }, onError: (error) {
      //   Logger.error("Error listening to non-FCM notifications", error: error);
      // });

    } catch (e, s) {
      Logger.error("Error setting up non-FCM push token/listener", error: e, stackTrace: s);
    }
  }

  /// Placeholder: Saves the push token to your backend via API.
  Future<void> _saveTokenToBackend(String token, String userId) async {
    try {
      // Example API endpoint: POST /api/users/{userId}/push-tokens
      await _apiService.post(
        "/api/users/$userId/push-tokens",
        {"token": token, "type": _getDeviceType()}, // Send token and device type
      );
      Logger.info("Push token saved to backend for user $userId.");
    } catch (e, s) {
      Logger.error("Error saving push token to backend", error: e, stackTrace: s);
    }
  }

  String _getDeviceType() {
    if (kIsWeb) return "web";
    // Use defaultTargetPlatform from flutter/foundation.dart
    final TargetPlatform platform = defaultTargetPlatform;
    if (platform == TargetPlatform.android) return "android";
    if (platform == TargetPlatform.iOS) return "ios";
    if (platform == TargetPlatform.macOS) return "macos";
    return "unknown";
  }

  // Removed Firebase message handlers (_setupMessageHandlers, _checkForInitialMessage)

  /// Processa o payload de dados de uma notificação (adaptable for non-FCM).
  // Marked as unused for now, as listener is commented out
  // ignore: unused_element
  void _handleDataPayload(Map<String, dynamic> data) {
    Logger.info("Processing data payload: $data");
    if (data["type"] == "incoming_call") {
      final String? channelId = data["channelId"];
      final String? callerName = data["callerName"];
      Logger.info("Incoming call notification for channel $channelId from $callerName");
      // TODO: Trigger incoming call UI
    } else if (data["type"] == "new_message") {
       final String? chatId = data["chatId"];
       Logger.info("New message notification for chat $chatId");
       // TODO: Update chat UI or show badge
    }
    // Add more logic for other notification types
  }

  /// Lida com o toque do usuário em uma notificação (adaptable for non-FCM).
  // Marked as unused for now, as listener is commented out
  // ignore: unused_element
  void _handleNotificationTap(Map<String, dynamic> data) {
    Logger.info("Handling notification tap with data: $data");
    if (data["screen"] == "chat") {
      final String? chatId = data["chatId"];
      Logger.info("Navigate to chat screen: $chatId");
      // TODO: Implement navigation
    } else if (data["screen"] == "channel") {
       final String? channelId = data["channelId"];
       Logger.info("Navigate to channel: $channelId");
       // TODO: Implement navigation or join channel
    }
  }

  /// Cancela as inscrições e limpa recursos.
  void dispose() {
    Logger.info("Disposing NotificationService (Non-FCM)...");
    // _notificationSubscription?.cancel(); // Cancel listener for alternative service
  }
}

