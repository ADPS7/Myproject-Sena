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

  void _mostrarDialogoNuevoCurso(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                    if (result['success'] == true) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Curso registrado")));
                      _cursoController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'])));
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
      appBar: AppBar(title: const Text("Gestión de Cursos")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNuevoCurso(context),
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text("Lista de cursos")),
    );
  }
}