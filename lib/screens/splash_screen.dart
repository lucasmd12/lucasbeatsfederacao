import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _gunshotPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _playInitialSounds();
    _controller.forward();
    
    // Navigate after splash screen
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  Future<void> _playInitialSounds() async {
    try {
      // Corrigido: aspas simples fechadas corretamente
      await _ambientPlayer.play(AssetSource('audio/splash_screen_sound.mp3'));
      Logger.info("Ambient sound playback started.");
      
      // Delay before gunshot
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Corrigido: aspas simples fechadas corretamente  
      await _gunshotPlayer.play(AssetSource('audio/gun_sound_effect.mp3'));
      Logger.info("Gunshot sound playback started.");
    } catch (e) {
      Logger.error("Error playing splash sounds: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ambientPlayer.dispose();
    _gunshotPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.scale(
                scale: 0.8 + (_animation.value * 0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // App name
                    const Text(
                      'Lucas Beats Federação',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Loading indicator
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}