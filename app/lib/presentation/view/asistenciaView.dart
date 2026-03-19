import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MarcarAsistenciaView extends StatefulWidget {
  final int idModulo;
  final String nombreModulo;

  const MarcarAsistenciaView({
    super.key,
    required this.idModulo,
    required this.nombreModulo,
  });

  @override
  State<MarcarAsistenciaView> createState() => _MarcarAsistenciaViewState();
}

class _MarcarAsistenciaViewState extends State<MarcarAsistenciaView> {
  final ApiService _apiService = ApiService();
  
  // Lista de IDs únicos seleccionados
  List<int> seleccionados = [];
  late Future<List<dynamic>> _futureEstudiantes;

  @override
  void initState() {
    super.initState();
    // Cargamos la lista una sola vez al entrar
    _futureEstudiantes = _apiService.getEstudiantesPorModulo(widget.idModulo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asistencia: ${widget.nombreModulo}"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Listado de Aprendices",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    "Presentes: ${seleccionados.length}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xff0D1A63),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureEstudiantes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final estudiantes = snapshot.data ?? [];
                if (estudiantes.isEmpty) {
                  return const Center(child: Text("No hay alumnos inscritos."));
                }

                return ListView.separated(
                  itemCount: estudiantes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final est = estudiantes[index];
                    
                    // Verificamos el ID. Si 'id_usuario' no existe, idEst será 0
                    final int idEst = est['id_usuario'] ?? 0;
                    final bool estaCheck = seleccionados.contains(idEst);

                    return CheckboxListTile(
                      activeColor: const Color(0xff0D1A63),
                      title: Text("${est['nombres']} ${est['apellidos']}"),
                      subtitle: Text(est['correo'] ?? ""),
                      secondary: CircleAvatar(
                        backgroundColor: estaCheck ? Colors.green : Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      value: estaCheck,
                      onChanged: (bool? valor) {
                        if (idEst == 0) {
                          debugPrint("⚠️ ERROR: El estudiante no tiene ID válido en el JSON.");
                          return;
                        }
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFFC107),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            if (seleccionados.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Selecciona al menos un estudiante")),
              );
              return;
            }

            final res = await _apiService.guardarAsistencia(
              idModulo: widget.idModulo, 
              idsEstudiantes: seleccionados
            );

            if (res['success'] == true) {
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text(
            "REGISTRAR ASISTENCIA",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}