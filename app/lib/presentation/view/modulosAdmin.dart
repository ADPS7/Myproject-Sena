import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NECESARIO PARA FILTROS
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

  @override
  void dispose() {
    _nombreController.dispose();
    _inicioController.dispose();
    _finController.dispose();
    super.dispose();
  }

  void _recargarLista() {
    setState(() {
      _listaModulosFuture = _apiService.getModulos();
    });
  }

  bool _validarFechas() {
    if (_inicioController.text.isEmpty || _finController.text.isEmpty) return false;
    try {
      DateTime inicio = DateTime.parse(_inicioController.text.split(' ')[0]);
      DateTime fin = DateTime.parse(_finController.text.split(' ')[0]);
      return inicio.isBefore(fin) || inicio.isAtSameMomentAs(fin);
    } catch (e) {
      return false;
    }
  }

  bool _inicioEsHoyOPosterior() {
    if (_inicioController.text.isEmpty) return false;
    try {
      DateTime inicio = DateTime.parse(_inicioController.text.split(' ')[0]);
      final hoy = DateTime.now();
      final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);
      return !inicio.isBefore(fechaHoy);
    } catch (e) {
      return false;
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: slateGrey, size: 20),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPurple.withOpacity(0.5), width: 2)),
    );
  }

  Widget _actionIcon(IconData icon, Color? color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (color ?? Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Future<void> _mostrarDialogoModulo(List<dynamic> cursos, {Map<String, dynamic>? moduloEditar}) async {
    _nombreController.clear();
    _inicioController.clear();
    _finController.clear();
    _idCursoSeleccionado = null;

    if (moduloEditar != null) {
      _nombreController.text = moduloEditar['nombre'].toString();
      if (moduloEditar['fecha_inicio'] != null) _inicioController.text = moduloEditar['fecha_inicio'].toString().split(' ')[0];
      if (moduloEditar['fecha_fin'] != null) _finController.text = moduloEditar['fecha_fin'].toString().split(' ')[0];
      _idCursoSeleccionado = moduloEditar['id_curso'];
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: softBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(moduloEditar == null ? "Nuevo Módulo" : "Editar Módulo", style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  TextField(
                    controller: _nombreController,
                    // PERMITE EDITAR SIEMPRE, PERO SOLO LETRAS
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
                    ],
                    decoration: _inputStyle("Nombre", Icons.edit_note),
                  ),
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
                      child: Text(curso['nombre'], overflow: TextOverflow.ellipsis, style: TextStyle(color: darkBlue)),
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
              style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                final nombre = _nombreController.text.trim();
                if (nombre.isEmpty || _idCursoSeleccionado == null || _inicioController.text.isEmpty || _finController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Completa todos los campos"), backgroundColor: Colors.orange));
                  return;
                }
                if (!_validarFechas()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error en las fechas"), backgroundColor: Colors.redAccent));
                  return;
                }
                if (moduloEditar == null && !_inicioEsHoyOPosterior()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La fecha de inicio debe ser hoy o posterior"), backgroundColor: Colors.redAccent));
                  return;
                }
                try {
                  Map<String, dynamic> res;
                  if (moduloEditar == null) {
                    res = await _apiService.crearModulo(nombre, _inicioController.text, _finController.text, _idCursoSeleccionado!);
                  } else {
                    res = await _apiService.editarModulo(moduloEditar['id_modulo'], nombre, _inicioController.text, _finController.text, _idCursoSeleccionado!);
                  }
                  if (!mounted) return;
                  if (res['success'] == true || res['status'] == 'success') {
                    Navigator.pop(context);
                    _recargarLista();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(moduloEditar == null ? "Módulo creado" : "Módulo actualizado"), backgroundColor: Colors.green));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['error']}")));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String label) => TextField(
    controller: controller,
    readOnly: true,
    onTap: () async {
      DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
      if (picked != null) controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    },
    decoration: _inputStyle(label, Icons.calendar_today_outlined),
  );

  void _confirmarEliminacion(int id) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("¿Eliminar módulo?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () async {
          final res = await _apiService.eliminarModulo(id);
          if (mounted) { Navigator.pop(context); if (res['success'] == true) _recargarLista(); }
        }, child: const Text("Eliminar")),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(title: Text("Módulos", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: FutureBuilder<List<dynamic>>(
        future: _listaModulosFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final modulos = snapshot.data!;
          return ListView.builder(
            itemCount: modulos.length,
            itemBuilder: (context, index) {
              final item = modulos[index];
              return ListTile(
                title: Text(item['nombre']),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  _actionIcon(Icons.edit, Colors.blue, () async {
                    final cursos = await _apiService.getCursos();
                    if (mounted) _mostrarDialogoModulo(cursos, moduloEditar: item);
                  }),
                  _actionIcon(Icons.delete, Colors.red, () => _confirmarEliminacion(item['id_modulo'])),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final cursos = await _apiService.getCursos();
          if (mounted) _mostrarDialogoModulo(cursos);
        },
      ),
    );
  }
}