import 'package:flutter/material.dart';
import '../widget/login_widget.dart';
import 'asiststudent.dart';
import 'NotasEstudiantes.dart';
import 'cursosStudente.dart';
import 'modulostudent.dart';

class StudentHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const StudentHomeScreen({super.key, required this.user});

  Widget _buildDashboardItem(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14))]),
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
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Bienvenido,", style: TextStyle(color: Colors.white70)), Text(user['nombres'] ?? 'Estudiante', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))]))),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(delegate: SliverChildListDelegate([
              const Text("Tu tablero", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildDashboardItem(Icons.grade, "Notas", "Ver promedio y calificaciones", Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotasEstudiantesScreen(idAlumno: user['id_usuario'])))),
              _buildDashboardItem(Icons.how_to_reg, "Asistencia", "Consultar historial", Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen()))),
              _buildDashboardItem(Icons.book, "Cursos", "Mis cursos inscritos", Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCourseScreen()))),
              _buildDashboardItem(Icons.grid_view, "Módulos", "Ver contenido", Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyModulesScreen()))),
            ])),
          ),
        ],
      ),
    );
  }
}