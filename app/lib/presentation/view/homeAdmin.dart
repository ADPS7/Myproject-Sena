import 'package:flutter/material.dart';

class Homeadmin extends StatelessWidget {
  const Homeadmin({super.key});

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
                "Información del Perfil",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff0D1A63)),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.person, color: Color(0xff0D1A63)),
                title: Text("Nombre completo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("Administrador Principal", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const ListTile(
                leading: Icon(Icons.email, color: Color(0xff0D1A63)),
                title: Text("Correo electrónico", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("admin@llinasiano.edu.co", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const ListTile(
                leading: Icon(Icons.cake, color: Color(0xff0D1A63)),
                title: Text("Fecha de nacimiento", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("10 de Marzo de 1995", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFC107),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Cambiar Contraseña", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
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
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(100),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bienvenido,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text("Administrador", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _mostrarPerfil(context),
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.shield, color: Color.fromARGB(255, 221, 127, 3), size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildLegacyContainer(Icons.school, "Gestión de Cursos"),
            const SizedBox(height: 20),
            _buildLegacyContainer(Icons.person, "Gestión de Usuarios"),
            const SizedBox(height: 20),
            _buildLegacyContainer(Icons.view_module, "Gestión de Módulos"),
            const SizedBox(height: 20),
            _buildLegacyContainer(Icons.assignment_turned_in, "Gestión de Asistencias"),
            const Padding(
              padding: EdgeInsets.all(30.0),
              child: Text("Contenido del Dashboard", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyContainer(IconData icono, String texto) {
    return Container(
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
    );
  }
}