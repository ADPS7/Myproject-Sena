import 'dart:convert';
import 'package:http/http.dart' as http;

import 'aut_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.2.134.154:5000';
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

  Future<Map<String, dynamic>> getNotasEstudiante(int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/notas-alumno/$id'),
  );

  return jsonDecode(response.body);
}

Future<String> getStudentCourse() async {
  final userId = await AuthService.getUserId(); 
  if (userId == null) return "Usuario no encontrado";

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/asistencias/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['curso_nombre'] != null) {
        return data['curso_nombre'];
      }
      if (data['asistencias'] != null && data['asistencias'].isNotEmpty) {
        return data['asistencias'][0]['curso_nombre'] ?? 'Sin curso asignado';
      }
      return 'Sin curso asignado';
    } else {
      return "Error del servidor";
    }
  } catch (e) {
    print("Error getStudentCourse: $e");
    return "Sin conexión con el servidor";
  }
}
  
Future<Map<String, dynamic>> getMyModules() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      return {'curso': 'Usuario no encontrado', 'modulos': []};
    }

    try {
      // Llamamos al endpoint correcto que ya mejoramos
      final response = await http.get(
        Uri.parse('$baseUrl/asistencias/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> asistencias = data['asistencias'] ?? [];
        
        String cursoNombre = data['curso_nombre'] ?? 
            (asistencias.isNotEmpty ? asistencias.first['curso_nombre'] ?? 'Sin curso asignado' : 'Sin curso asignado');

        final int idCurso = asistencias.isNotEmpty 
            ? (asistencias.first['id_curso'] ?? 1) 
            : 1;

        // Obtenemos los módulos
        final List<dynamic> modulos = await getModulosPorCurso(idCurso);

        return {
          'curso': cursoNombre,
          'modulos': modulos,
        };
      } else {
        return {'curso': 'Error al cargar', 'modulos': []};
      }
    } catch (e) {
      print("Error en getMyModules: $e");
      return {'curso': 'Sin curso asignado', 'modulos': []};
    }
  }
  Future<Map<String, dynamic>> crearCurso(String nombreCurso) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cursos/crear'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nombre': nombreCurso}),
      );

      final data = json.decode(response.body);
      return data; // Retorna el mapa con success y el mensaje/error
    } catch (e) {
      return {"success": false, "error": "Error de conexión: $e"};
    }
  }
  Future<List<dynamic>> getCursos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cursos'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  Future<Map<String, dynamic>> editarCurso(int idCurso, String nuevoNombre) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cursos/editar/$idCurso'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nombre': nuevoNombre}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error de conexión"};
    }
  }
  Future<Map<String, dynamic>> eliminarCurso(int idCurso) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cursos/eliminar/$idCurso'),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error de conexión"};
    }
  }
  Future<Map<String, dynamic>> crearModulo(String nombre, String inicio, String fin, int idCurso) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/modulos/crear'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'fecha_inicio': inicio,
          'fecha_fin': fin,
          'id_curso': idCurso
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
  Future<List<dynamic>> getModulos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/modulos'));
      
      if (response.statusCode == 200) {
        // Decodificamos el JSON y devolvemos la lista
        return json.decode(response.body);
      } else {
        return []; // Retorna lista vacía si falla
      }
    } catch (e) {
      print("Error al obtener módulos: $e");
      return [];
    }
  }
  Future<Map<String, dynamic>> editarModulo(int id, String nombre, String inicio, String fin, int idCurso) async {
    final response = await http.put(
      Uri.parse('$baseUrl/modulos/editar/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nombre': nombre, 'fecha_inicio': inicio, 'fecha_fin': fin, 'id_curso': idCurso}),
    );
    return json.decode(response.body);
  }
  Future<Map<String, dynamic>> eliminarModulo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/modulos/eliminar/$id'));
    return json.decode(response.body);
  }
  
  
}