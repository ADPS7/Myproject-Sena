import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final ApiService _apiService = ApiService();

  List usuarios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    setState(() {
      loading = true;
    });

    final response = await _apiService.obtenerUsuarios();

    if (response['success']) {
      usuarios = response['usuarios'];
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> cambiarRol(int userId, String nuevoRol) async {
    final response = await _apiService.actualizarRol(userId, nuevoRol);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Rol actualizado correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      cargarUsuarios();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al actualizar rol"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List obtenerPorRol(String rol) {
    return usuarios.where((u) => u['rol'] == rol).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Control de Usuarios"),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargarUsuarios,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buildCategoria("Administradores", "admin"),
                  buildCategoria("Profesores", "profesor"),
                  buildCategoria("Estudiantes", "estudiante"),
                ],
              ),
            ),
    );
  }

  Widget buildCategoria(String titulo, String rol) {
    final lista = obtenerPorRol(rol);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (lista.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("No hay usuarios en esta categoría"),
          ),

        ...lista.map((usuario) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF7C4DFF),
                  child: Icon(Icons.person, color: Colors.white),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['nombres'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        usuario['correo'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                DropdownButton<String>(
                  value: usuario['rol'],
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text("Admin"),
                    ),
                    DropdownMenuItem(
                      value: 'profesor',
                      child: Text("Profesor"),
                    ),
                    DropdownMenuItem(
                      value: 'estudiante',
                      child: Text("Estudiante"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      cambiarRol(usuario['id'], value);
                    }
                  },
                ),
              ],
            ),
          );
        }),
        
        const SizedBox(height: 24),
      ],
    );
  }
}