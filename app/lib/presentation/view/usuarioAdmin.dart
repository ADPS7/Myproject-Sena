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

  // Buscadores por sección
  final Map<String, TextEditingController> _searchControllers = {};
  final Map<String, String> _searchTerms = {};

  @override
  void initState() {
    super.initState();
    // Inicializar controladores para cada sección
    const secciones = ['coordinador', 'profesor', 'inactivo', 'estudiante'];
    for (var seccion in secciones) {
      _searchControllers[seccion] = TextEditingController();
      _searchTerms[seccion] = '';
    }
    cargarUsuarios();
  }

  @override
  void dispose() {
    for (var controller in _searchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> cargarUsuarios() async {
    setState(() => loading = true);

    final response = await _apiService.obtenerUsuarios();
    if (response['success']) {
      usuarios = response['usuarios'];
    }

    setState(() => loading = false);
  }

  Future<void> cambiarRol(int userId, String nuevoRol) async {
    String rolParaBackend = nuevoRol;
    if (nuevoRol == 'coordinador') rolParaBackend = 'coordinacion';

    if (rolParaBackend == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No puedes asignar rol de Administrador"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final response = await _apiService.actualizarRol(userId, rolParaBackend);

    if (response['success']) {
      String mensaje = nuevoRol == 'inactivo'
          ? "Usuario inactivado correctamente"
          : "Rol actualizado correctamente";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
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
    final searchTerm = _searchTerms[rol]?.toLowerCase().trim() ?? '';

    return usuarios.where((u) {
      final rolUsuario = u['rol']?.toString().toLowerCase() ?? '';
      bool coincideRol = false;

      if (rol == 'coordinador')
        coincideRol = rolUsuario == 'coordinacion';
      else
        coincideRol = rolUsuario == rol.toLowerCase();

      if (!coincideRol) return false;

      if (searchTerm.isEmpty) return true;

      final nombreCompleto = "${u['nombres']} ${u['apellidos'] ?? ''}"
          .toLowerCase();
      final correo = u['correo']?.toLowerCase() ?? '';

      return nombreCompleto.contains(searchTerm) || correo.contains(searchTerm);
    }).toList();
  }

  void _onSearchChanged(String rol, String value) {
    setState(() {
      _searchTerms[rol] = value;
    });
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
                  buildCategoria("Usuarios Inactivos", "inactivo"),
                  buildCategoria("Estudiantes", "estudiante"),
                ],
              ),
            ),
    );
  }

  Widget buildCategoria(String titulo, String rol) {
    final lista = obtenerPorRol(rol);
    final bool esInactivo = rol == 'inactivo';
    final controller = _searchControllers[rol]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Buscador pequeño
            SizedBox(
              width: 180,
              child: TextField(
                controller: controller,
                onChanged: (value) => _onSearchChanged(rol, value),
                decoration: InputDecoration(
                  hintText: "Buscar...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
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
            child: Text(
              esInactivo
                  ? "No hay usuarios inactivos"
                  : "No se encontraron resultados",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

        ...lista.map((usuario) {
          String rolActual = usuario['rol'] ?? '';
          if (rolActual == 'coordinacion') rolActual = 'coordinador';

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
                CircleAvatar(
                  backgroundColor: esInactivo
                      ? Colors.grey
                      : const Color(0xFF7C4DFF),
                  child: Icon(
                    esInactivo ? Icons.person_off : Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${usuario['nombres']} ${usuario['apellidos'] ?? ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        usuario['correo'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                DropdownButton<String>(
                  value: rolActual,
                  items: [
                    const DropdownMenuItem(
                      value: 'coordinador',
                      child: Text("Coordinador"),
                    ),
                    const DropdownMenuItem(
                      value: 'profesor',
                      child: Text("Profesor"),
                    ),
                    const DropdownMenuItem(
                      value: 'estudiante',
                      child: Text("Estudiante"),
                    ),
                    const DropdownMenuItem(
                      value: 'inactivo',
                      child: Text(
                        "Inactivar",
                        style: TextStyle(color: Colors.red),
                      ),
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
