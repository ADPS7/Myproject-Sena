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

  late TextEditingController nombresController;
  late TextEditingController apellidosController;
  late TextEditingController emailController;
  late TextEditingController fechaController;
  
  // === NUEVO CONTROLADOR PARA CONTRASEÑA ===
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    nombresController = TextEditingController(text: widget.user['nombres'] ?? '');
    apellidosController = TextEditingController(text: widget.user['apellidos'] ?? '');
    emailController = TextEditingController(text: widget.user['correo'] ?? '');

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
        } catch (e2) {
          fechaLimpia = fechaRaw.split(' ')[0];
        }
      }
    }
    fechaController = TextEditingController(text: fechaLimpia);
  }

  // === FUNCIÓN PARA CAMBIAR SOLO CONTRASEÑA ===
  Future<void> _changePassword() async {
    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe tener al menos 6 caracteres"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      // Nota: Asegúrate de tener este método en tu api_service.dart
      final result = await _apiService.actualizarRol(widget.user['id_usuario'], passwordController.text.trim()); // Cambia por actualizarPassword si ya lo creaste

      if (result['success'] == true) {
        passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Contraseña actualizada correctamente"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cambiar contraseña: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (nombresController.text.trim().isEmpty || 
        apellidosController.text.trim().isEmpty || 
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombres, apellidos y correo son obligatorios"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await _apiService.actualizarPerfil(
        idUsuario: widget.user['id_usuario'],
        nombres: nombresController.text.trim(),
        apellidos: apellidosController.text.trim(),
        correo: emailController.text.trim(),
        fechaNacimiento: fechaController.text,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Datos actualizados correctamente"), backgroundColor: Colors.green),
        );
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
        title: const Text("Ajustes", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: primaryPurple,
                child: const Icon(Icons.person, size: 70, color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),

            // SECCIÓN: DATOS PERSONALES
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Datos Personales", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField("Nombres", nombresController, isEditing),
                  const SizedBox(height: 16),
                  _buildTextField("Apellidos", apellidosController, isEditing),
                  const SizedBox(height: 16),
                  _buildTextField("Correo Electrónico", emailController, isEditing),
                  const SizedBox(height: 16),
                  _buildTextField("Fecha de Nacimiento", fechaController, isEditing),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // === NUEVA SECCIÓN: SEGURIDAD (CONTRASEÑA) ===
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Seguridad", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Nueva Contraseña",
                      hintText: "La contraseña debe tener al menos 8 caracteres",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _changePassword,
                      icon: const Icon(Icons.lock_open, size: 18),
                      label: const Text("Actualizar Contraseña"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => isEditing = !isEditing),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing ? Colors.grey : primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(isEditing ? "Cancelar" : "Editar Perfil",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          : const Text("Guardar Cambios", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildTextField(String label, TextEditingController controller, bool enabled) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
      ),
    );
  }
}