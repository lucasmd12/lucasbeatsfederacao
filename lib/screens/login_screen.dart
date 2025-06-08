import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      Logger.info('Attempting login for: ${_usernameController.text}');

      bool success = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        Logger.info('Login successful via AuthService for user: ${authService.currentUser?.username}');
      } else {
        if (mounted) {
           CustomSnackbar.showError(context, 'Falha no login. Verifique suas credenciais.');
        }
      }
    } catch (e) {
      Logger.error('Login Screen Error', error: e);
      if (mounted) {
        CustomSnackbar.showError(context, 'Erro no login: ${e.toString().replaceFirst("Exception: ", "")}"');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePasswordReset() async {
     final username = _usernameController.text.trim();
     if (username.isEmpty) {
       CustomSnackbar.showError(context, 'Digite seu nome de usuário para solicitar a redefinição.');
       return;
     }
     Logger.warning("Password Reset functionality not implemented yet.");
     CustomSnackbar.showInfo(context, 'Funcionalidade de redefinição de senha ainda não implementada.');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/loading_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.shield_moon,
                          size: 80,
                          color: Color(0xFF9147FF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'FEDERACAOMAD',
                        textAlign: TextAlign.center,
                        style: textTheme.displayLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 48),

                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Gothic'),
                        decoration: InputDecoration(
                          labelText: 'Usuário',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome de usuário';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Gothic'),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('ENTRAR'),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _isLoading ? null : _handlePasswordReset,
                            child: const Text('Esqueceu a senha?', style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text('Criar conta', style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


