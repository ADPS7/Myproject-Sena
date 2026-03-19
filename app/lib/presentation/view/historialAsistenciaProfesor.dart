import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistorialAsistenciaView extends StatelessWidget {
  final int idModulo;
  final String nombreModulo;

  const HistorialAsistenciaView({
    super.key,
    required this.idModulo,
    required this.nombreModulo,
  });

  @override
  Widget build(BuildContext context) {
    final ApiService _apiService = ApiService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Historial: $nombreModulo"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        // Aquí llamamos a la función de tu ApiService
        future: _apiService.getHistorialPorModulo(idModulo), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final historial = snapshot.data ?? [];

          if (historial.isEmpty) {
            return const Center(child: Text("No hay registros para este módulo."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: historial.length,
            itemBuilder: (context, index) {
              final registro = historial[index];
              final bool asistio = registro['asistio'] == 'SI';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: asistio ? Colors.green : Colors.red,
                    child: Icon(
                      asistio ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  title: Text("${registro['nombres']} ${registro['apellidos']}"),
                  subtitle: Text("Fecha: ${registro['fecha']}"),
                  trailing: Text(
                    registro['asistio'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: asistio ? Colors.green : Colors.red,
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