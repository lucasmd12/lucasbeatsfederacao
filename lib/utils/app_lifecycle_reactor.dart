import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/logger.dart';

class AppLifecycleReactor extends StatefulWidget {
  final Widget child;

  const AppLifecycleReactor({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _AppLifecycleReactorState createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _onAppResumed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  void _onAppResumed() {
    Logger.info('App resumed');
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        // Reconectar serviços quando o app volta ao foco
        _reconnectServices();
      }
    } catch (e) {
      Logger.error('Error on app resumed: $e');
    }
  }

  void _onAppPaused() {
    Logger.info('App paused');
    try {
      // Pausar serviços quando o app vai para background
      _pauseServices();
    } catch (e) {
      Logger.error('Error on app paused: $e');
    }
  }

  void _onAppInactive() {
    Logger.info('App inactive');
  }

  void _onAppDetached() {
    Logger.info('App detached');
    try {
      // Limpar recursos quando o app é finalizado
      _cleanupServices();
    } catch (e) {
      Logger.error('Error on app detached: $e');
    }
  }

  void _onAppHidden() {
    Logger.info('App hidden');
  }

  Future<void> _reconnectServices() async {
    try {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.reconnect();
    } catch (e) {
      Logger.error('Error reconnecting services: $e');
    }
  }

  void _pauseServices() {
    try {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.pause();
    } catch (e) {
      Logger.error('Error pausing services: $e');
    }
  }

  void _cleanupServices() {
    try {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.cleanup();
    } catch (e) {
      Logger.error('Error cleaning up services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
