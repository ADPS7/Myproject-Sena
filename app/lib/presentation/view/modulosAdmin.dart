// Archivo: modulos_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ModulosScreen extends StatefulWidget {
  const ModulosScreen({super.key});

  @override
  State<ModulosScreen> createState() => _ModulosScreenState();
}

class _ModulosScreenState extends State<ModulosScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _inicioController = TextEditingController();
  final TextEditingController _finController = TextEditingController();
  int? _idCursoSeleccionado;

  late Future<List<dynamic>> _listaModulosFuture;

  @override
  void initState() {
    super.initState();
    _listaModulosFuture = _apiService.getModulos();
  }

  void _recargarLista() => setState(() => _listaModulosFuture = _apiService.getModulos());

  // --- DISEÑO: Tarjeta de Módulo con estilo moderno ---
  Widget _buildModuloCard(Map<String, dynamic> modulo, List<dynamic> cursos) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xff0D1A63).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.class_, color: Color(0xff0D1A63)),
        ),
        title: Text(modulo['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text("📅 ${modulo['fecha_inicio']} a ${modulo['fecha_fin']}", style: TextStyle(color: Colors.grey[600])),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _mostrarDialogoModulo(cursos, moduloEditar: modulo)),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _confirmarEliminacion(modulo['id_modulo'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FE),
      appBar: AppBar(
        title: const Text("Gestión de Módulos", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xff0D1A63),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _listaModulosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Sin módulos registrados"));
          
          return FutureBuilder<List<dynamic>>(
            future: _apiService.getCursos(),
            builder: (context, cursosSnapshot) {
              final cursos = cursosSnapshot.data ?? [];
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _buildModuloCard(snapshot.data![index], cursos),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff0D1A63),
        icon: const Icon(Icons.add),
        label: const Text("Nuevo"),
        onPressed: () async {
          final cursos = await _apiService.getCursos();
          if (mounted) _mostrarDialogoModulo(cursos);
        },
      ),
    );
  }

  // --- Métodos de formulario y eliminación (mismos de antes) ---
  // ... (Aquí irían _mostrarDialogoModulo y _confirmarEliminacion)
}