import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/utils/logger.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashScreen extends StatefulWidget {
  final bool showIndicator;
  const SplashScreen({super.key, this.showIndicator = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _gunshotPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  StreamSubscription? _gunshotSubscription;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    Logger.info("SplashScreen initialized. Indicator: ${widget.showIndicator}");

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of one pulse cycle
    )..repeat(reverse: true); // Repeat the animation back and forth

    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _playSplashSoundsSequence();
  }

  Future<void> _playSplashSoundsSequence() async {
    try {
      await _gunshotPlayer.setReleaseMode(ReleaseMode.stop);
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);

      _gunshotSubscription = _gunshotPlayer.onPlayerComplete.listen((event) {
        Logger.info("Gunshot sound completed.");
        _playAmbientSound();
      });

      Logger.info("Playing gunshot sound...");
      await _gunshotPlayer.play(AssetSource('audio/gun_sound_effect.mp3'));
      Logger.info("Gunshot sound playback started.");

    } catch (e, stackTrace) {
      Logger.error("Failed to play gunshot sound", error: e, stackTrace: stackTrace);
      _playAmbientSound();
    }
  }

  Future<void> _playAmbientSound() async {
    try {
      Logger.info("Playing ambient sound...");
      await _ambientPlayer.play(AssetSource('audio/splash_screen_sound.mp3'));
      Logger.info("Ambient sound playback started (looping).");
    } catch (e, stackTrace) {
      Logger.error("Failed to play ambient sound", error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    Logger.info("Disposing SplashScreen audio players.");
    _gunshotSubscription?.cancel();
    _gunshotPlayer.dispose();
    _ambientPlayer.dispose();
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loading_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation, // Apply the animation to the logo
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    Logger.error("Failed to load splash logo", error: error, stackTrace: stackTrace);
                    return Icon(
                      Icons.shield_moon,
                      size: 100,
                      color: Theme.of(context).primaryColor,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'FEDERACAOMAD',
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  color: Colors.white,
                  shadows: [
                     Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Comunicação e organização para o clã',
                style: textTheme.displayMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                   shadows: [
                     Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 2.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 48),
              if (widget.showIndicator)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                )
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}


