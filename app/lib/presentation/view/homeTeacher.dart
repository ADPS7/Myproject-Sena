import 'package:app/presentation/view/notaPro.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../widget/login_widget.dart';
import 'AjustesScreen.dart';
import 'asistsTeacher.dart';
import 'cursosteacher.dart';

class HomeTeacher extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeTeacher({super.key, required this.user});

  @override
  State<HomeTeacher> createState() => _HomeTeacherState();
}

class _HomeTeacherState extends State<HomeTeacher> {
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  final ApiService _apiService = ApiService();

  late Future<List<dynamic>> _cursosFuture;
  late Future<int> _totalAlumnosFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _cursosFuture = _apiService.getCursosPorProfesor(
        widget.user['id_usuario'],
      );
      _totalAlumnosFuture = _obtenerTotalAlumnos();
    });
  }

  Future<int> _obtenerTotalAlumnos() async {
    try {
      final cursos = await _apiService.getCursosPorProfesor(
        widget.user['id_usuario'],
      );
      int total = 0;

      for (var curso in cursos) {
        final estudiantes = await _apiService.getEstudiantesPorCurso(
          curso['id_curso'],
        );
        total += estudiantes.length;
      }
      return total;
    } catch (e) {
      print("Error obteniendo total de alumnos: $e");
      return 0;
    }
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
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 45,
                backgroundColor: primaryPurple,
                child: const Icon(Icons.person, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 15),
              Text(
                "${widget.user['nombres'] ?? ''} ${widget.user['apellidos'] ?? ''}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.user['correo'] ?? "No email",
                style: TextStyle(color: Colors.grey[600]),
              ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "CERRAR SESIÓN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    bool isLoading = false,
  }) {
    return Container(
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
          isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
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
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: primaryPurple, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: darkBlue,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _cargarDatos(),
          color: primaryPurple,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                          Text(
                            "PANEL INSTRUCTOR",
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            widget.user['nombres']?.split(' ')[0] ?? 'Hola',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _mostrarPerfil(context),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: primaryPurple,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tarjetas de Resumen
              SliverToBoxAdapter(
                child: Container(
                  height: 130,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Cursos
                      FutureBuilder<List<dynamic>>(
                        future: _cursosFuture,
                        builder: (context, snapshot) {
                          String total = "0";
                          bool loading =
                              snapshot.connectionState ==
                              ConnectionState.waiting;
                          if (snapshot.hasData)
                            total = snapshot.data!.length.toString();
                          return SizedBox(
                            width: 155,
                            child: _buildStatCard(
                              "Cursos",
                              total,
                              Icons.school_rounded,
                              isLoading: loading,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),

                      // Alumnos
                      FutureBuilder<int>(
                        future: _totalAlumnosFuture,
                        builder: (context, snapshot) {
                          String total = "0";
                          bool loading =
                              snapshot.connectionState ==
                              ConnectionState.waiting;
                          if (snapshot.hasData)
                            total = snapshot.data.toString();
                          return SizedBox(
                            width: 155,
                            child: _buildStatCard(
                              "Alumnos",
                              total,
                              Icons.people_outline_rounded,
                              isLoading: loading,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),

              // Acciones principales (con recarga automática)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      "GESTIÓN ACADÉMICA",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDashboardItem(
                      Icons.book_outlined,
                      "Mis Cursos",
                      "Gestiona tus fichas y grupos",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyCoursesTeacherScreen(user: widget.user),
                        ),
                      ).then((_) => _cargarDatos()),
                    ),

                    _buildDashboardItem(
                      Icons.assignment_turned_in_outlined,
                      "Calificar Notas",
                      "Registro de evaluaciones",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotasProfesorView(
                            idUsuario: widget.user['id_usuario'] ?? 0,
                          ),
                        ),
                      ).then((_) => _cargarDatos()),
                    ),

                    _buildDashboardItem(
                      Icons.fact_check_outlined,
                      "Control de Asistencia",
                      "Reporte de faltas y retardos",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AsistsTeacher(
                            idUsuario: widget.user['id_usuario'] ?? 0,
                          ),
                        ),
                      ).then((_) => _cargarDatos()),
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        backgroundColor: Colors.white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.grey[400],
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AjustesScreen(user: widget.user),
              ),
            ).then((_) => _cargarDatos());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Ajustes",
          ),
        ],
      ),
    );
  }
}
