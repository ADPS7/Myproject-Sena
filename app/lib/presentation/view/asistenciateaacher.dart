import 'package:flutter/material.dart';

class AsistsTeacher extends StatefulWidget {
  final int idUsuario;

  const AsistsTeacher({super.key, required this.idUsuario});

  @override
  State<AsistsTeacher> createState() => _AsistsTeacherState();
}

class _AsistsTeacherState extends State<AsistsTeacher> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Control de Asistencia", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A1E3A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fact_check_rounded, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            Text("Módulo de Asistencia para ID: ${widget.idUsuario}"),
          ],
        ),
      ),
    );
  }
}