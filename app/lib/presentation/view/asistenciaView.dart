import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MarcarAsistenciaView extends StatefulWidget {
  final int idModulo;
  final String nombreModulo;

  const MarcarAsistenciaView({
    super.key, 
    required this.idModulo, 
    required this.nombreModulo
  });

  @override
  State<MarcarAsistenciaView> createState() => _MarcarAsistenciaViewState();
}

class _MarcarAsistenciaViewState extends State<MarcarAsistenciaView> {
  final ApiService _apiService = ApiService();
  
  // Esta lista almacenará los IDs de los aprendices que el profesor marque
  List<int> seleccionados = []; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asistencia: ${widget.nombreModulo}"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Encabezado con contador
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Listado de Aprendices",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Marque a los que están presentes",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: const Color(0xff0D1A63),
                  radius: 25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${seleccionados.length}",
                        style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const Text(
                        "P",
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Lista de Estudiantes
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _apiService.getEstudiantesPorModulo(widget.idModulo),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text("Error al cargar: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No se encontraron aprendices en este módulo."),
                  );
                }

                final estudiantes = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 10, bottom: 100),
                  itemCount: estudiantes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final est = estudiantes[index];
                    
                    // --- PROTECCIÓN CONTRA ERRORES NULL ---
                    // Si 'id_usuario' viene nulo o no existe, usamos 0 para evitar el crash
                    final int idEst = est['id_usuario'] ?? 0; 
                    final String nombre = est['nombres'] ?? "Sin Nombre";
                    final String apellido = est['apellidos'] ?? "";
                    final String correo = est['correo'] ?? "Sin correo";
                    
                    final bool estaCheck = seleccionados.contains(idEst);

                    return CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      activeColor: const Color(0xff0D1A63),
                      value: estaCheck,
                      title: Text(
                        "$nombre $apellido",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(correo),
                      secondary: CircleAvatar(
                        backgroundColor: estaCheck ? Colors.green : Colors.grey[300],
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : "?",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      onChanged: (bool? valor) {
                        if (idEst == 0) return; // Seguridad: no marcar si el ID es inválido
                        setState(() {
                          if (valor == true) {
                            seleccionados.add(idEst);
                          } else {
                            seleccionados.remove(idEst);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Botón Flotante/Fijo inferior para Guardar
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFFC107),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
          ),
          onPressed: () async {
            if (seleccionados.isEmpty) {
              _mostrarAlerta(context, "Atención", "No has seleccionado ningún aprendiz.");
              return;
            }

            final res = await _apiService.guardarAsistencia(
              idModulo: widget.idModulo, 
              idsEstudiantes: seleccionados
            );
            
            if (context.mounted) {
              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Asistencia guardada correctamente")),
                );
                Navigator.pop(context); // Regresar a la vista de cursos
              } else {
                _mostrarAlerta(context, "Error", res['error'] ?? "Hubo un problema al guardar.");
              }
            }
          },
          child: const Text(
            "CONFIRMAR ASISTENCIA", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Función auxiliar para mostrar alertas de error
  void _mostrarAlerta(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }
}