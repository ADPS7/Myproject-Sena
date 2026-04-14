import 'package:app/presentation/view/asiststudent.dart';
import 'package:flutter/material.dart';
import '../widget/login_widget.dart';
import 'NotasEstudiantes.dart';
import 'cursosStudente.dart';
import 'modulostudent.dart';

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

  void _goToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(),
      ),
    );
  }

  void _goToMyCourse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyCourseScreen()),
    );
  }

  void _goToMyModules(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyModulesScreen()));
  }

  void _goToNotes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotasEstudiantesScreen(idAlumno: user['id_usuario']),
      ),
    );
  }

  // NUEVO: Función de Menú Desplegable Estilizado
  void _mostrarPerfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF0A1E3A),
                child: Icon(Icons.school_rounded, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 15),
              Text(
                "${user['nombres'] + ' ' + user['apellidos']}",
                style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF0A1E3A)
                ),
              ),
              Text(
                (user['rol'] ?? 'ESTUDIANTE').toString().toUpperCase(),
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileItem(Icons.email_outlined, "Correo", "${user['correo']}"),
                    Divider(height: 1, color: Colors.grey[100], indent: 70),
                    _buildProfileItem(Icons.badge_outlined, "Rol", "Estudiante"),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1E3A).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF0A1E3A)),
      ),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
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
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // SE MODIFICÓ: El avatar ahora es clicable
                      GestureDetector(
                        onTap: () => _mostrarPerfil(context),
                        child: const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.school_rounded, size: 38, color: Color(0xFFFF8C00)),
                        ),
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
                    GestureDetector(
                      onTap: () => _goToNotes(context),
                      child:  _buildStatCard("Promedio", "4.3", Icons.grade, Colors.green),
                    ),
                    GestureDetector(
                      onTap: () => _goToAttendance(context),
                      child: _buildStatCard("Asistencia", "94%", Icons.how_to_reg, Colors.blue),
                    ),
                    GestureDetector(
                      onTap: () => _goToMyCourse(context),
                      child: _buildStatCard("Cursos", "1", Icons.book, Colors.purple),
                    ),
                    GestureDetector(
                      onTap: () => _goToMyModules(context),
                      child: _buildStatCard("Módulos", "14", Icons.grid_view, Colors.orange),
                    ),
                  ],
                ),
              ]),
            ),
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