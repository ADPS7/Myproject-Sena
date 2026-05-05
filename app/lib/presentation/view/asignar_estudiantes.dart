import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AsignarEstudiantesScreen extends StatefulWidget {
  const AsignarEstudiantesScreen({super.key});

  @override
  State<AsignarEstudiantesScreen> createState() => _AsignarEstudiantesScreenState();
}

class _AsignarEstudiantesScreenState extends State<AsignarEstudiantesScreen> {
  final ApiService _apiService = ApiService();
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color softBg = const Color(0xFFF8FAFC);
  final Color darkBlue = const Color(0xFF334155);
  final Color slateGrey = const Color(0xFF64748B);

  int? _selectedCourseId;
  List<dynamic> _cursos = [];
  List<dynamic> _estudiantesSinCurso = [];
  List<dynamic> _estudiantesAsignados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
    });

    final cursos = await _apiService.getCursos();
    final estudiantesSinCurso = await _apiService.getEstudiantesSinCurso();
    final estudiantesAsignados = _selectedCourseId != null
        ? await _apiService.getEstudiantesPorCurso(_selectedCourseId!)
        : <dynamic>[];

    if (!mounted) return;

    setState(() {
      _cursos = cursos;
      _estudiantesSinCurso = estudiantesSinCurso;
      _estudiantesAsignados = estudiantesAsignados;
      _isLoading = false;
    });
  }

  Future<void> _cargarEstudiantesAsignados() async {
    if (_selectedCourseId == null) return;

    setState(() {
      _isLoading = true;
    });

    final estudiantes = await _apiService.getEstudiantesPorCurso(_selectedCourseId!);
    if (!mounted) return;

    setState(() {
      _estudiantesAsignados = estudiantes;
      _isLoading = false;
    });
  }

  Future<void> _asignarEstudiante(Map<String, dynamic> estudiante) async {
    if (_selectedCourseId == null) {
      _mostrarMensaje('Selecciona primero un curso para asignar.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resultado = await _apiService.asignarAlumno(estudiante['id_usuario'], _selectedCourseId!);

    if (!mounted) return;

    if (resultado['success'] == true) {
      setState(() {
        _estudiantesSinCurso.removeWhere((e) => e['id_usuario'] == estudiante['id_usuario']);
        _estudiantesAsignados.add(estudiante);
        _isLoading = false;
      });
      _mostrarMensaje('Estudiante asignado correctamente.');
    } else {
      setState(() {
        _isLoading = false;
      });
      _mostrarMensaje(resultado['error'] ?? 'No se pudo asignar al estudiante.');
    }
  }

  Future<void> _desasignarEstudiante(Map<String, dynamic> estudiante) async {
    setState(() {
      _isLoading = true;
    });

    final resultado = await _apiService.desasignarAlumno(estudiante['id_usuario']);

    if (!mounted) return;

    if (resultado['success'] == true) {
      setState(() {
        _estudiantesAsignados.removeWhere((e) => e['id_usuario'] == estudiante['id_usuario']);
        _estudiantesSinCurso.add(estudiante);
        _isLoading = false;
      });
      _mostrarMensaje('Estudiante desasignado correctamente.');
    } else {
      setState(() {
        _isLoading = false;
      });
      _mostrarMensaje(resultado['error'] ?? 'No se pudo desasignar al estudiante.');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> estudiante, {required bool assigned}) {
    final nombre = '${estudiante['nombres'] ?? ''} ${estudiante['apellidos'] ?? ''}'.trim();
    final idUsuario = estudiante['id_usuario'] as int?;
    final label = assigned ? 'Desasignar' : 'Asignar';
    final action = assigned ? _desasignarEstudiante : _asignarEstudiante;
    final buttonColor = assigned ? Colors.redAccent : primaryPurple;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(nombre.isEmpty ? estudiante['correo'] ?? 'Estudiante' : nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('ID: ${idUsuario ?? '---'}', style: const TextStyle(color: Color(0xFF64748B))),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: idUsuario == null ? null : () => action(estudiante),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Asignar Estudiantes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Selecciona un curso y administra asignaciones sin repetidos.', style: TextStyle(fontSize: 14, color: Color(0xFF475569))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButton<int>(
                value: _selectedCourseId,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: const Text('Elegir curso', style: TextStyle(color: Colors.black87)),
                items: _cursos.map((curso) {
                  return DropdownMenuItem<int>(
                    value: curso['id_curso'] as int?,
                    child: Text(curso['nombre'] ?? 'Curso', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourseId = value;
                  });
                  _cargarEstudiantesAsignados();
                },
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estudiantes asignados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            TextButton.icon(
                              onPressed: _selectedCourseId != null ? _cargarEstudiantesAsignados : null,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Actualizar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_selectedCourseId == null)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Text('Selecciona un curso para ver los estudiantes asignados.', style: TextStyle(color: Color(0xFF64748B))),
                          )
                        else if (_estudiantesAsignados.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Text('Este curso no tiene estudiantes asignados.', style: TextStyle(color: Color(0xFF64748B))),
                          )
                        else
                          Column(
                            children: _estudiantesAsignados.map<Widget>((estudiante) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildStudentCard(estudiante, assigned: true),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 24),
                        const Text('Estudiantes sin curso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        if (_estudiantesSinCurso.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Text('No hay estudiantes disponibles para asignar.', style: TextStyle(color: Color(0xFF64748B))),
                          )
                        else
                          Column(
                            children: _estudiantesSinCurso.map<Widget>((estudiante) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildStudentCard(estudiante, assigned: false),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
