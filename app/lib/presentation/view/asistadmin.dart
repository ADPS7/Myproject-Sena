import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  Future<List<dynamic>> _fetchAdminData() async {
    final result = await ApiService().getAdminAsistencias();
    if (result['success'] == true) {
      return result['cursos'] ?? [];
    } else {
      throw Exception(result['error'] ?? 'Error al cargar datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF7C4DFF); // Morado vibrante
    const Color darkBg = Color(0xFF1A202C);      // Azul oscuro profundo

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: accentColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentColor, Color(0xFF6200EE)],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reportes de",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        "Asistencias",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchAdminData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator(color: accentColor)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[300], size: 60),
                          const SizedBox(height: 16),
                          Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                final cursos = snapshot.data ?? [];
                if (cursos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: Text("No hay cursos registrados", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: cursos.length,
                  itemBuilder: (context, index) {
                    final curso = cursos[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: ExpansionTile(
                        shape: const Border(),
                        iconColor: accentColor,
                        title: Text(
                          curso['nombre'],
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkBg),
                        ),
                        children: (curso['modulos'] as List<dynamic>).map<Widget>((modulo) {
                          final estudiantes = modulo['estudiantes'] as List<dynamic>;
                          final int numAlertas = estudiantes.where((e) => e['alerta'] == true).length;

                          return Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(modulo['nombre'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              subtitle: Text(
                                '${estudiantes.length} alumnos • $numAlertas alertas',
                                style: TextStyle(color: numAlertas > 0 ? Colors.orange[700] : Colors.grey[500], fontSize: 13),
                              ),
                              children: estudiantes.map<Widget>((estudiante) {
                                final bool alerta = estudiante['alerta'] ?? false;
                                final int inas = estudiante['inasistencias'] ?? 0;

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ExpansionTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(estudiante['nombre'], 
                                            style: TextStyle(fontWeight: FontWeight.bold, color: darkBg, fontSize: 14)),
                                        ),
                                        if (alerta)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                                            child: const Text('ALERTA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        else
                                          Text('$inas inasist.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                    children: (estudiante['asistencias'] as List<dynamic>).map<Widget>((as) {
                                      final bool asistio = as['asistio'] == 'SI';
                                      return ListTile(
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        leading: Icon(asistio ? Icons.check_circle_rounded : Icons.cancel_rounded, 
                                          color: asistio ? Colors.green : Colors.red, size: 18),
                                        title: Text(as['fecha'], style: const TextStyle(fontSize: 13)),
                                        trailing: Text(asistio ? 'Presente' : 'Ausente', 
                                          style: TextStyle(color: asistio ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}