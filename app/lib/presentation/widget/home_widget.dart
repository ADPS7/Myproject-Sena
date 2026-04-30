import 'package:flutter/material.dart';
import 'package:app/presentation/widget/login_widget.dart';
import 'register_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Fondo Gris Sólido (Consistente)
      body: Stack(
        children: [
          // --- DECORACIÓN GEOMÉTRICA MINIMALISTA ---
          
          // Rectángulo superior rotado
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.15,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: size.width * 0.8,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),

          // Línea decorativa inferior
          Positioned(
            bottom: 60,
            left: -20,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 150,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    
                    // Logo de la Institución
                    Container(
                      height: size.height * 0.18,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/instituto-removebg-preview.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Tarjeta Principal de Bienvenida
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Edullinas',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Gestión académica moderna.\nTodo lo que necesitas en un solo lugar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Botonera
                    _buildButton(
                      context, 
                      title: 'Iniciar Sesión', 
                      isPrimary: true,
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const LoginView())
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildButton(
                      context, 
                      title: 'Crear cuenta', 
                      isPrimary: false,
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const RegisterView())
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Footer minimalista
                    TextButton(
                      onPressed: () {}, 
                      child: const Text(
                        'Términos y Condiciones',
                        style: TextStyle(
                          color: Color(0xFF94A3B8), 
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botón optimizado para el nuevo estilo
  Widget _buildButton(BuildContext context, {required String title, required bool isPrimary, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF7C4DFF) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
          ),
        ),
        child: Text(
          title, 
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}