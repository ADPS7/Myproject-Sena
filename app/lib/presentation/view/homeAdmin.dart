import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../widget/login_widget.dart';
import 'asistadmin.dart';
import 'cursoAdmin.dart';
import 'modulosAdmin.dart';

class Homeadmin extends StatefulWidget {
  final Map<String, dynamic> user;

  const Homeadmin({
    super.key,
    required this.user,
  });

  @override
  State<Homeadmin> createState() => _HomeadminState();
}

class _HomeadminState extends State<Homeadmin> {
  final ApiService _apiService = ApiService();
  
  // Guardamos el Future en una variable para evitar que se dispare 
  // múltiples veces innecesariamente al reconstruir la UI.
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos iniciales de edullinas
    _statsFuture = _apiService.obtenerDatosCardAdmin();
  }

  // Función para refrescar los datos desde la base de datos
  void _refreshData() {
    setState(() {
      _statsFuture = _apiService.obtenerDatosCardAdmin();
    });
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
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFF7C4DFF),
                child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 15),
              Text(widget.user['nombres'] ?? 'Administrador',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
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
            ],
          ),
        );
      },
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
            // Header con nombre de usuario
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Panel Admin", style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(widget.user['nombres']?.split(' ')[0] ?? 'Admin', 
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
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

            // Tarjetas de Estadísticas Dinámicas
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    bool loading = snapshot.connectionState == ConnectionState.waiting;
                    String cursos = "0";
                    String usuarios = "0";

                    if (snapshot.hasData && snapshot.data!['success'] == true) {
                      cursos = snapshot.data!['totalCursos'].toString();
                      usuarios = snapshot.data!['totalUsuarios'].toString();
                    }

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildStatCard("Cursos", cursos, Icons.book_rounded, loading),
                        const SizedBox(width: 16),
                        _buildStatCard("Usuarios", usuarios, Icons.people_rounded, loading),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Menú de Opciones
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text("ACCIONES PRINCIPALES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 16),
                  
                  _buildDashboardItem(Icons.auto_stories_outlined, "Gestionar Cursos", "Crea y edita programas", 
                    () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const CursosScreen()));
                      _refreshData(); // Al volver, pedimos los datos nuevos
                    }
                  ),
                  
                  _buildDashboardItem(Icons.account_tree_outlined, "Módulos Educativos", "Estructura de contenidos", 
                    () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulosScreen()));
                      _refreshData();
                    }
                  ),
                  
                  _buildDashboardItem(Icons.fact_check_outlined, "Asistencias", "Reportes generales", 
                    () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAttendanceScreen()));
                      _refreshData();
                    }
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets de apoyo dentro de la clase para mantener el estado
  Widget _buildStatCard(String label, String value, IconData icon, bool loading) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7C4DFF), size: 20),
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
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: const Color(0xFF7C4DFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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