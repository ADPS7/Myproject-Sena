import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            snap: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0A1E3A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          "Asistencias Admin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Gestión completa por curso y módulo",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
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
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final cursos = snapshot.data ?? [];
                if (cursos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text("No hay cursos registrados aún"),
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

                    return ExpansionTile(
                      title: Text(
                        curso['nombre'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: (curso['modulos'] as List<dynamic>).map<Widget>((
                        modulo,
                      ) {
                        final estudiantes =
                            modulo['estudiantes'] as List<dynamic>;
                        final int numAlertas = estudiantes
                            .where((e) => e['alerta'] == true)
                            .length;

                        return ExpansionTile(
                          title: Text(
                            modulo['nombre'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${estudiantes.length} estudiantes • $numAlertas con alerta',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          children: estudiantes.map<Widget>((estudiante) {
                            final bool alerta = estudiante['alerta'] ?? false;
                            final int inas = estudiante['inasistencias'] ?? 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        estudiante['nombre'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),

                                    if (!alerta)
                                      Text(
                                        '$inas',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),

                                    const SizedBox(width: 8),

                                    if (alerta)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          '¡ALERTA!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                children:
                                    (estudiante['asistencias'] as List<dynamic>)
                                        .map<Widget>((as) {
                                          final bool asistio =
                                              as['asistio'] == 'SI';
                                          return ListTile(
                                            dense: true,
                                            leading: Icon(
                                              asistio
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: asistio
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            title: Text(
                                              as['fecha'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            trailing: Text(
                                              asistio ? 'SI' : 'NO',
                                              style: TextStyle(
                                                color: asistio
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
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