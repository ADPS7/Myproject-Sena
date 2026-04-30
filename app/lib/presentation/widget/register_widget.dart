import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // ... (Tus controladores y lógica de _selectDate y _registerUser se mantienen igual)
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Fondo Gris Sólido
      body: Stack(
        children: [
          // --- ELEMENTOS GEOMÉTRICOS (En lugar de burbujas) ---
          
          // Rectángulo decorativo superior
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: size.width * 0.8,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),

          // Línea decorativa lateral
          Positioned(
            right: 20,
            top: size.height * 0.2,
            child: Container(
              width: 4,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Image.network(
                    "https://image2url.com/r2/default/images/1770490852326-698c5fd0-f5e1-48cc-8548-30eb28e1596b.png",
                    height: 90,
                  ),
                  const SizedBox(height: 30),

                  // Contenedor Principal (Card)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Crear Cuenta",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Regístrate para acceder a Edullinas",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                        const SizedBox(height: 30),

                        _customInput(hint: "Nombres", controller: nombresController, icon: Icons.person_outline),
                        const SizedBox(height: 15),
                        _customInput(hint: "Apellidos", controller: apellidosController, icon: Icons.badge_outlined),
                        const SizedBox(height: 15),
                        _customInput(hint: "Correo", controller: emailController, icon: Icons.email_outlined),
                        const SizedBox(height: 15),
                        _customInput(
                          hint: "Fecha de Nacimiento", 
                          controller: fechaController, 
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () => {}, // Lógica de fecha aquí
                        ),
                        const SizedBox(height: 15),
                        _customInput(
                          hint: "Contraseña", 
                          controller: passwordController, 
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        const SizedBox(height: 35),

                        // Botón de Registro
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MISMOS HELPERS QUE ANTES (Pero ajustados al nuevo estilo) ---

  Widget _customInput({required String hint, required TextEditingController controller, required IconData icon, bool isPassword = false, bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF7C4DFF)),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureText = !_obscureText)) : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => {}, // Lógica de registro aquí
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Registrarse", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}