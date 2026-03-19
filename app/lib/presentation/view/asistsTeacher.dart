import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterAttendanceView extends StatefulWidget {
  final String cursoId; // ID del curso seleccionado
  final String cursoNombre;

  const RegisterAttendanceView({
    super.key, 
    required this.cursoId, 
    required this.cursoNombre
  });

  @override
  State<RegisterAttendanceView> createState() => _RegisterAttendanceViewState();
}

class _RegisterAttendanceViewState extends State<RegisterAttendanceView> {
  List<dynamic> alumnos = [];
  Map<int, bool> asistencia = {}; // Guarda ID del alumno y su estado (true/false)
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
  }

  Future<void> _cargarAlumnos() async {
    // Aquí llamarías a tu API para traer los alumnos de este curso
    // Ejemplo: final result = await ApiService().getAlumnosByCurso(widget.cursoId);
    
    // Simulación de datos:
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      alumnos = [
        {"id": 1, "nombre": "Juan Pérez"},
        {"id": 2, "nombre": "María García"},
        {"id": 3, "nombre": "Carlos López"},
      ];
      // Inicializar todos como "Presente" (true)
      for (var alumno in alumnos) {
        asistencia[alumno['id']] = true;
      }
      isLoading = false;
    });
  }

  Future<void> _enviarAsistencia() async {
    setState(() => isLoading = true);
    
    // Aquí enviarías el mapa de asistencia a tu base de datos
    // final success = await ApiService().postAsistencia(widget.cursoId, asistencia);

    await Future.delayed(const Duration(seconds: 2)); // Simulación
    
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Asistencia registrada con éxito"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asistencia: ${widget.cursoNombre}"),
        backgroundColor: const Color(0xff0D1A63),
        foregroundColor: Colors.white,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: alumnos.length,
                  itemBuilder: (context, index) {
                    final alumno = alumnos[index];
                    final int id = alumno['id'];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: CheckboxListTile(
                        title: Text(alumno['nombre']),
                        subtitle: Text(asistencia[id]! ? "Presente" : "Ausente"),
                        value: asistencia[id],
                        activeColor: const Color(0xff0D1A63),
                        onChanged: (bool? value) {
                          setState(() {
                            asistencia[id] = value ?? false;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _enviarAsistencia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("GUARDAR ASISTENCIA", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
    );
  }
}