import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.2.138.52:8000';

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
      return {"success": false, "error": "Error de conexión"};
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

  Future<List<dynamic>> getTodosLosEstudiantes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios/estudiantes'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> guardarAsistencia(List<Map<String, dynamic>> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asistencia/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}