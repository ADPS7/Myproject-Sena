import 'package:app/services/aut_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});   // ← Sin parámetros

  Future<List<dynamic>> _fetchAsistencias() async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception('Usuario no encontrado. Inicia sesión nuevamente.');
    }

    final response = await http.get(
      Uri.parse('http://10.2.135.71:5000/asistencias/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['asistencias'] ?? [];
    } else {
      throw Exception('Error al cargar asistencias');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header igual que antes...
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF0A1E3A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      "Mis Asistencias",
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Registro de tus módulos cursados",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchAsistencias(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final asistencias = snapshot.data ?? [];

                if (asistencias.isEmpty) {
                  return const Center(child: Text("Aún no tienes registros de asistencia"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: asistencias.length,
                  itemBuilder: (context, index) {
                    final item = asistencias[index];
                    final bool asistio = item['asistio'] == 'SI';
                    return _buildAsistenciaCard(
                      modulo: item['modulo_nombre'] ?? 'Módulo',
                      fecha: item['fecha'],
                      asistio: asistio,
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
  Widget _buildAsistenciaCard({
    required String modulo,
    required String fecha,
    required bool asistio,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: asistio ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              asistio ? Icons.check_circle : Icons.cancel,
              color: asistio ? Colors.green : Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("Fecha: $fecha", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text(
                  asistio ? "Asistió" : "No asistió",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: asistio ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
