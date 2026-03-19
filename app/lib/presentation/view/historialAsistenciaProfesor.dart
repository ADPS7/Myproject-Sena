import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistorialAsistenciaView extends StatelessWidget {
  final int idUsuario;
  final String nombreAlumno;

  const HistorialAsistenciaView({
    super.key, 
    required this.idUsuario, 
    required this.nombreAlumno
  });

  @override
  Widget build(BuildContext context) {
    final ApiService _apiService = ApiService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Asistencias: $nombreAlumno"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _apiService.getHistorialAsistencia(idUsuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || snapshot.data?['success'] == false) {
            return const Center(
              child: Text("Error al cargar el historial o no hay datos."),
            );
          }

          final lista = snapshot.data?['asistencias'] as List<dynamic>? ?? [];

          if (lista.isEmpty) {
            return const Center(
              child: Text("Aún no tienes registros de asistencia."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = lista[index];
              final bool asistio = item['asistio'] == 'SI';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: asistio ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      asistio ? Icons.check_circle : Icons.cancel, 
                      color: asistio ? Colors.green : Colors.red
                    ),
                  ),
                  title: Text(
                    item['modulo_nombre'] ?? "Sin nombre",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Fecha: ${item['fecha_formateada']}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: asistio ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['asistio'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}