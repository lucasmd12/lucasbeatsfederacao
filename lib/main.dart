import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';

// Import Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/call_page.dart';
import 'screens/clan_management_screen.dart';

// Import Services, Providers and Models
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/federation_service.dart';
import 'services/clan_service.dart';
import 'services/socket_service.dart';
import 'services/chat_service.dart';
import 'services/signaling_service.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/call_provider.dart';
import 'utils/logger.dart';
import 'utils/theme_constants.dart';
import 'widgets/app_lifecycle_reactor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Logger.info("App Initialization Started.");

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Logger.info('Screen orientation set to portrait.');
  } catch (e, stackTrace) {
    Logger.error('Failed to set screen orientation', error: e, stackTrace: stackTrace);
  }

  // Play initial sounds
  final player = AudioPlayer();
  try {
    await player.play(AssetSource('audio/gun_sound_effect.mp3'));
    await player.play(AssetSource('audio/splash_screen_sound.mp3'));
    Logger.info('Initial sounds played.');
  } catch (e) {
    Logger.error('Error playing initial sounds', error: e);
  }

  Logger.info("Running FEDERACAOMAD App.");
  runApp(const FEDERACAOMADApp());
}

class FEDERACAOMADApp extends StatelessWidget {
  const FEDERACAOMADApp({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.info("Building FEDERACAOMADApp Widget.");

    final apiService = ApiService();
    final authService = AuthService();
    final socketService = SocketService(authService);
    final signalingService = SignalingService(socketService);
    final federationService = FederationService(apiService, authService);
    final clanService = ClanService(apiService, authService);
    final chatService = ChatService();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<SocketService>.value(value: socketService),
        ChangeNotifierProvider<SignalingService>.value(value: signalingService),
        Provider<FederationService>.value(value: federationService),
        Provider<ClanService>.value(value: clanService),
        ChangeNotifierProvider<ChatService>.value(value: chatService),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<SocketService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CallProvider(
            authService: context.read<AuthService>(),
            socketService: context.read<SocketService>(),
            signalingService: context.read<SignalingService>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
      ],
      child: AppLifecycleReactor(
        child: MaterialApp(
          title: 'FEDERACAOMAD',
          debugShowCheckedModeBanner: false,
          theme: ThemeConstants.darkTheme,
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.authStatus == AuthStatus.unknown) {
                return const SplashScreen();
              } else if (authProvider.authStatus == AuthStatus.authenticated) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/call': (context) => const CallPage(),
            '/clan-management': (context) {
              final clanId = ModalRoute.of(context)?.settings.arguments as String?;
              if (clanId != null) {
                return ClanManagementScreen(clanId: clanId);
              } else {
                return Scaffold(appBar: AppBar(title: const Text('Erro')), body: const Center(child: Text('ID do Clã não fornecido.')));
              }
            },
          },
        ),
      ),
    );
  }
}


