import 'dart:convert';
import 'package:http/http.dart' as http;

import 'aut_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.2.133.175:5000';
  Future<Map<String, dynamic>> login({
    required String correo,
    required String clave,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': correo, 'clave': clave}),
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
      final response = await http.get(
        Uri.parse('$baseUrl/modulos/curso/$idCurso'),
      );
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
    List<Map<String, dynamic>> asistencias = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asistencia/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_modulo': idModulo,
          'estudiantes': idsEstudiantes,
          'fecha': DateTime.now().toIso8601String().split('T')[0],
          'asistencias': asistencias,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Asistencia guardada correctamente',
        };
      } else {
        final errorBody = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorBody['error'] ?? 'Error desconocido al guardar asistencia',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getHistorialAsistencia(dynamic idUsuario) async {
    try {
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
    final response = await http.get(Uri.parse('$baseUrl/notas-alumno/$id'));

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getNotasPorModulo(int idModulo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notas/modulo/$idModulo'),
      );
      if (response.statusCode == 200) {
        print("Notas por módulo: ${response.body}");
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Error en getNotasPorModulo: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> guardarNota({
    int? idNota,
    required int idUsuario,
    required int idModulo,
    required double nota,
  }) async {
    if (nota > 5.0) {
      return {'success': false, 'error': 'La nota no puede ser mayor a 5.0.'};
    }

    try {
      final uri = idNota != null
          ? Uri.parse('$baseUrl/notas/$idNota')
          : Uri.parse('$baseUrl/notas');

      final response = idNota != null
          ? await http.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'nota': nota}),
            )
          : await http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'id_usuario': idUsuario,
                'id_modulo': idModulo,
                'nota': nota,
              }),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }

      final errorBody = json.decode(response.body);
      return {
        'success': false,
        'error': errorBody['error'] ?? 'Error al guardar la nota',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
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

        String cursoNombre =
            data['curso_nombre'] ??
            (asistencias.isNotEmpty
                ? asistencias.first['curso_nombre'] ?? 'Sin curso asignado'
                : 'Sin curso asignado');

        final int idCurso = asistencias.isNotEmpty
            ? (asistencias.first['id_curso'] ?? 1)
            : 1;

        // Obtenemos los módulos
        final List<dynamic> modulos = await getModulosPorCurso(idCurso);

        return {'curso': cursoNombre, 'modulos': modulos};
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

  Future<Map<String, dynamic>> editarCurso(
    int idCurso,
    String nuevoNombre,
  ) async {
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

  Future<Map<String, dynamic>> crearModulo(
    String nombre,
    String inicio,
    String fin,
    int idCurso,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/modulos/crear'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'fecha_inicio': inicio,
          'fecha_fin': fin,
          'id_curso': idCurso,
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

  Future<Map<String, dynamic>> editarModulo(
    int id,
    String nombre,
    String inicio,
    String fin,
    int idCurso,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/modulos/editar/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'nombre': nombre,
        'fecha_inicio': inicio,
        'fecha_fin': fin,
        'id_curso': idCurso,
      }),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> eliminarModulo(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/modulos/eliminar/$id'),
    );
    return json.decode(response.body);
  }

  Future<List<dynamic>> getEstudiantes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/estudiantes'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getEstudiantesSinCurso() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estudiantes-sin-curso'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getProfesores() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profesores'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getEstudiantesPorCurso(int idCurso) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cursos/$idCurso/estudiantes'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getProfesoresSinCurso() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profesores-sin-curso'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getProfesoresPorCurso(int idCurso) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cursos/$idCurso/profesores'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getProfesoresDisponiblesPorCurso(int idCurso) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profesores-disponibles/$idCurso'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> desasignarProfesor(
    int idUsuario,
    int? idCurso,
  ) async {
    try {
      final body = {'id_usuario': idUsuario};
      if (idCurso != null) {
        body['id_curso'] = idCurso;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/desasignar-profesor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error de conexión"};
    }
  }

  Future<Map<String, dynamic>> asignarProfesor(
    int idUsuario,
    int idCurso,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asignar-profesor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_usuario': idUsuario, 'id_curso': idCurso}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error de conexión"};
    }
  }

  Future<Map<String, dynamic>> desasignarAlumno(int idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/desasignar-alumno'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_usuario': idUsuario}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error de conexión"};
    }
  }

  Future<Map<String, dynamic>> asignarAlumno(int idUsuario, int idCurso) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asignar-alumno'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_usuario': idUsuario, 'id_curso': idCurso}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error de conexión"};
    }
  }

  Future<Map<String, dynamic>> obtenerDatosCardAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "totalCursos": data['totalCursos'] ?? 0,
          "totalUsuarios": data['totalUsuarios'] ?? 0,
        };
      } else {
        return {
          "success": false,
          "error": "Error al obtener datos del servidor",
        };
      }
    } catch (e) {
      print("Error en getAdminStats: $e");
      return {"success": false, "error": "Error de conexión"};
    }
  }

  Future<Map<String, dynamic>> getStudentStats(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student_stats/$idUsuario'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Error del servidor'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> actualizarPerfilCompleto({
    required int idUsuario,
    required String nombres,
    required String apellidos,
    required String correo,
    required String fechaNacimiento,
    required String direccion,
    required String departamento,
    required String municipio,
    required String telefono,
    required String telefonoEmergencia,
    required String tipoDocumento,
    required String numeroDocumento,
    required String estrato,
    required String sexo,
    required String eps,
    String? password,
  }) async {
    try {
      // Armamos el JSON con todos los datos que pide la nueva función de Python
      final Map<String, dynamic> body = {
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': correo,
        'fecha_nacimiento': fechaNacimiento,
        'direccion': direccion,
        'departamento': departamento,
        'municipio': municipio,
        'telefono': telefono,
        'telefono_emergencia': telefonoEmergencia,
        'tipo_documento': tipoDocumento,
        'numero_documento': numeroDocumento,
        'estrato': estrato,
        'sexo': sexo,
        'eps': eps,
      };

      // Si el usuario escribió una contraseña nueva, la anexamos
      if (password != null && password.isNotEmpty) {
        body['nueva_clave'] = password;
      }

      // Apuntamos a la NUEVA ruta que creamos en Flask
      final response = await http.put(
        Uri.parse('$baseUrl/actualizar_perfil_completo/$idUsuario'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error de conexión"};
    }
  }
  // Estos son los metodos del archibo usuarioAdmin.dart que hacen uso de los servicios del ApiService, por eso se encuentran aqui para no perder el contexto de su uso

  // primer metodo

  Future<Map<String, dynamic>> obtenerUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'usuarios': data['usuarios'], // ✅ FIX IMPORTANTE
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Error al obtener usuarios',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> actualizarRol(
    int userId,
    String nuevoRol,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$userId/rol'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rol': nuevoRol}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Error al actualizar rol',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Consulta los datos exclusivos de la tabla DatosUsuarios
  Future<Map<String, dynamic>> obtenerDatosAdicionales(int idUsuario) async {
    final url = Uri.parse('$baseUrl/obtener_datos_adicionales/$idUsuario');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "error": "Error del servidor: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "No se pudo conectar con el servidor: $e",
      };
    }
  }

  Future<Map<String, dynamic>> getReporteAsistenciaPorModulo(
    int idModulo,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/asistencia/detallada/$idModulo'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // NUEVO: Guardar nota con nombre de actividad
  Future<Map<String, dynamic>> guardarNotaConActividad({
    required int idUsuario,
    required int idModulo,
    required double nota,
    required String nombreActividad,
    int? idNota,
  }) async {
    try {
      final uri = idNota != null
          ? Uri.parse('$baseUrl/notas/$idNota')
          : Uri.parse('$baseUrl/notas');

      final response = idNota != null
          ? await http.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'nota': nota, 'nombre': nombreActividad}),
            )
          : await http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'id_usuario': idUsuario,
                'id_modulo': idModulo,
                'nota': nota,
                'nombre': nombreActividad,
              }),
            );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<List<dynamic>> getHistorialNotas(int idModulo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notas/modulo/historial_v2/$idModulo'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Error al obtener historial: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': email}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"exists": false, "error": "Error de conexión"};
    }
  }

  // 2. Solicita el envío del código de 6 dígitos al correo
  Future<Map<String, dynamic>> requestReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request-reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': email}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"error": "No se pudo solicitar el código"};
    }
  }

  // 3. Verifica si el código ingresado por el usuario es correcto
  Future<Map<String, dynamic>> verifyCode(String email, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': email, 'codigo': codigo}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"error": "Error al verificar código"};
    }
  }

  // 4. Actualiza la contraseña en la base de datos
  Future<Map<String, dynamic>> updatePassword(String email, String nuevaClave) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': email, 'clave': nuevaClave}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {"success": false, "error": "Error al actualizar la contraseña"};
    }
  }
}
