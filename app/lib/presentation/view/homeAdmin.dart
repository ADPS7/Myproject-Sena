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

  // Componente de tarjeta reutilizable (Igual al de estudiante)
  Widget _buildDashboardItem(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            backgroundColor: const Color(0xFF0A1E3A),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Panel Administrativo", style: TextStyle(color: Colors.white70)),
                      Text(
                        user['nombres'] ?? 'Administrador',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("Gestión Global", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildDashboardItem(Icons.book, "Cursos", "Administrar oferta académica", Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CursosScreen()))),
                _buildDashboardItem(Icons.view_module, "Módulos", "Administrar contenidos", Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulosScreen()))),
                _buildDashboardItem(Icons.people_alt, "Usuarios", "Gestionar cuentas", Colors.orange, () {}),
                _buildDashboardItem(Icons.fact_check, "Asistencias", "Reportes de asistencia", Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAttendanceScreen()))),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => _cerrarSesion(context),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}