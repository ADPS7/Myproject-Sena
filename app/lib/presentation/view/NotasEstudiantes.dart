import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotasEstudiantesScreen extends StatelessWidget {
  final int idAlumno;
  const NotasEstudiantesScreen({
    super.key,
    required this.idAlumno,
  });

  // Paleta de colores del patrón
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  Future<Map<String, dynamic>> _fetchNotas() async {
    final result = await ApiService().getNotasEstudiante(idAlumno);
    if (result['success'] == true) {
      return result;
    } else {
      throw Exception(result['error'] ?? 'Error al cargar datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchNotas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryPurple));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}", 
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
              );
            }

            final data = snapshot.data!;
            final String curso = data['curso'] ?? 'Curso';
            final List<dynamic> modulos = data['modulos'] ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header siguiendo el patrón de los otros
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderGrey),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: darkBlue),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("CALIFICACIONES", 
                          style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text(curso, 
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text("Revisa tu progreso por cada módulo", 
                          style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Lista de Módulos con diseño de tarjetas limpias
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final modulo = modulos[index];
                        final notas = (modulo['notas'] as List<dynamic>)
                            .map((e) => double.parse(e.toString()))
                            .toList();

                        double promedio = 0;
                        if (notas.isNotEmpty) {
                          promedio = notas.reduce((a, b) => a + b) / notas.length;
                        }

                        // Color según desempeño
                        Color statusColor = promedio >= 3.0 ? const Color(0xFF10B981) : Colors.redAccent;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderGrey, width: 1.5),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.book_rounded, color: statusColor, size: 22),
                              ),
                              title: Text(
                                modulo['nombre'],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlue),
                              ),
                              subtitle: Text(
                                notas.isEmpty ? "Sin notas" : "Promedio: ${promedio.toStringAsFixed(1)}",
                                style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              children: [
                                const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9)),
                                ...notas.asMap().entries.map((entry) {
                                  final i = entry.key + 1;
                                  final nota = entry.value;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                                    title: Text("Actividad $i", style: const TextStyle(fontSize: 14)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (nota >= 3.0 ? Colors.green : Colors.red).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        nota.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: nota >= 3.0 ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: modulos.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}