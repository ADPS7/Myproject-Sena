import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';

  // Guardar datos después del login exitoso
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user['id_usuario']);
    await prefs.setString(_keyUserName, user['nombres'] ?? '');
    await prefs.setString(_keyUserRole, user['rol'] ?? '');
  }

  // Obtener el id del usuario logueado
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}