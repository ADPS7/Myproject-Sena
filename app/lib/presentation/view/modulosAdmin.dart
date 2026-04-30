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

  // Paleta de colores equilibrada
  final Color primaryPurple = const Color(0xFF7C4DFF); 
  final Color softBg = const Color(0xFFF8FAFC);
  final Color darkBlue = const Color(0xFF334155);
  final Color slateGrey = const Color(0xFF94A3B8);

  late Future<List<dynamic>> _listaModulosFuture;

  @override
  void initState() {
    super.initState();
    _listaModulosFuture = _apiService.getModulos();
  }

  void _recargarLista() {
    setState(() {
      _listaModulosFuture = _apiService.getModulos();
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

  // Widget para los botones de editar/eliminar (Protección contra error de Color Null)
  Widget _actionIcon(IconData icon, Color? color, VoidCallback onTap) {
    final Color finalColor = color ?? Colors.grey; 
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: finalColor.withOpacity(0.1), 
          borderRadius: BorderRadius.circular(10)
        ),
        child: Icon(icon, color: finalColor, size: 20),
      ),
    );
  }

  // --- FORMULARIO DE REGISTRO/EDICIÓN ---
  Future<void> _mostrarDialogoModulo(List<dynamic> cursos, {Map<String, dynamic>? moduloEditar}) async {
    if (moduloEditar != null) {
      _nombreController.text = moduloEditar['nombre'];
      _inicioController.text = moduloEditar['fecha_inicio'];
      _finController.text = moduloEditar['fecha_fin'];
      _idCursoSeleccionado = moduloEditar['id_curso'];
    } else {
      _nombreController.clear();
      _inicioController.clear();
      _finController.clear();
      _idCursoSeleccionado = null;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: softBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            moduloEditar == null ? "Nuevo Módulo" : "Editar Módulo",
            style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  TextField(controller: _nombreController, decoration: _inputStyle("Nombre", Icons.edit_note)),
                  const SizedBox(height: 16),
                  _buildDateField(context, _inicioController, "Fecha Inicio"),
                  const SizedBox(height: 16),
                  _buildDateField(context, _finController, "Fecha Fin"),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _idCursoSeleccionado,
                    isExpanded: true,
                    decoration: _inputStyle("Asignar Curso", Icons.book_outlined),
                    items: cursos.map((curso) => DropdownMenuItem<int>(
                      value: curso['id_curso'], 
                      child: Text(curso['nombre'], overflow: TextOverflow.ellipsis, style: TextStyle(color: darkBlue, fontSize: 14))
                    )).toList(),
                    onChanged: (val) => setDialogState(() => _idCursoSeleccionado = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar", style: TextStyle(color: slateGrey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (_idCursoSeleccionado != null && _nombreController.text.isNotEmpty) {
                  if (moduloEditar == null) {
                    await _apiService.crearModulo(_nombreController.text, _inicioController.text, _finController.text, _idCursoSeleccionado!);
                  } else {
                    await _apiService.editarModulo(moduloEditar['id_modulo'], _nombreController.text, _inicioController.text, _finController.text, _idCursoSeleccionado!);
                  }
                  if (mounted) { Navigator.pop(context); _recargarLista(); }
                }
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String label) => TextField(
    controller: controller,
    readOnly: true,
    onTap: () async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        controller.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      }
    },
    decoration: _inputStyle(label, Icons.calendar_today_outlined),
  );

  void _confirmarEliminacion(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("¿Eliminar módulo?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _apiService.eliminarModulo(id);
              if (mounted) { Navigator.pop(context); _recargarLista(); }
            }, 
            child: const Text("Sí, eliminar", style: TextStyle(color: Colors.white))
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
        title: Text("Módulos", style: TextStyle(color: darkBlue, fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _listaModulosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }
          final modulos = snapshot.data ?? [];
          
          if (modulos.isEmpty) {
            return Center(child: Text("No hay módulos registrados", style: TextStyle(color: slateGrey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: modulos.length,
            itemBuilder: (context, index) {
              final item = modulos[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(item['nombre'] ?? 'Módulo', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
                  subtitle: Text("Inicia: ${item['fecha_inicio'] ?? '---'}", style: TextStyle(color: slateGrey, fontSize: 13)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionIcon(Icons.edit_outlined, Colors.blue.shade300, () async {
                        final cursos = await _apiService.getCursos();
                        if (mounted) _mostrarDialogoModulo(cursos, moduloEditar: item);
                      }),
                      const SizedBox(width: 8),
                      _actionIcon(Icons.delete_outline, Colors.red.shade300, () => _confirmarEliminacion(item['id_modulo'])),
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
        onPressed: () async {
          final cursos = await _apiService.getCursos();
          if (mounted) _mostrarDialogoModulo(cursos);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Añadir Módulo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}