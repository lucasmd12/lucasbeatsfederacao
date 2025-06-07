class ApiConfig {
  static const String baseUrl = 'https://beckend-ydd1.onrender.com';
  static const String socketUrl = 'wss://beckend-ydd1.onrender.com'; // Se for usar WebSocket futuramente
  static const Duration timeout = Duration(seconds: 10); // Tempo limite padrão para chamadas HTTP
}