package com.example.lucasbeatsfederacao

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.lucasbeatsfederacao/voip"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeVoip" -> {
                    // Inicializar configurações VOIP específicas do Android
                    result.success("VOIP initialized")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

