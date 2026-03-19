import 'package:flutter/material.dart';
import '../widget/login_widget.dart';
import 'asistsTeacher.dart'; // 1. IMPORTA TU VISTA DE ASISTENCIA

class HomeTeacher extends StatelessWidget {
  final Map<String, dynamic> user;
  const HomeTeacher({super.key, required this.user});

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
                "Perfil del Docente",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff0D1A63)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.badge, color: Color(0xff0D1A63)),
                title: const Text("Nombre del Instructor", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("${user['nombres']} ${user['apellidos']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xff0D1A63)),
                title: const Text("Correo Institucional", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("${user['correo']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
                            const Text("Panel de Control,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text(
                                user['nombres'] ?? "Docente", 
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _mostrarPerfil(context),
                          child: const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.account_circle, color: Color(0xff0D1A63), size: 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildLegacyContainer(context, Icons.class_, "Gestión de Cursos", () {}),
            const SizedBox(height: 20),
            
            // 2. AQUÍ CONECTAMOS LA VISTA DE ASISTENCIA
            _buildLegacyContainer(context, Icons.group, "Tomar Asistencia", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AsistenciaView()),
              );
            }),

            const SizedBox(height: 20),
            _buildLegacyContainer(context, Icons.assignment, "Calificar Notas", () {}),
            const SizedBox(height: 20),
            _buildLegacyContainer(context, Icons.layers, "Contenido de Módulos", () {}),
            
            const Padding(
              padding: EdgeInsets.all(30.0),
              child: Text(
                "Tablero de Información Académica", 
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. ACTUALIZAMOS EL MÉTODO PARA RECIBIR EL CLIC (onTap)
  Widget _buildLegacyContainer(BuildContext context, IconData icono, String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
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
            Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff333333))),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}