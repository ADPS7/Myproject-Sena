import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  late Future<List<dynamic>> _futureCursos;

  @override
  void initState() {
    super.initState();
    _futureCursos = _fetchNotas();
  }

  Future<List<dynamic>> _fetchNotas() async {
    final result = await ApiService().getAdminNotas();
    if (result['success'] == true) {
      return result['cursos'] ?? [];
    }
    throw Exception(result['error'] ?? 'Error al cargar notas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        backgroundColor: const Color.fromARGB(255, 89, 134, 185),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCursos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          final cursos = snapshot.data ?? [];

          if (cursos.isEmpty) {
            return const Center(child: Text('No hay notas disponibles')); 
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cursos.length,
            itemBuilder: (context, indexCurso) {
              final curso = cursos[indexCurso];
              final modulos = (curso['modulos'] as List<dynamic>? ?? []);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  title: Text(curso['nombre'] ?? 'Curso sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${modulos.length} m�dulo(s)'),
                  children: modulos.map<Widget>((modulo) {
                    final estudiantes = (modulo['estudiantes'] as List<dynamic>? ?? []);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        color: const Color(0xffeef2fa),
                        child: ExpansionTile(
                          title: Text(modulo['nombre'] ?? 'M�dulo sin nombre'),
                          subtitle: Text('${estudiantes.length} estudiante(s)'),
                          children: estudiantes.map<Widget>((estudiante) {
                            final notas = (estudiante['notas'] as List<dynamic>? ?? []);
                            final promedio = estudiante['promedio']?.toString() ?? '0';
                            final alerta = estudiante['alerta'] == true;

                            return ListTile(
                              title: Text(estudiante['nombre'] ?? 'Sin nombre'),
                              subtitle: Text('Promedio: $promedio'),
                              trailing: alerta
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.red.shade200, borderRadius: BorderRadius.circular(12)),
                                      child: const Text('RIESGO', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    )
                                  : null,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Notas de ${estudiante['nombre'] ?? 'Estudiante'}'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: notas.map<Widget>((nota) {
                                            final notaValue = nota['nota'];
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Nota'),
                                                Text(
                                                  notaValue.toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: (notaValue is num && notaValue < 3) ? Colors.red : Colors.green,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
