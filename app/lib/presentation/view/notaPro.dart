import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotasProfesorView extends StatefulWidget {
  final int idUsuario; // ID del profesor

  const NotasProfesorView({super.key, required this.idUsuario});

  @override
  State<NotasProfesorView> createState() => _NotasProfesorViewState();
}

class _NotasProfesorViewState extends State<NotasProfesorView> {
  final ApiService _api = ApiService();

  Future<List<dynamic>>? _futureCursos;

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  void _cargarCursos() {
    setState(() {
      _futureCursos = _api.getCursosPorProfesor(widget.idUsuario);
    });
  }

  Future<List<dynamic>> _getModulos(int idCurso) async {
    return await _api.getModulosPorCurso(idCurso);
  }

  Future<List<dynamic>> _getEstudiantes(int idModulo) async {
    return await _api.getEstudiantesPorModulo(idModulo);
  }

  void _mostrarDialogoNota(Map estudiante, int idModulo) {
    final TextEditingController controller = TextEditingController(
      text: estudiante['nota']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nota - ${estudiante['nombres']} ${estudiante['apellidos']}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Ej: 4.5"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              
              Navigator.pop(context);
              setState(() {}); // recarga la vista para mostrar la nota actualizada
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cursos & Notas"),
        backgroundColor: const Color(0xff0D1A63),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCursos,
        builder: (context, snapshotCursos) {
          if (!snapshotCursos.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cursos = snapshotCursos.data!;
          if (cursos.isEmpty) {
            return const Center(child: Text("No tienes cursos asignados."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cursos.length,
            itemBuilder: (context, indexCurso) {
              final curso = cursos[indexCurso];

              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.school, color: Color(0xffFFC107)),
                  title: Text(
                    curso['nombre'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    FutureBuilder<List<dynamic>>(
                      future: _getModulos(curso['id_curso']),
                      builder: (context, snapshotModulos) {
                        if (!snapshotModulos.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final modulos = snapshotModulos.data!;
                        if (modulos.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("No hay módulos en este curso."),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: modulos.length,
                          itemBuilder: (context, indexModulo) {
                            final modulo = modulos[indexModulo];

                            return Card(
                              color: Colors.grey[50],
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ExpansionTile(
                                leading: const Icon(Icons.book, color: Color(0xff0D1A63)),
                                title: Text(
                                  modulo['nombre'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  FutureBuilder<List<dynamic>>(
                                    future: _getEstudiantes(modulo['id_modulo']),
                                    builder: (context, snapshotEstudiantes) {
                                      if (!snapshotEstudiantes.hasData) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      final estudiantes = snapshotEstudiantes.data!;
                                      if (estudiantes.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text("No hay estudiantes en este módulo."),
                                        );
                                      }

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: estudiantes.length,
                                        itemBuilder: (context, indexEstudiante) {
                                          final est = estudiantes[indexEstudiante];

                                          return ListTile(
                                            leading: const Icon(Icons.person),
                                            title: Text("${est['nombres']} ${est['apellidos']}"),
                                            subtitle: Text(est['correo']),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () => _mostrarDialogoNota(est, modulo['id_modulo']),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}