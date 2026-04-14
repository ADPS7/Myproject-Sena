import 'package:flutter/material.dart';

import '../widget/login_widget.dart';
import 'asistadmin.dart';

class Homeadmin extends StatelessWidget {
  final Map<String, dynamic> user;
  
  const Homeadmin({super.key, required this.user});

  void _cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  void _goToAssistanceAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAttendanceScreen(),
      ),
    );
  }

void _mostrarPerfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xffF5F6FA), // Color de fondo de la app para consistencia
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra superior estética
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),

              // Avatar grande y nombre
              CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xff0D1A63),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 15),
              Text(
                "${user['nombres'] ?? ''} ${user['apellidos'] ?? ''}",
                style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xff0D1A63)
                ),
              ),
              Text(
                (user['rol'] ?? 'ADMINISTRADOR').toString().toUpperCase(),
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 30),

              // Tarjeta de información
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileItem(
                      Icons.email_outlined, 
                      "Correo Electrónico", 
                      "${user['correo']}"
                    ),
                    Divider(height: 1, color: Colors.grey[100], indent: 70),
                    _buildProfileItem(
                      Icons.fingerprint, 
                      "Rol", 
                      "Administrador"
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Botón de Cerrar Sesión Estilizado
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _cerrarSesion(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text("CERRAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Widget auxiliar para los items del perfil
  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xff0D1A63).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xff0D1A63)),
      ),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xff0D1A63),
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Bienvenido,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text(
                              "${user['nombres'] + ' ' + user['apellidos']}", 
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _mostrarPerfil(context),
                          child: const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.admin_panel_settings, color: Color(0xff0D1A63), size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildActionCard(Icons.book, "Cursos"),
            const SizedBox(height: 20),
            _buildActionCard(Icons.view_module, "Módulos"),
            const SizedBox(height: 20),
            _buildActionCard(Icons.people_alt, "Usuarios"),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _goToAssistanceAdmin(context),
              child: _buildActionCard(Icons.fact_check, "Asistencias"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icono, String texto) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff0D1A63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: const Color(0xff0D1A63), size: 30),
          ),
          const SizedBox(width: 20),
          Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}