import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para los filtros de entrada en tiempo real

import '../../services/api_service.dart';

class AjustesScreen extends StatefulWidget {
  final Map<String, dynamic> user; // Trae 'nombres', 'apellidos', 'correo', 'id_usuario' del Login
  const AjustesScreen({super.key, required this.user});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final ApiService _apiService = ApiService();

  // Controladores de la tabla Usuarios
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

  // Variables para Dropdowns de DatosUsuarios
  String? selectedTipoDocumento;
  String? selectedEstrato;
  String? selectedSexo;

  bool isLoading = false;       // Controla el estado del botón Guardar
  bool isFetching = true;       // Controla la pantalla de carga inicial al traer los datos
  bool isEditing = false;       // Controla si los campos están habilitados para edición
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();

    // 1. Inicializar datos que ya están en memoria (Vienen desde la tabla Usuarios)
    nombresController = TextEditingController(text: (widget.user['nombres'] ?? '').toString());
    apellidosController = TextEditingController(text: (widget.user['apellidos'] ?? '').toString());
    emailController = TextEditingController(text: (widget.user['correo'] ?? '').toString());
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    String fechaRaw = widget.user['fecha_nacimiento']?.toString() ?? '';
    String fechaLimpia = "";
    if (fechaRaw.isNotEmpty) {
      try {
        final date = DateTime.parse(fechaRaw);
        fechaLimpia = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } catch (_) {
        fechaLimpia = fechaRaw.split(' ')[0];
      }
    }
    fechaController = TextEditingController(text: fechaLimpia);

    // 2. Inicializar controladores de la tabla DatosUsuarios temporalmente vacíos
    direccionController = TextEditingController();
    departamentoController = TextEditingController();
    municipioController = TextEditingController();
    telefonoController = TextEditingController();
    telefonoEmergenciaController = TextEditingController();
    numeroDocumentoController = TextEditingController();
    epsController = TextEditingController();

    // 3. Llamar automáticamente al servidor de Python para traer y mostrar los datos adicionales
    _cargarDatosDesdeServidor();
  }

  // MÉTODO PRINCIPAL: Trae los datos desde Python y rellena los campos automáticamente
  Future<void> _cargarDatosDesdeServidor() async {
    try {
      final result = await _apiService.obtenerDatosAdicionales(widget.user['id_usuario']);

      if (result['success'] == true && result['existe'] == true) {
        final datosBD = result['data'];

        setState(() {
          direccionController.text = (datosBD['direccion'] ?? '').toString();
          departamentoController.text = (datosBD['departamento'] ?? '').toString();
          municipioController.text = (datosBD['municipio'] ?? '').toString();
          telefonoController.text = (datosBD['telefono'] ?? '').toString();
          telefonoEmergenciaController.text = (datosBD['telefono_emergencia'] ?? '').toString();
          numeroDocumentoController.text = (datosBD['numero_documento'] ?? '').toString();
          epsController.text = (datosBD['eps'] ?? '').toString();

          // Validaciones de enums para los DropdownFields
          List<String> tiposDoc = ['DNI', 'Pasaporte', 'Cedula de Extranjería', 'Cedula', 'Tarjeta de Identidad'];
          if (tiposDoc.contains(datosBD['tipo_documento'])) {
            selectedTipoDocumento = datosBD['tipo_documento'];
          }

          List<String> estratos = ['1', '2', '3', '4', '5', '6'];
          if (estratos.contains(datosBD['Estrato']?.toString())) {
            selectedEstrato = datosBD['Estrato'].toString();
          }

          List<String> sexos = ['M', 'F', 'O'];
          if (sexos.contains(datosBD['Sexo'])) {
            selectedSexo = datosBD['Sexo'];
          }

          isFetching = false; // Desactiva el indicador de carga global
        });
      } else {
        // Si el usuario es nuevo y no tiene datos guardados en esta tabla, abrimos el formulario limpio
        setState(() => isFetching = false);
      }
    } catch (e) {
      setState(() => isFetching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar e intentar cargar datos: $e"), backgroundColor: Colors.red),
      );
    }
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
    );

    if (picked != null) {
      setState(() {
        fechaController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveChanges() async {
    // =========================================================================
    // INICIO DE VALIDACIONES ESTRICTAS (MISMAS DE LA WEB)
    // =========================================================================

    // REGLA 1: Todos los campos del formulario son estrictamente obligatorios
    if (nombresController.text.trim().isEmpty ||
        apellidosController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        fechaController.text.trim().isEmpty ||
        direccionController.text.trim().isEmpty ||
        departamentoController.text.trim().isEmpty ||
        municipioController.text.trim().isEmpty ||
        telefonoController.text.trim().isEmpty ||
        telefonoEmergenciaController.text.trim().isEmpty ||
        numeroDocumentoController.text.trim().isEmpty ||
        epsController.text.trim().isEmpty ||
        selectedSexo == null ||
        selectedTipoDocumento == null ||
        selectedEstrato == null) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Todos los campos son estrictamente obligatorios para poder guardar."), backgroundColor: Colors.red),
      );
      return;
    }

    // REGLA 2: Formato del correo electrónico mediante expresión regular (Regex)
    final regexCorreo = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$');
    if (!regexCorreo.hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Por favor, ingresa un correo electrónico válido."), backgroundColor: Colors.red),
      );
      return;
    }

    // REGLA 3: Validación de edad mínima (Mayor de 16 años)
    try {
      final fechaNac = DateTime.parse(fechaController.text.trim());
      final fechaActual = DateTime.now();
      int edad = fechaActual.year - fechaNac.year;
      if (fechaActual.month < fechaNac.month || (fechaActual.month == fechaNac.month && fechaActual.day < fechaNac.day)) {
        edad--;
      }
      
      if (edad < 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Restricción de edad: Debes tener al menos 16 años para registrarte."), backgroundColor: Colors.orange),
        );
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Formato de fecha de nacimiento incorrecto."), backgroundColor: Colors.red),
      );
      return;
    }

    // REGLA 4: Formato estricto de Teléfonos Colombianos
    String telefonoMovil = telefonoController.text.trim();
    String telefonoEmergencia = telefonoEmergenciaController.text.trim();

    if (telefonoMovil.length != 10 || !telefonoMovil.startsWith('3')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ El Teléfono Móvil debe tener 10 dígitos y comenzar con 3."), backgroundColor: Colors.red),
      );
      return;
    }

    if (telefonoEmergencia.length != 10 || !telefonoEmergencia.startsWith('3')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ El Teléfono de Emergencia debe tener 10 dígitos y comenzar con 3."), backgroundColor: Colors.red),
      );
      return;
    }

    // REGLA 5: Números telefónicos no idénticos
    if (telefonoMovil == telefonoEmergencia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ El número de teléfono móvil no puede ser el mismo que el de emergencia"), 
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    // REGLA 6: Coincidencia de contraseñas si decide cambiarla
    if (passwordController.text.isNotEmpty) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Las contraseñas ingresadas no coinciden."), backgroundColor: Colors.red),
        );
        return;
      }
    }

    // =========================================================================
    // FIN DE VALIDACIONES - ENVIAR AL SERVIDOR ORIGINAL
    // =========================================================================

    setState(() => isLoading = true);

    try {
      // Mantenemos intacta tu llamada original al ApiService
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
          const SnackBar(content: Text("✅ Todos los datos se han actualizado correctamente"), backgroundColor: Colors.green),
        );
        passwordController.clear();
        confirmPasswordController.clear();
        setState(() => isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? "Error al actualizar"), backgroundColor: Colors.red),
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
        shape: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      // Condicional de Carga: Muestra un círculo mientras consulta a Python. Al terminar pinta todo el formulario.
      body: isFetching
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: primaryPurple.withOpacity(0.1),
                      child: Icon(Icons.person_rounded, size: 55, color: primaryPurple),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Datos Personales", Icons.badge_rounded, primaryPurple),
                        _buildTextField(
                          "Nombres", 
                          nombresController, 
                          isEditing, 
                          Icons.person_outline_rounded,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'))] // Solo letras y espacios en tiempo real
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          "Apellidos", 
                          apellidosController, 
                          isEditing, 
                          Icons.person_outline_rounded,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'))] // Solo letras y espacios en tiempo real
                        ),
                        const SizedBox(height: 18),
                        _buildTextField("Correo Electrónico", emailController, isEditing, Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: isEditing ? () => _seleccionarFecha(context) : null,
                          child: AbsorbPointer(
                            absorbing: true, // Bloqueado siempre para obligar a usar el DatePicker sin abrir teclado nativo
                            child: _buildTextField("Fecha de Nacimiento", fechaController, isEditing, Icons.calendar_month_rounded, readOnly: true),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildDropdownField("Sexo", selectedSexo, ['M', 'F', 'O'], (val) => setState(() => selectedSexo = val), isEditing, Icons.wc_rounded),

                        const SizedBox(height: 28),

                        _buildSectionHeader("Documentación y Salud", Icons.assignment_ind_outlined, primaryPurple),
                        _buildDropdownField("Tipo de Documento", selectedTipoDocumento, ['DNI', 'Pasaporte', 'Cedula de Extranjería', 'Cedula', 'Tarjeta de Identidad'], (val) => setState(() => selectedTipoDocumento = val), isEditing, Icons.subtitles_rounded),
                        const SizedBox(height: 18),
                        _buildTextField(
                          "Número de Documento", 
                          numeroDocumentoController, 
                          isEditing, 
                          Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly] // Bloquea letras en tiempo real
                        ),
                        const SizedBox(height: 18),
                        _buildTextField("EPS", epsController, isEditing, Icons.health_and_safety_outlined),

                        const SizedBox(height: 28),

                        _buildSectionHeader("Ubicación y Contacto", Icons.home_work_outlined, primaryPurple),
                        _buildTextField("Dirección residencial", direccionController, isEditing, Icons.location_on_outlined),
                        const SizedBox(height: 18),
                        _buildTextField("Departamento", departamentoController, isEditing, Icons.map_outlined),
                        const SizedBox(height: 18),
                        _buildTextField("Municipio / Ciudad", municipioController, isEditing, Icons.location_city_outlined),
                        const SizedBox(height: 18),
                        _buildTextField(
                          "Teléfono Móvil", 
                          telefonoController, 
                          isEditing, 
                          Icons.phone_android_rounded, 
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)] // Bloquea letras y limita a 10 dígitos
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          "Teléfono de Emergencia", 
                          telefonoEmergenciaController, 
                          isEditing, 
                          Icons.contact_phone_outlined, 
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)] // Bloquea letras y limita a 10 dígitos
                        ),
                        const SizedBox(height: 18),
                        _buildDropdownField("Estrato Socioeconómico", selectedEstrato, ['1', '2', '3', '4', '5', '6'], (val) => setState(() => selectedEstrato = val), isEditing, Icons.layers_outlined),

                        const SizedBox(height: 28),

                        _buildSectionHeader("Seguridad & Contraseña", Icons.lock_outline_rounded, primaryPurple),
                        _buildPasswordField("Nueva Contraseña", passwordController, isEditing, _showPassword, () => setState(() => _showPassword = !_showPassword)),
                        const SizedBox(height: 18),
                        _buildPasswordField("Confirmar Contraseña", confirmPasswordController, isEditing, _showConfirmPassword, () => setState(() => _showConfirmPassword = !_showConfirmPassword)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() {
                            isEditing = !isEditing;
                            if (!isEditing) _cargarDatosDesdeServidor(); // Si cancela, vuelve a descargar los datos limpios de la base de datos
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEditing ? const Color(0xFF64748B) : primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(isEditing ? "Cancelar" : "Editar Perfil"),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Text("Guardar"),
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
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9))),
      ],
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    bool enabled, 
    IconData icon, {
    bool readOnly = false, 
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, // Argumento añadido para los filtros de texto en tiempo real
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged, bool enabled, IconData icon) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_open_rounded, size: 20, color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
        suffixIcon: enabled ? IconButton(icon: Icon(showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded), onPressed: onToggle) : null,
      ),
    );
  }
}