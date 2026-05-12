import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nombreController = TextEditingController();

  // Paleta de colores equilibrada
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color softBg = const Color(0xFFF8FAFC);
  final Color darkBlue = const Color(0xFF334155);
  final Color slateGrey = const Color(0xFF94A3B8);

  late Future<List<dynamic>> _listaCursosFuture;

  @override
  void initState() {
    super.initState();
    _listaCursosFuture = _apiService.getCursos();
  }

  // Liberar el controlador para optimizar memoria (importante para tu hardware)
  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _recargarLista() {
    setState(() {
      _listaCursosFuture = _apiService.getCursos();
    });
  }

  // Estilo de los campos de texto
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: slateGrey, size: 20),
      labelStyle: TextStyle(color: slateGrey),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryPurple.withOpacity(0.5), width: 2),
      ),
    );
  }

  // Widget para los botones de acción
  Widget _actionIcon(IconData icon, Color? color, VoidCallback onTap) {
    final Color finalColor = color ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: finalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: finalColor, size: 20),
      ),
    );
  }

  // --- FORMULARIO DE REGISTRO/EDICIÓN DE CURSO CON FEEDBACK ---
  Future<void> _mostrarDialogoCurso({Map<String, dynamic>? cursoEditar}) async {
    if (cursoEditar != null) {
      _nombreController.text = cursoEditar['nombre'];
    } else {
      _nombreController.clear();
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: softBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          cursoEditar == null ? "Nuevo Curso" : "Editar Curso",
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              TextField(
                  controller: _nombreController,
                  decoration: _inputStyle("Nombre del Curso", Icons.school_outlined)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: slateGrey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final nombre = _nombreController.text.trim();
              if (nombre.isNotEmpty) {
                Map<String, dynamic> response;

                if (cursoEditar == null) {
                  response = await _apiService.crearCurso(nombre);
                } else {
                  response = await _apiService.editarCurso(cursoEditar['id_curso'], nombre);
                }

                if (mounted) {
                  Navigator.pop(context); // Cierra el diálogo

                  if (response['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(cursoEditar == null 
                              ? "¡Curso creado correctamente!" 
                              : "¡Curso actualizado con éxito!"),
                          ],
                        ),
                        backgroundColor: cursoEditar == null ? Colors.green.shade600 : primaryPurple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(20),
                      ),
                    );
                    _recargarLista();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${response['error'] ?? 'No se pudo guardar'}"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("Guardar",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- CONFIRMAR ELIMINACIÓN CON FEEDBACK ROJO ---
  void _confirmarEliminacion(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("¿Eliminar curso?"),
        content: const Text("Se eliminarán todos los datos relacionados. Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final response = await _apiService.eliminarCurso(id);
              if (mounted) {
                Navigator.pop(context);
                if (response['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Curso eliminado con éxito",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  _recargarLista();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error: no se puede eliminar el curso porque tiene datos relacionados"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            child: const Text("Sí, eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Cursos",
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _listaCursosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }
          final cursos = snapshot.data ?? [];

          if (cursos.isEmpty) {
            return Center(
                child: Text("No hay cursos registrados", style: TextStyle(color: slateGrey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final item = cursos[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primaryPurple.withOpacity(0.1),
                    child: Icon(Icons.class_, color: primaryPurple, size: 20),
                  ),
                  title: Text(item['nombre'] ?? 'Curso',
                      style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
                  subtitle: Text("ID: ${item['id_curso'] ?? '---'}",
                      style: TextStyle(color: slateGrey, fontSize: 13)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionIcon(Icons.edit_outlined, Colors.blue.shade300, () {
                        _mostrarDialogoCurso(cursoEditar: item);
                      }),
                      const SizedBox(width: 8),
                      _actionIcon(Icons.delete_outline, Colors.red.shade300,
                          () => _confirmarEliminacion(item['id_curso'])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkBlue,
        onPressed: () => _mostrarDialogoCurso(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo Curso",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}