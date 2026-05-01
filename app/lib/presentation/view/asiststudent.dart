import 'package:app/services/aut_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  // Paleta de colores del patrón
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  Future<Map<String, dynamic>> _fetchAsistencias() async {
    final userId = await AuthService.getUserId();
    if (userId == null) throw Exception('Usuario no encontrado');

    final response = await http.get(
      Uri.parse('http://192.168.101.79:5000/asistencias/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) throw Exception('Error al cargar asistencias');

    final data = json.decode(response.body);
    final List<dynamic> asistencias = data['asistencias'] ?? [];

    if (asistencias.isEmpty) {
      return {'curso': 'Sin curso registrado', 'modulos': <String, List<dynamic>>{}};
    }

    String cursoNombre = asistencias.first['curso_nombre'] ?? 'Curso actual';
    final Map<String, List<dynamic>> modulos = {};

    for (var item in asistencias) {
      final String modulo = item['modulo_nombre'] ?? 'Módulo sin nombre';
      modulos.putIfAbsent(modulo, () => []);
      modulos[modulo]!.add(item);
    }

    modulos.forEach((_, lista) {
      lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    });

    return {'curso': cursoNombre, 'modulos': modulos};
  }

  String _limpiarModulo(String nombre) {
    final regex = RegExp(r'^(Módulo|Modulo)\s*\d+\s*[-:]\s*', caseSensitive: false);
    return nombre.replaceFirst(regex, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchAsistencias(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryPurple));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
            }

            final data = snapshot.data!;
            final String curso = data['curso'];
            final Map<String, List<dynamic>> modulos = data['modulos'];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header siguiendo el patrón
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
                        Text("REGISTRO DIARIO", 
                          style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text(curso, 
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text("Control de asistencias por módulo", 
                          style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Lista de Módulos
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: modulos.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text("No hay registros disponibles")),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final String moduloKey = modulos.keys.elementAt(index);
                              final List<dynamic> registros = modulos[moduloKey]!;
                              
                              // Calcular porcentaje de asistencia simple
                              int presentes = registros.where((r) => r['asistio'] == 'SI').length;
                              double porcentaje = (presentes / registros.length) * 100;

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
                                        color: primaryPurple.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.event_available_rounded, color: primaryPurple, size: 22),
                                    ),
                                    title: Text(
                                      _limpiarModulo(moduloKey),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlue),
                                    ),
                                    subtitle: Text(
                                      "${registros.length} días registrados • ${porcentaje.toStringAsFixed(0)}%",
                                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                    ),
                                    children: [
                                      const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9)),
                                      ...registros.map((item) {
                                        final bool asistio = item['asistio'] == 'SI';
                                        return ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                                          title: Text(item['fecha'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                          trailing: Icon(
                                            asistio ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                            color: asistio ? const Color(0xFF10B981) : Colors.redAccent,
                                            size: 20,
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