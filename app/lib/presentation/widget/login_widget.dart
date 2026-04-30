import 'package:app/services/aut_service.dart';
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
  bool _obscureText = true;

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
      await AuthService.saveUser(userData);
      final String rol = userData['rol'].toString().toLowerCase();

      Widget nextScreen;
      
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Fondo Gris Sólido
      body: Stack(
        children: [
          // --- DECORACIÓN GEOMÉTRICA ---
          
          // Rectángulo superior derecho rotado
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.1,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: size.width * 0.7,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),

          // Barra lateral izquierda
          Positioned(
            left: 0,
            top: size.height * 0.3,
            child: Container(
              width: 6,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.network(
                      "https://image2url.com/r2/default/images/1770490852326-698c5fd0-f5e1-48cc-8548-30eb28e1596b.png", 
                      height: 110
                    ),
                    const SizedBox(height: 40),

                    // Tarjeta de Login
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Inicia sesión para continuar",
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                          ),
                          const SizedBox(height: 35),

                          // Inputs Estilo "Outline" Moderno
                          _customInput(
                            controller: emailController,
                            label: "Correo Electrónico",
                            icon: Icons.alternate_email_rounded,
                          ),
                          const SizedBox(height: 20),
                          _customInput(
                            controller: passwordController,
                            label: "Contraseña",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFF7C4DFF)),
                              child: const Text("¿Olvidaste tu contraseña?", 
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),

                          const SizedBox(height: 25),

                          _buildLoginButton(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 35),
                    
                    // Enlace a Registro
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "¿No tienes una cuenta? ",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                          children: [
                            TextSpan(
                              text: "Crea una aquí",
                              style: TextStyle(
                                color: Color(0xFF7C4DFF), 
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _customInput({
    required TextEditingController controller, 
    required String label, 
    required IconData icon,
    bool isPassword = false
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      style: const TextStyle(color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF7C4DFF), size: 22),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ) 
          : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : const Text("Ingresar al Portal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}