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
    // Si desde el Dropdown seleccionan 'coordinador', al backend le mandamos 'coordinacion'
    String rolParaBackend = nuevoRol;
    if (nuevoRol == 'coordinador') {
      rolParaBackend = 'coordinacion';
    }

    if (rolParaBackend == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Acción denegada: No puedes asignar el rol de Administrador"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final response = await _apiService.actualizarRol(userId, rolParaBackend);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rol actualizado correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      cargarUsuarios();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al actualizar rol"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- EL TRUCO ESTÁ AQUÍ ---
  List obtenerPorRol(String rol) {
    return usuarios.where((u) {
      final rolUsuario = u['rol'];
      
      // Si la interfaz pide 'coordinador', filtramos por 'coordinacion'
      if (rol == 'coordinador') {
        return rolUsuario == 'coordinacion';
      }
      
      // Para profesores y estudiantes, se mantiene igual
      return rolUsuario == rol;
    }).toList();
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
                  buildCategoria("Coordinadores", "coordinador"),
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
          // Mapeamos el valor actual para el Dropdown de la interfaz
          String rolInterfaz = usuario['rol'];
          if (rolInterfaz == 'coordinacion') {
            rolInterfaz = 'coordinador';
          }

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
                  value: rolInterfaz, // Usa el rol adaptado ('coordinador')
                  items: const [
                    DropdownMenuItem(
                      value: 'coordinador',
                      child: Text("Coordinador"),
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
                      cambiarRol(usuario['id_usuario'], value);
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