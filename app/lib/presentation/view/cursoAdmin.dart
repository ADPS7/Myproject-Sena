import 'package:flutter/material.dart';

class CursosScreen extends StatelessWidget {
  const CursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Gestión de Cursos"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
        actions: [
          // Botón en la parte superior (App Bar) como pediste
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // Lógica para añadir curso
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Lista de cursos vacía"),
      ),
    );
  }
}