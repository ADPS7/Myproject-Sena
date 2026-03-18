import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.101.81:8000'; // Asegúrate que esta IP sea la de tu PC

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
}