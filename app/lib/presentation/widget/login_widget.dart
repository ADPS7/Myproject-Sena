import 'package:flutter/material.dart';
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

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa los campos')),
      );
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
      final String rol = userData['rol'].toString().toLowerCase();

      Widget nextScreen;
      
      // Aquí ocurre la redirección por rol
      if (rol == 'admin') {
        nextScreen = Homeadmin(user: userData);
      } else if (rol == 'estudiante') {
        nextScreen = StudentHomeScreen(user: userData);
      } else if (rol == 'profesor') {
        nextScreen = HomeTeacher(user: userData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Rol no reconocido')),
        );
        return;
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Error de credenciales')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  Image.network("https://image2url.com/r2/default/images/1770490852326-698c5fd0-f5e1-48cc-8548-30eb28e1596b.png", height: 140),
                  const Text("¡Hola de Nuevo!", style: TextStyle(fontSize: 34, color: Color(0xff0D1A63), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  _customInput(controller: emailController, hint: "Email"),
                  const SizedBox(height: 10),
                  _customInput(controller: passwordController, hint: "Contraseña", isPassword: true),
                  const SizedBox(height: 20),
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
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Iniciar Sesión"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}