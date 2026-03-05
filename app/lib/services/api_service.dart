import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.2.138.52:8000';

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

  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/get_users'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }
}