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

  // Función para mostrar el formulario emergente
  Future<void> _mostrarDialogoNuevoCurso(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Registrar Nuevo Curso"),
          content: TextField(
            controller: _cursoController,
            decoration: const InputDecoration(
              labelText: "Nombre del curso",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_cursoController.text.isNotEmpty) {
                  final result = await _apiService.crearCurso(_cursoController.text);
                  if (mounted) {
                    if (result['success'] == true) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Curso registrado con éxito")),
                      );
                      _cursoController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['error'] ?? "Error desconocido")),
                      );
                    }
                  }
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
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
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los cursos"));
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
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xff0D1A63),
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  title: Text(cursos[index]['nombre']),
                  subtitle: Text("codigo: ${cursos[index]['id_curso']}"),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0D1A63),
        onPressed: () async {
          await _mostrarDialogoNuevoCurso(context);
          setState(() {}); // Esto fuerza al FutureBuilder a recargar la lista
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}