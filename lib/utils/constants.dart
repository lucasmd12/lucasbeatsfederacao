import 'package:flutter/material.dart';

// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Lucas Beats Federação';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Plataforma de beats e música da Federação';
  
  // URLs e Endpoints
  static const String baseUrl = 'https://beckend-ydd1.onrender.com';
  static const String socketUrl = 'wss://socket.lucasbeatsfederacao.com';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Uploads
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedAudioFormats = [
    'mp3', 'wav', 'aac', 'm4a', 'flac'
  ];
  static const List<String> allowedImageFormats = [
    'jpg', 'jpeg', 'png', 'webp'
  ];
  
  // Audio Settings
  static const int maxAudioDuration = 300; // 5 minutes in seconds
  static const int sampleRate = 44100;
  static const int bitRate = 320000; // 320 kbps
  
  // Chat Settings
  static const int maxMessageLength = 1000;
  static const int maxChatParticipants = 50;
  
  // Cache Settings
  static const int imageCacheDuration = 7; // days
  static const int audioCacheDuration = 3; // days
}

// lib/core/constants/api_constants.dart
class ApiConstants {
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String deleteAccount = '/user/delete';
  static const String userBeats = '/user/beats';
  
  // Beats Endpoints
  static const String beats = '/beats';
  static const String beatDetails = '/beats/{id}';
  static const String uploadBeat = '/beats/upload';
  static const String downloadBeat = '/beats/{id}/download';
  static const String searchBeats = '/beats/search';
  static const String featuredBeats = '/beats/featured';
  static const String categoriesList = '/beats/categories';
  
  // Chat Endpoints
  static const String chats = '/chats';
  static const String chatDetails = '/chats/{id}';
  static const String createChat = '/chats/create';
  static const String joinChat = '/chats/{id}/join';
  static const String leaveChat = '/chats/{id}/leave';
  static const String chatMessages = '/chats/{id}/messages';
  static const String sendMessage = '/chats/{id}/messages';
  
  // Federation Endpoints
  static const String federations = '/federations';
  static const String joinFederation = '/federations/{id}/join';
  static const String federationMembers = '/federations/{id}/members';
  static const String federationBeats = '/federations/{id}/beats';
  
  // File Endpoints
  static const String uploadFile = '/files/upload';
  static const String downloadFile = '/files/{id}';
  static const String deleteFile = '/files/{id}';
}

// lib/core/constants/asset_constants.dart
class AssetConstants {
  // Images
  static const String imagesPath = 'assets/images/';
  static const String logo = '${imagesPath}logo.png';
  static const String splashLogo = '${imagesPath}splash_logo.png';
  static const String branding = '${imagesPath}branding.png';
  static const String defaultAvatar = '${imagesPath}default_avatar.png';
  static const String musicBackground = '${imagesPath}music_bg.jpg';
  static const String placeholder = '${imagesPath}placeholder.png';
  
  // Icons
  static const String iconsPath = 'assets/icons/';
  static const String appIcon = '${iconsPath}app_icon.png';
  static const String playIcon = '${iconsPath}ic_play.svg';
  static const String pauseIcon = '${iconsPath}ic_pause.svg';
  static const String stopIcon = '${iconsPath}ic_stop.svg';
  static const String micIcon = '${iconsPath}ic_mic.svg';
  static const String sendIcon = '${iconsPath}ic_send.svg';
  static const String attachIcon = '${iconsPath}ic_attach.svg';
  static const String emojiIcon = '${iconsPath}ic_emoji.svg';
  
  // Sounds
  static const String soundsPath = 'assets/sounds/';
  static const String notificationSound = '${soundsPath}notification.mp3';
  static const String messageSentSound = '${soundsPath}message_sent.mp3';
  static const String messageReceivedSound = '${soundsPath}message_received.mp3';
  
  // Lottie Animations
  static const String lottiePath = 'assets/lottie/';
  static const String loadingAnimation = '${lottiePath}loading.json';
  static const String successAnimation = '${lottiePath}success.json';
  static const String errorAnimation = '${lottiePath}error.json';
  static const String musicWaveAnimation = '${lottiePath}music_wave.json';
}

// lib/core/constants/color_constants.dart
class ColorConstants {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3F37C9);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A896);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF666666);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Chat Colors
  static const Color myMessageColor = Color(0xFF6C63FF);
  static const Color otherMessageColor = Color(0xFF2D2D2D);
  static const Color onlineColor = Color(0xFF4CAF50);
  static const Color offlineColor = Color(0xFF666666);
  
  // Audio Player Colors
  static const Color waveformColor = Color(0xFF6C63FF);
  static const Color waveformBackgroundColor = Color(0xFF2D2D2D);
  static const Color progressColor = Color(0xFF03DAC6);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFF6C63FF);
  static const Color buttonSecondary = Color(0xFF2D2D2D);
  static const Color buttonDisabled = Color(0xFF666666);
  
  // Border Colors
  static const Color borderColor = Color(0xFF333333);
  static const Color dividerColor = Color(0xFF2D2D2D);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF3F37C9),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFF121212),
    Color(0xFF1E1E1E),
  ];
}

// lib/core/constants/string_constants.dart
class StringConstants {
  // App Strings
  static const String appName = 'Lucas Beats Federação';
  static const String welcome = 'Bem-vindo à Federação';
  static const String loading = 'Carregando...';
  static const String retry = 'Tentar novamente';
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String save = 'Salvar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String share = 'Compartilhar';
  
  // Auth Strings
  static const String login = 'Entrar';
  static const String register = 'Cadastrar';
  static const String logout = 'Sair';
  static const String username = 'Usuário';
  static const String password = 'Senha';
  static const String confirmPassword = 'Confirmar senha';
  static const String forgotPassword = 'Esqueceu a senha?';
  static const String resetPassword = 'Redefinir senha';
  static const String loginSuccess = 'Login realizado com sucesso!';
  static const String loginError = 'Erro ao fazer login';
  static const String registerSuccess = 'Cadastro realizado com sucesso!';
  static const String registerError = 'Erro ao cadastrar usuário';
  
  // Validation Strings
  static const String usernameRequired = 'Nome de usuário é obrigatório';
  static const String passwordRequired = 'Senha é obrigatória';
  static const String passwordTooShort = 'Senha deve ter pelo menos 6 caracteres';
  static const String passwordsNotMatch = 'Senhas não coincidem';
  static const String invalidCredentials = 'Credenciais inválidas';
  
  // Chat Strings
  static const String chats = 'Conversas';
  static const String newChat = 'Nova conversa';
  static const String typeMessage = 'Digite uma mensagem...';
  static const String sendMessage = 'Enviar mensagem';
  static const String messageDeleted = 'Mensagem deletada';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String typing = 'Digitando...';
  
  // Beats Strings
  static const String beats = 'Beats';
  static const String myBeats = 'Meus Beats';
  static const String uploadBeat = 'Upload de Beat';
  static const String downloadBeat = 'Baixar Beat';
  static const String playBeat = 'Reproduzir';
  static const String pauseBeat = 'Pausar';
  static const String stopBeat = 'Parar';
  static const String beatTitle = 'Título do Beat';
  static const String beatDescription = 'Descrição';
  static const String beatCategory = 'Categoria';
  static const String duration = 'Duração';
  static const String bpm = 'BPM';
  static const String genre = 'Gênero';
  
  // Error Messages
  static const String genericError = 'Ocorreu um erro inesperado';
  static const String networkError = 'Erro de conexão com a internet';
  static const String serverError = 'Erro interno do servidor';
  static const String fileNotFound = 'Arquivo não encontrado';
  static const String fileTooBig = 'Arquivo muito grande';
  static const String invalidFileFormat = 'Formato de arquivo inválido';
  static const String permissionDenied = 'Permissão negada';
  
  // Success Messages
  static const String beatUploaded = 'Beat enviado com sucesso!';
  static const String profileUpdated = 'Perfil atualizado com sucesso!';
  static const String messagesSent = 'Mensagem enviada!';
  
  // Settings
  static const String settings = 'Configurações';
  static const String profile = 'Perfil';
  static const String notifications = 'Notificações';
  static const String privacy = 'Privacidade';
  static const String about = 'Sobre';
  static const String version = 'Versão';
  static const String termsOfUse = 'Termos de Uso';
  static const String privacyPolicy = 'Política de Privacidade';
}

