import 'package:app/services/aut_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../services/api_service.dart';
import '../view/homeAdmin.dart';
import '../view/homeTeacher.dart';
import '../view/homestudent.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Configuración de Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // --- LOGICA DE GOOGLE ---
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => isLoading = true);
      
      // Abre el selector de cuentas del dispositivo
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return; 
      }

      // Enviamos el correo a la base de datos para validar si existe
      final result = await ApiService().loginSocial(correo: googleUser.email);

      if (result['success']) {
        final userData = result['user'];
        await AuthService.saveUser(userData);
        _navigateByRole(userData);
      } else {
        // Si no existe en la BD, cerramos sesión de Google para que pueda reintentar
        await _googleSignIn.signOut();
        _showError(result['error'] ?? 'Este correo no está registrado.');
      }
    } catch (e) {
      _showError("Error al conectar con Google");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- LOGIN TRADICIONAL (Email/Clave) ---
  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError('Por favor, completa los campos');
      return;
    }

    setState(() => isLoading = true);
    final result = await ApiService().login(
      correo: emailController.text.trim(),
      clave: passwordController.text.trim(),
    );
    setState(() => isLoading = false);

    if (result['success']) {
      final userData = result['user'];
      await AuthService.saveUser(userData);
      _navigateByRole(userData);
    } else {
      _showError(result['error'] ?? 'Credenciales incorrectas');
    }
  }

  // --- NAVEGACIÓN SEGÚN ROL ---
  void _navigateByRole(Map<String, dynamic> userData) {
    final String rol = userData['rol'].toString().toLowerCase();
    Widget nextScreen;

    if (rol == 'admin') {
      nextScreen = Homeadmin(user: userData);
    } else if (rol == 'profesor') {
      nextScreen = HomeTeacher(user: userData);
    } else {
      nextScreen = StudentHomeScreen(user: userData);
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffF0FFDF), Color(0xff0F2854)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.network(
                    "https://image2url.com/r2/default/images/1770490852326-698c5fd0-f5e1-48cc-8548-30eb28e1596b.png", 
                    height: 140
                  ),
                  const Text(
                    "¡Hola de Nuevo!", 
                    style: TextStyle(fontSize: 34, color: Color(0xff0D1A63), fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 25),
                  _customInput(controller: emailController, hint: "Email"),
                  const SizedBox(height: 10),
                  _customInput(controller: passwordController, hint: "Contraseña", isPassword: true),
                  const SizedBox(height: 20),
                  
                  // Botón Iniciar Sesión
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FilledButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff0D1A63),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Iniciar Sesión"),
                    ),
                  ),

                  const SizedBox(height: 35),
                  const Text("O inicia sesión con:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 20),
                  
                  // Iconos Sociales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(
                        imagePath: 'assets/images/ico-google.png',
                        onTap: _handleGoogleSignIn, // Aquí activas Google
                      ),
                      const SizedBox(width: 25),
                      _socialIcon(
                        imagePath: 'assets/images/icon-facebook.jpg',
                        onTap: () => _showError("Facebook no disponible aún"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialIcon({required String imagePath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Image.asset(imagePath, height: 35, width: 35),
      ),
    );
  }

  Widget _customInput({required TextEditingController controller, required String hint, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff4988C4),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            contentPadding: const EdgeInsets.only(left: 20),
            hintStyle: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}