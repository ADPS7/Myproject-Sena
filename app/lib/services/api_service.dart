import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:8000'; // Asegúrate que esta IP sea la de tu PC

  Future<Map<String, dynamic>> login({
    required String correo,
    required String clave,  
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'correo': correo,
          'clave': clave,
        }),
      );

      final decodedData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {"success": true, "user": decodedData['user']};
      } else {
        return {"success": false, "error": decodedData['error']};
      }
    } catch (e) {
      return {"success": false, "error": "Error de conexión con el servidor"};
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String nombres,
    required String apellidos,
    required String correo,
    required String fechaNacimiento,
    required String clave,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_user'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': correo,
        'fecha_nacimiento': fechaNacimiento,
        'clave': clave,
      }),
    );
    return json.decode(response.body);
  }

  Future<List<dynamic>> getCursosPorProfesor(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cursos/profesor/$idUsuario'),
      );

      if (response.statusCode == 200) {
        // Retorna la lista de cursos (id_curso y nombre)
        return json.decode(response.body);
      } else {
        print("Error en el servidor: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error de conexión: $e");
      return [];
    }
  }
  // Obtener módulos de un curso específico
  Future<List<dynamic>> getModulosPorCurso(int idCurso) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/modulos/curso/$idCurso'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error en getModulosPorCurso: $e");
      return [];
    }
  }
  
  Future<List<dynamic>> getEstudiantesPorModulo(int idModulo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/modulo/$idModulo/students'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  Future<Map<String, dynamic>> guardarAsistencia({
    required int idModulo,
    required List<int> idsEstudiantes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asistencia/registrar'), // Ajusta esta URL a tu backend
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_modulo': idModulo,
          'estudiantes': idsEstudiantes, // La lista de IDs que marcaste
          'fecha': DateTime.now().toIso8601String().split('T')[0], // Fecha actual YYYY-MM-DD
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final errorBody = json.decode(response.body);
        return {'success': false, 'error': errorBody['detail'] ?? 'Error al guardar'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
  Future<Map<String, dynamic>> getHistorialAsistencia(dynamic idUsuario) async { // dynamic por si acaso
    try {
      // Forzamos el ID a string para evitar errores en la URL
      final String idStr = idUsuario.toString();
      final response = await http.get(
        Uri.parse('$baseUrl/asistencias/detalle/$idStr'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } 
      return {"success": false, "asistencias": []};
    } catch (e) {
      return {"success": false, "asistencias": []};
    }
  }

  Future<Map<String, dynamic>> getAdminAsistencias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/asistencias'),
        headers: {'Content-Type': 'application/json'},
      );

      final decodedData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "cursos": decodedData['cursos'] ?? []};
      } else {
        return {
          "success": false,
          "error": decodedData['error'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {"success": false, "error": "Error de conexión con el servidor"};
    }
  }

  Future<Map<String, dynamic>> getAdminNotas() async {
  final response = await http.get(Uri.parse('$baseUrl/admin/notas'));

  return json.decode(response.body);
  }
}