import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AsistenciaView extends StatefulWidget {
  const AsistenciaView({super.key});

  @override
  State<AsistenciaView> createState() => _AsistenciaViewState();
}

class _AsistenciaViewState extends State<AsistenciaView> {
  final ApiService _apiService = ApiService();
  List<dynamic> _estudiantes = [];
  Map<int, String> _estados = {}; // id_usuario -> 'SI'/'NO'
  bool _isLoading = true;
  int idModuloActual = 1; // Deberías obtenerlo según tu lógica de negocio

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final data = await _apiService.getTodosLosEstudiantes();
    setState(() {
      _estudiantes = data;
      for (var est in _estudiantes) {
        _estados[est['id_usuario']] = 'SI';
      }
      _isLoading = false;
    });
  }

  Future<void> _enviarDatos() async {
    setState(() => _isLoading = true);
    
    final String fechaActual = DateTime.now().toIso8601String().split('T')[0];
    
    List<Map<String, dynamic>> payload = _estados.entries.map((e) => {
      "fecha": fechaActual,
      "asistio": e.value,
      "id_usuario": e.key,
      "id_modulo": idModuloActual
    }).toList();

    final exito = await _apiService.guardarAsistencia(payload);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exito ? "Asistencia guardada" : "Error al guardar"),
          backgroundColor: exito ? Colors.green : Colors.red,
        ),
      );
      if (exito) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Asistencia"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _estudiantes.length,
                    itemBuilder: (context, index) {
                      final est = _estudiantes[index];
                      final id = est['id_usuario'];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text("${est['nombres']} ${est['apellidos']}"),
                          subtitle: Text(est['correo']),
                          trailing: DropdownButton<String>(
                            value: _estados[id],
                            items: const [
                              DropdownMenuItem(value: 'SI', child: Text("Presente")),
                              DropdownMenuItem(value: 'NO', child: Text("Faltó")),
                            ],
                            onChanged: (val) {
                              setState(() => _estados[id] = val!);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _enviarDatos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0D1A63),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("GUARDAR ASISTENCIA", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
    );
  }
}