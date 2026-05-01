import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../widget/login_widget.dart';
import 'asiststudent.dart';
import 'NotasEstudiantes.dart';
import 'cursosStudente.dart';
import 'modulostudent.dart';

class StudentHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const StudentHomeScreen({super.key, required this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final ApiService _apiService = ApiService();
  
  // Usamos un Future que puede ser nulo inicialmente para evitar errores de inicialización
  Future<Map<String, dynamic>>? _studentStatsFuture;

  // Colores del tema
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    // Inicializamos la petición al servidor usando el id del usuario logueado
    _studentStatsFuture = _apiService.getStudentStats(widget.user['id_usuario']);
  }

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
              CircleAvatar(
                radius: 45,
                backgroundColor: primaryPurple,
                child: const Icon(Icons.person, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 15),
              Text(widget.user['nombres'] ?? 'Estudiante',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text(widget.user['correo'] ?? "No email",
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("CERRAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PANEL ESTUDIANTE", 
                          style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
                        Text(widget.user['nombres']?.split(' ')[0] ?? 'Hola', 
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _mostrarPerfil(context),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: primaryPurple,
                        child: const Icon(Icons.person_rounded, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Tarjetas de Resumen con Lógica de Cálculo de Promedio
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _studentStatsFuture,
                  builder: (context, snapshot) {
                    String promedio = "0.0";
                    String asistenciaPerc = "--%";
                    String modulosRealizados = "0";
                    bool loading = snapshot.connectionState == ConnectionState.waiting;

                    if (snapshot.hasData && snapshot.data!['success'] == true) {
                      var data = snapshot.data!;
                      
                      // 1. Cálculo de Promedio de Notas (según tabla Notas, columna nota)
                      List notas = data['notas'] ?? [];
                      if (notas.isNotEmpty) {
                        double suma = 0;
                        for (var item in notas) {
                          // Usamos 'nota' para coincidir con tu esquema SQL
                          suma += double.tryParse(item['nota'].toString()) ?? 0.0;
                        }
                        promedio = (suma / notas.length).toStringAsFixed(1);
                      }

                      // 2. Otros datos (asumiendo que los envías desde Python)
                      asistenciaPerc = data['asistencia_porcentaje']?.toString() ?? "--%";
                      modulosRealizados = data['modulos_completados']?.toString() ?? "0";
                    }

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildStatCard("Promedio", promedio, Icons.auto_graph_rounded, loading),
                        const SizedBox(width: 16),
                        _buildStatCard("Asistencias", asistenciaPerc, Icons.calendar_today_rounded, loading),
                        const SizedBox(width: 16),
                        _buildStatCard("Módulos", modulosRealizados, Icons.view_module_rounded, loading),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Menú de Acciones
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text("ACADEMIA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  _buildDashboardItem(Icons.grade_outlined, "Mis Notas", "Calificaciones y retroalimentación", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotasEstudiantesScreen(idAlumno: widget.user['id_usuario'])))),
                  _buildDashboardItem(Icons.how_to_reg_outlined, "Mi Asistencia", "Registro de faltas e ingresos", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen()))),
                  _buildDashboardItem(Icons.library_books_outlined, "Mis Cursos", "Programas en los que estás inscrito", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCourseScreen()))),
                  _buildDashboardItem(Icons.view_module_outlined, "Módulos", "Contenido de estudio disponible", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyModulesScreen()))),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: primaryPurple,
          unselectedItemColor: Colors.grey[400],
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Inicio"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: "Avisos"),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Ajustes"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool loading) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryPurple, size: 20),
          const Spacer(),
          loading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderGrey, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: primaryPurple.withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: primaryPurple, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkBlue)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}