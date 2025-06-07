import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'LucaBeatsFederacao';

  void log(String message) {
    if (kDebugMode) {
      print('[$_tag] $message');
    }
  }

  void logError(String error) {
    if (kDebugMode) {
      print('[$_tag] ERROR: $error');
    }
  }

  void logWarning(String warning) {
    if (kDebugMode) {
      print('[$_tag] WARNING: $warning');
    }
  }

  void logInfo(String info) {
    if (kDebugMode) {
      print('[$_tag] INFO: $info');
    }
  }
}

