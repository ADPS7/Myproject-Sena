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

  void _recargarLista() {
    setState(() {
      _listaModulosFuture = _apiService.getModulos();
    });
  }

  // --- FORMULARIO PARA CREAR O EDITAR ---
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
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(moduloEditar == null ? "Registrar Módulo" : "Editar Módulo",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff0D1A63))),
                  const SizedBox(height: 20),
                  _buildTextField(_nombreController, "Nombre del Módulo", Icons.title),
                  const SizedBox(height: 10),
                  _buildDateField(context, _inicioController, "Fecha Inicio"),
                  const SizedBox(height: 10),
                  _buildDateField(context, _finController, "Fecha Fin"),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        value: _idCursoSeleccionado,
                        isExpanded: true,
                        hint: const Text("Seleccione un curso"),
                        items: cursos.map((curso) => DropdownMenuItem<int>(value: curso['id_curso'], child: Text(curso['nombre']))).toList(),
                        onChanged: (val) => setDialogState(() => _idCursoSeleccionado = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff0D1A63), foregroundColor: Colors.white),
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
                        child: const Text("Guardar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- DIÁLOGO DE CONFIRMACIÓN PARA ELIMINAR ---
  void _confirmarEliminacion(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Estás seguro de que deseas eliminar este módulo?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _apiService.eliminarModulo(id);
              if (mounted) { Navigator.pop(context); _recargarLista(); }
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) => TextField(controller: controller, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)));
  
  Widget _buildDateField(BuildContext context, TextEditingController controller, String label) => TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2026), lastDate: DateTime(2100));
        if (pickedDate != null) controller.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      },
      decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(title: const Text("Gestión de Módulos"), backgroundColor: const Color(0xff0D1A63), foregroundColor: Colors.white),
      body: FutureBuilder<List<dynamic>>(
        future: _listaModulosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No hay módulos registrados"));
          final modulos = snapshot.data!;
          return ListView.builder(
            itemCount: modulos.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => Card(
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xff0D1A63), child: Icon(Icons.view_module, color: Colors.white)),
                title: Text(modulos[index]['nombre']),
                subtitle: Text("Inicio: ${modulos[index]['fecha_inicio']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Color(0xff0D1A63)), onPressed: () async {
                      final cursos = await _apiService.getCursos();
                      if (mounted) _mostrarDialogoModulo(cursos, moduloEditar: modulos[index]);
                    }),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminacion(modulos[index]['id_modulo'])),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0D1A63),
        onPressed: () async {
          final cursos = await _apiService.getCursos();
          if (mounted) _mostrarDialogoModulo(cursos);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}