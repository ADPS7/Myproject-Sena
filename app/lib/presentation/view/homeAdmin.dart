import 'package:flutter/material.dart';
import '../widget/login_widget.dart';
import 'asistadmin.dart';
import 'cursoAdmin.dart';
import 'modulosAdmin.dart';

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
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF7C4DFF),
                child: Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 45),
              ),
              const SizedBox(height: 15),
              // Uso de información de usuario basada en el esquema de "edullinas"
              Text(user['nombres'] ?? 'Administrador',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 10),
              Text(user['correo'] ?? "No email",
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _cerrarSesion(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text("CERRAR SESIÓN",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7C4DFF), size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: const Color(0xFF7C4DFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A202C))),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Panel Admin", style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                        Text(user['nombres']?.split(' ')[0] ?? 'Admin', 
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _mostrarPerfil(context),
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF7C4DFF),
                        child: Icon(Icons.person_rounded, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    SizedBox(width: 140, child: _buildStatCard("Cursos", "12", Icons.book_rounded)),
                    const SizedBox(width: 16),
                    SizedBox(width: 140, child: _buildStatCard("Alumnos", "124", Icons.people_rounded)),
                    const SizedBox(width: 16),
                    SizedBox(width: 140, child: _buildStatCard("Módulos", "48", Icons.grid_view_rounded)),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text("ACCIONES PRINCIPALES",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  _buildDashboardItem(Icons.auto_stories_outlined, "Gestionar Cursos", "Crea y edita programas", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CursosScreen()))),
                  _buildDashboardItem(Icons.account_tree_outlined, "Módulos Educativos", "Estructura de contenidos", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulosScreen()))),
                  _buildDashboardItem(Icons.badge_outlined, "Control de Usuarios", "Roles y permisos", () {}),
                  _buildDashboardItem(Icons.fact_check_outlined, "Asistencias", "Reportes generales", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAttendanceScreen()))),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
      
      // Menú inferior simplificado a Inicio, Reportes y Configuración
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF7C4DFF),
          unselectedItemColor: Colors.grey[400],
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Inicio"),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Reportes"),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Configuración"),
          ],
        ),
      ),
    );
  }
}