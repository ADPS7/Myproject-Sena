import 'dart:ui';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class AjustesScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const AjustesScreen({super.key, required this.user});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final ApiService _apiService = ApiService();

  // Controladores principales
  late TextEditingController nombresController;
  late TextEditingController apellidosController;
  late TextEditingController emailController;
  late TextEditingController fechaController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // Controladores de la tabla DatosUsuarios
  late TextEditingController direccionController;
  late TextEditingController departamentoController;
  late TextEditingController municipioController;
  late TextEditingController telefonoController;
  late TextEditingController telefonoEmergenciaController;
  late TextEditingController numeroDocumentoController;
  late TextEditingController epsController;

  // Variables para Dropdowns
  String? selectedTipoDocumento;
  String? selectedEstrato;
  String? selectedSexo;

  bool isLoading = false;
  bool isEditing = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();

    // Inicialización segura contra valores nulos (Previene LateInitializationError)
    nombresController = TextEditingController(text: (widget.user['nombres'] ?? '').toString());
    apellidosController = TextEditingController(text: (widget.user['apellidos'] ?? '').toString());
    emailController = TextEditingController(text: (widget.user['correo'] ?? '').toString());
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    direccionController = TextEditingController(text: (widget.user['direccion'] ?? '').toString());
    departamentoController = TextEditingController(text: (widget.user['departamento'] ?? '').toString());
    municipioController = TextEditingController(text: (widget.user['municipio'] ?? '').toString());
    telefonoController = TextEditingController(text: (widget.user['telefono'] ?? '').toString());
    telefonoEmergenciaController = TextEditingController(text: (widget.user['telefono_emergencia'] ?? '').toString());
    numeroDocumentoController = TextEditingController(text: (widget.user['numero_documento'] ?? '').toString());
    epsController = TextEditingController(text: (widget.user['eps'] ?? '').toString());

    // Validar y asignar Dropdowns
    List<String> tiposDoc = ['DNI', 'Pasaporte', 'Cedula de Extranjería', 'Cedula', 'Tarjeta de Identidad'];
    if (tiposDoc.contains(widget.user['tipo_documento'])) {
      selectedTipoDocumento = widget.user['tipo_documento'];
    }

    List<String> estratos = ['1', '2', '3', '4', '5', '6'];
    if (estratos.contains(widget.user['Estrato']?.toString())) {
      selectedEstrato = widget.user['Estrato'].toString();
    }

    List<String> sexos = ['M', 'F', 'O'];
    if (sexos.contains(widget.user['Sexo'])) {
      selectedSexo = widget.user['Sexo'];
    }

    // Parseo de fechas seguro
    String fechaRaw = widget.user['fecha_nacimiento']?.toString() ?? '';
    String fechaLimpia = "";

    if (fechaRaw.isNotEmpty) {
      try {
        final date = DateTime.parse(fechaRaw);
        fechaLimpia = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } catch (e) {
        try {
          RegExp regExp = RegExp(r'(\d{1,2}) (\w{3}) (\d{4})');
          Match? match = regExp.firstMatch(fechaRaw);

          if (match != null) {
            int day = int.parse(match.group(1)!);
            String monthStr = match.group(2)!;
            int year = int.parse(match.group(3)!);

            Map<String, int> months = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
              'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            };

            int month = months[monthStr] ?? 1;
            fechaLimpia = "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
          }
        } catch (_) {
          fechaLimpia = fechaRaw.split(' ')[0];
        }
      }
    }

    fechaController = TextEditingController(text: fechaLimpia);
  }

  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    emailController.dispose();
    fechaController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    direccionController.dispose();
    departamentoController.dispose();
    municipioController.dispose();
    telefonoController.dispose();
    telefonoEmergenciaController.dispose();
    numeroDocumentoController.dispose();
    epsController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (fechaController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(fechaController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C4DFF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fechaController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveChanges() async {
    // 1. Validaciones de campos obligatorios básicos
    if (nombresController.text.trim().isEmpty || 
        apellidosController.text.trim().isEmpty || 
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombres, apellidos y correo son obligatorios"), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validaciones de Dropdowns seleccionados
    if (selectedSexo == null || selectedTipoDocumento == null || selectedEstrato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa los campos de Sexo, Tipo de Documento y Estrato"), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. VALIDACIÓN: Teléfono Móvil vs Teléfono de Emergencia
    String telefonoMovil = telefonoController.text.trim();
    String telefonoEmergencia = telefonoEmergenciaController.text.trim();

    if (telefonoMovil.isNotEmpty && telefonoEmergencia.isNotEmpty) {
      if (telefonoMovil == telefonoEmergencia) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ El número de teléfono móvil no puede ser el mismo que el de emergencia"), 
            backgroundColor: Colors.amber, // Color amarillo/advertencia
          ),
        );
        return; // Frena la ejecución del guardado
      }
    }

    // 4. Validación opcional de contraseña
    if (passwordController.text.isNotEmpty) {
      if (passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La contraseña debe tener mínimo 6 caracteres"), backgroundColor: Colors.red),
        );
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Las contraseñas no coinciden"), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      // Envío de todo el formulario unificado hacia la nueva ruta de Python
      final result = await _apiService.actualizarPerfilCompleto(
        idUsuario: widget.user['id_usuario'],
        nombres: nombresController.text.trim(),
        apellidos: apellidosController.text.trim(),
        correo: emailController.text.trim(),
        fechaNacimiento: fechaController.text,
        direccion: direccionController.text.trim(),
        departamento: departamentoController.text.trim(),
        municipio: municipioController.text.trim(),
        telefono: telefonoMovil,
        telefonoEmergencia: telefonoEmergencia,
        tipoDocumento: selectedTipoDocumento!,
        numeroDocumento: numeroDocumentoController.text.trim(),
        estrato: selectedEstrato!,
        sexo: selectedSexo!,
        eps: epsController.text.trim(),
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Todos los datos se han actualizado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        passwordController.clear();
        confirmPasswordController.clear();
        setState(() => isEditing = false);
      } else {
        // Muestra los errores controlados por Python (Ej: documento duplicado)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? "Error al actualizar"), 
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = const Color(0xFF7C4DFF);
    final Color bgGrey = const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text("Ajustes de Perfil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        surfaceTintColor: Colors.white,
        shape: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Sección Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryPurple, primaryPurple.withOpacity(0.4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryPurple.withOpacity(0.1),
                        child: Icon(Icons.person_rounded, size: 55, color: primaryPurple),
                      ),
                    ),
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Formulario en Bloques Estilizados
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BLOQUE 1: DATOS PERSONALES ---
                  _buildSectionHeader("Datos Personales", Icons.badge_rounded, primaryPurple),
                  _buildTextField("Nombres", nombresController, isEditing, Icons.person_outline_rounded),
                  const SizedBox(height: 18),
                  _buildTextField("Apellidos", apellidosController, isEditing, Icons.person_outline_rounded),
                  const SizedBox(height: 18),
                  _buildTextField("Correo Electrónico", emailController, isEditing, Icons.mail_outline_rounded),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: isEditing ? () => _seleccionarFecha(context) : null,
                    child: AbsorbPointer(
                      absorbing: isEditing,
                      child: _buildTextField(
                        "Fecha de Nacimiento", 
                        fechaController, 
                        isEditing, 
                        Icons.calendar_month_rounded,
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildDropdownField(
                    "Sexo", 
                    selectedSexo, 
                    ['M', 'F', 'O'], 
                    (val) => setState(() => selectedSexo = val), 
                    isEditing, 
                    Icons.wc_rounded
                  ),

                  const SizedBox(height: 28),

                  // --- BLOQUE 2: DOCUMENTACIÓN Y SALUD ---
                  _buildSectionHeader("Documentación y Salud", Icons.assignment_ind_outlined, primaryPurple),
                  _buildDropdownField(
                    "Tipo de Documento", 
                    selectedTipoDocumento, 
                    ['DNI', 'Pasaporte', 'Cedula de Extranjería', 'Cedula', 'Tarjeta de Identidad'], 
                    (val) => setState(() => selectedTipoDocumento = val), 
                    isEditing, 
                    Icons.subtitles_rounded
                  ),
                  const SizedBox(height: 18),
                  _buildTextField("Número de Documento", numeroDocumentoController, isEditing, Icons.pin_outlined),
                  const SizedBox(height: 18),
                  _buildTextField("EPS", epsController, isEditing, Icons.health_and_safety_outlined),

                  const SizedBox(height: 28),

                  // --- BLOQUE 3: UBICACIÓN Y CONTACTO ---
                  _buildSectionHeader("Ubicación y Contacto", Icons.home_work_outlined, primaryPurple),
                  _buildTextField("Dirección residencial", direccionController, isEditing, Icons.location_on_outlined),
                  const SizedBox(height: 18),
                  _buildTextField("Departamento", departamentoController, isEditing, Icons.map_outlined),
                  const SizedBox(height: 18),
                  _buildTextField("Municipio / Ciudad", municipioController, isEditing, Icons.location_city_outlined),
                  const SizedBox(height: 18),
                  _buildTextField("Teléfono Móvil", telefonoController, isEditing, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                  const SizedBox(height: 18),
                  _buildTextField("Teléfono de Emergencia", telefonoEmergenciaController, isEditing, Icons.contact_phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 18),
                  _buildDropdownField(
                    "Estrato Socioeconómico", 
                    selectedEstrato, 
                    ['1', '2', '3', '4', '5', '6'], 
                    (val) => setState(() => selectedEstrato = val), 
                    isEditing, 
                    Icons.layers_outlined
                  ),

                  const SizedBox(height: 28),

                  // --- BLOQUE 4: SEGURIDAD ---
                  _buildSectionHeader("Seguridad & Contraseña", Icons.lock_outline_rounded, primaryPurple),
                  _buildPasswordField("Nueva Contraseña", passwordController, isEditing, _showPassword, () => setState(() => _showPassword = !_showPassword)),
                  const SizedBox(height: 18),
                  _buildPasswordField("Confirmar Contraseña", confirmPasswordController, isEditing, _showConfirmPassword, () => setState(() => _showConfirmPassword = !_showConfirmPassword)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botones de Acción inferior
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      isEditing = !isEditing;
                      if (!isEditing) {
                        passwordController.clear();
                        confirmPasswordController.clear();
                      }
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? const Color(0xFF64748B) : primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isEditing ? "Cancelar" : "Editar Perfil",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text("Guardar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color purpleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: purpleColor, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFF1F5F9)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool enabled, IconData icon, {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(color: enabled ? const Color(0xFF0F172A) : const Color(0xFF64748B), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged, bool enabled, IconData icon) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8)),
      style: TextStyle(color: enabled ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool enabled, bool showPassword, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: !showPassword,
      style: TextStyle(color: enabled ? const Color(0xFF0F172A) : const Color(0xFF64748B), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w400),
        prefixIcon: const Icon(Icons.lock_open_rounded, size: 20, color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
        suffixIcon: enabled ? IconButton(
          icon: Icon(showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFF64748B), size: 20),
          onPressed: onToggle,
        ) : null,
      ),
    );
  }
}