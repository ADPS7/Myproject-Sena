import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'asistenciaView.dart'; 
// IMPORTANTE: Asegúrate de que el nombre del archivo sea el correcto
import 'historialAsistenciaProfesor.dart';

class MisCursosView extends StatefulWidget {
  final Map<String, dynamic> user;
  const MisCursosView({super.key, required this.user});

  @override
  State<MisCursosView> createState() => _MisCursosViewState();
}

class _MisCursosViewState extends State<MisCursosView> {
  final ApiService _apiService = ApiService();

  void _mostrarModulos(BuildContext context, int idCurso, String nombreCurso) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
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
              const SizedBox(height: 20),
              Text(
                "Módulos de $nombreCurso",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0D1A63),
                ),
              ),
              const SizedBox(height: 15),
              FutureBuilder<List<dynamic>>(
                future: _apiService.getModulosPorCurso(idCurso),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final modulos = snapshot.data ?? [];
                  if (modulos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Sin módulos registrados."),
                    );
                  }

                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: modulos.length,
                      itemBuilder: (context, index) {
                        final modulo = modulos[index];
                        return Card(
                          elevation: 0,
                          color: Colors.grey[50],
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: ExpansionTile(
                            leading: const Icon(Icons.book, color: Color(0xff0D1A63)),
                            title: Text(
                              modulo['nombre'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                child: Row(
                                  children: [
                                    // BOTÓN VER HISTORIAL (Redirección directa)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context); // Cierra el modal
                                          
                                          // NAVEGACIÓN A LA VISTA QUE ME PASASTE
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HistorialAsistenciaView(
                                                idUsuario: widget.user['id_usuario'], 
                                                nombreAlumno: "${widget.user['nombres']} ${widget.user['apellidos']}",
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.history, size: 18),
                                        label: const Text("VER"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xff0D1A63),
                                          side: const BorderSide(color: Color(0xff0D1A63)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // BOTÓN GUARDAR ASISTENCIA
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context); 
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MarcarAsistenciaView(
                                                idModulo: modulo['id_modulo'],
                                                nombreModulo: modulo['nombre'],
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.check_circle_outline, size: 18),
                                        label: const Text("GUARDAR"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xffFFC107),
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
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
      appBar: AppBar(
        title: const Text("Mis Cursos"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getCursosPorProfesor(widget.user['id_usuario']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cursos = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final curso = cursos[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const Icon(Icons.school, size: 40, color: Color(0xffFFC107)),
                  title: Text(
                    curso['nombre'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _mostrarModulos(context, curso['id_curso'], curso['nombre']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}