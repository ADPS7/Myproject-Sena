// Archivo: cursos_screen.dart
import 'package:flutter/material.dart';

import '../../services/api_service.dart';


class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  final TextEditingController _cursoController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Dialogo para Registrar
  Future<void> _mostrarDialogoNuevoCurso() async {
    _cursoController.clear();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Nuevo Curso"),
        content: TextField(
          controller: _cursoController,
          decoration: const InputDecoration(labelText: "Nombre del curso"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_cursoController.text.isNotEmpty) {
                final result = await _apiService.crearCurso(_cursoController.text);
                if (mounted) {
                  Navigator.pop(context);
                  if (result['success'] == true) {
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
                  }
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // Dialogo para Editar
  void _mostrarDialogoEditarCurso(int id, String nombreActual) {
    TextEditingController editarController = TextEditingController(text: nombreActual);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Curso"),
        content: TextField(controller: editarController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final result = await _apiService.editarCurso(id, editarController.text);
              if (mounted) {
                Navigator.pop(context);
                if (result['success'] == true) {
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'] ?? "Error")));
                }
              }
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  // Dialogo para Eliminar
  void _confirmarEliminar(int id, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Curso"),
        content: Text("¿Estás seguro de eliminar '$nombre'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final result = await _apiService.eliminarCurso(id);
              if (mounted) {
                Navigator.pop(context);
                if (result['success'] == true) {
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
                }
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Gestión de Cursos"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getCursos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay cursos registrados"));
          }

          final cursos = snapshot.data!;
          return ListView.builder(
            itemCount: cursos.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.school, color: Color(0xff0D1A63)),
                  title: Text(cursos[index]['nombre']),
                  subtitle: Text("ID: ${cursos[index]['id_curso']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogoEditarCurso(cursos[index]['id_curso'], cursos[index]['nombre']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarEliminar(cursos[index]['id_curso'], cursos[index]['nombre']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0D1A63),
        onPressed: _mostrarDialogoNuevoCurso,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}