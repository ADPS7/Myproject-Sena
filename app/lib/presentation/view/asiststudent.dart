import 'package:app/services/aut_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  Future<Map<String, dynamic>> _fetchAsistencias() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      throw Exception('Usuario no encontrado');
    }

    final response = await http.get(
      Uri.parse('http://10.2.138.187/asistencias/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cargar asistencias');
    }

    final data = json.decode(response.body);
    final List<dynamic> asistencias = data['asistencias'] ?? [];

    if (asistencias.isEmpty) {
      return {
        'curso': 'Sin curso registrado',
        'modulos': <String, List<dynamic>>{},
      };
    }

    String cursoNombre = asistencias.first['curso_nombre'] ?? 'Curso actual';

    // Agrupar por módulo
    final Map<String, List<dynamic>> modulos = {};

    for (var item in asistencias) {
      final String modulo = item['modulo_nombre'] ?? 'Módulo sin nombre';
      modulos.putIfAbsent(modulo, () => []);
      modulos[modulo]!.add(item);
    }

    // Ordenar por fecha descendente
    modulos.forEach((_, lista) {
      lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    });

    return {
      'curso': cursoNombre,
      'modulos': modulos,
    };
  }

  // Limpiar nombre del módulo
  String _limpiarModulo(String nombre) {
    final regex = RegExp(r'^(Módulo|Modulo)\s*\d+\s*[-:]\s*', caseSensitive: false);
    return nombre.replaceFirst(regex, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAsistencias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final data = snapshot.data!;
          final String curso = data['curso'];
          final Map<String, List<dynamic>> modulos = data['modulos'];

          return CustomScrollView(
            slivers: [
              // ================= HEADER CON CURVATURA =================
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A1E3A),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              curso,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Registro por módulo",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ================= LISTA DE MÓDULOS =================
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: modulos.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "Aún no tienes registros de asistencia",
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final String moduloCompleto =
                                modulos.keys.elementAt(index);
                            final String moduloNombre =
                                _limpiarModulo(moduloCompleto);

                            final List<dynamic> asistencias =
                                modulos[moduloCompleto]!;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  moduloNombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text("${asistencias.length} registros"),
                                children: asistencias.map((item) {
                                  final bool asistio = item['asistio'] == 'SI';
                                  return ListTile(
                                    leading: Icon(
                                      asistio ? Icons.check_circle : Icons.cancel,
                                      color: asistio ? Colors.green : Colors.red,
                                      size: 30,
                                    ),
                                    title: Text(item['fecha']),
                                    trailing: Text(
                                      asistio ? "SI" : "NO",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: asistio ? Colors.green : Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                          childCount: modulos.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}