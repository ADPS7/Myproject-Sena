import 'package:app/services/api_service.dart';
import 'package:app/services/aut_service.dart';
import 'package:flutter/material.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  _TeacherAttendanceScreenState createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _students = [];
  List<dynamic> _modules = [];
  int? _selectedModuleId;
  bool _isLoading = true;
  String? _errorMessage;

  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('Usuario no encontrado');

      // Obtener módulos del profesor
      final modulesResponse = await _apiService.getTeacherModules(userId);
      _modules = modulesResponse['modulos'] ?? [];

      if (_modules.isNotEmpty) {
        _selectedModuleId = _modules.first['id_modulo'];
        await _loadStudents();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedModuleId == null) return;

    try {
      final studentsResponse = await _apiService.getStudentsByModule(_selectedModuleId!);
      setState(() {
        _students = studentsResponse['estudiantes'] ?? [];
        // Inicializar estado de asistencia
        for (var student in _students) {
          student['asistio'] = true; // Por defecto presente
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estudiantes: $e';
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedModuleId == null || _students.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final attendanceData = _students.map((student) => {
        'id_usuario': student['id_usuario'],
        'id_modulo': _selectedModuleId,
        'asistio': student['asistio'] ? 'SI' : 'NO',
        'fecha': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
      }).toList();

      final response = await _apiService.saveBulkAttendance(attendanceData);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asistencia guardada correctamente')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(response['message'] ?? 'Error al guardar asistencia');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGrey),
                                ),
                                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: darkBlue),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "TOMAR ASISTENCIA",
                              style: TextStyle(
                                color: primaryPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Selector de módulo
                        if (_modules.isNotEmpty) ...[
                          Text("Seleccionar Módulo", style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderGrey),
                            ),
                            child: DropdownButton<int>(
                              value: _selectedModuleId,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: _modules.map((module) {
                                return DropdownMenuItem<int>(
                                  value: module['id_modulo'],
                                  child: Text(module['nombre']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedModuleId = value;
                                });
                                _loadStudents();
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Lista de estudiantes
                        Expanded(
                          child: _students.isEmpty
                              ? const Center(child: Text("No hay estudiantes en este módulo"))
                              : ListView.builder(
                                  itemCount: _students.length,
                                  itemBuilder: (context, index) {
                                    final student = _students[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderGrey),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${student['nombres']} ${student['apellidos']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: darkBlue,
                                                  ),
                                                ),
                                                Text(
                                                  student['correo'],
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Switch(
                                            value: student['asistio'] ?? true,
                                            onChanged: (value) {
                                              setState(() {
                                                student['asistio'] = value;
                                              });
                                            },
                                            activeColor: primaryPurple,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Botón guardar
                        if (_students.isNotEmpty)
                          ElevatedButton(
                            onPressed: _saveAttendance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Guardar Asistencia",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}