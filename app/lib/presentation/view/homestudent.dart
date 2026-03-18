import 'package:app/presentation/view/asiststudent.dart';
import 'package:flutter/material.dart';

import '../widget/login_widget.dart';


class StudentHomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const StudentHomeScreen({super.key, required this.user});

  void _cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  // Función para navegar a la pantalla de asistencias
  void _goToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String studentName = "${user['nombres']} ${user['apellidos']}";

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A1E3A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Bienvenido,", style: TextStyle(color: Colors.white70, fontSize: 18)),
                              Text(
                                user['nombres'] ?? 'Estudiante',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.school_rounded, size: 38, color: Color(0xFFFF8C00)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      "Tu tablero",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: [
                        _buildStatCard("Promedio", "4.3", Icons.grade, Colors.green),
                        
                        // ← TARJETA DE ASISTENCIA CLICABLE
                        GestureDetector(
                          onTap: () => _goToAttendance(context),
                          child: _buildStatCard(
                            "Asistencia",
                            "94%",
                            Icons.how_to_reg,
                            Colors.blue,
                          ),
                        ),

                        _buildStatCard("Cursos", "6", Icons.book, Colors.purple),
                        _buildStatCard("Módulos", "14", Icons.grid_view, Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 30),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _cerrarSesion(context),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.red, fontSize: 16)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}