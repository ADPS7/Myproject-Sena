import 'package:flutter/material.dart';

import '../widget/login_widget.dart';

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

  void _mostrarPerfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Información de Cuenta",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff0D1A63)),
              ),
              const SizedBox(height: 20),
              
              // Dato: Nombre y Apellido
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xff0D1A63)),
                title: const Text("Nombre Completo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(
                  "${user['nombres'] ?? 'N/A'} ${user['apellidos'] ?? ''}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
              
              // Dato: Correo
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xff0D1A63)),
                title: const Text("Correo Electrónico", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(
                  "${user['correo'] ?? 'Sin correo'}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),

              // Dato: Rol (Base de datos)
              ListTile(
                leading: const Icon(Icons.verified_user, color: Color(0xff0D1A63)),
                title: const Text("Rol de Usuario", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(
                  "${user['rol']?.toUpperCase() ?? 'ADMINISTRADOR'}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("CERRAR SESIÓN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
                              "${user['nombres'] ?? 'Admin'}", 
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
            _buildActionCard(Icons.fact_check, "Asistencias"),
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