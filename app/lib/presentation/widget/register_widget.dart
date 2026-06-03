import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'login_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    nombresController.dispose();
    apellidosController.dispose();
    emailController.dispose();
    fechaController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      body: Stack(
        children: [
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: size.width * 0.8,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: size.height * 0.2,
            child: Container(
              width: 4,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.network(
                    "https://image2url.com/r2/default/images/1770490852326-698c5fd0-f5e1-48cc-8548-30eb28e1596b.png",
                    height: 90,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.school_rounded,
                      size: 90,
                      color: Color(0xFF7C4DFF),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Crear Cuenta",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Regístrate para acceder a Edullinas",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _customInput(
                          hint: "Nombres",
                          controller: nombresController,
                          icon: Icons.person_outline,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'))],
                        ),
                        const SizedBox(height: 15),
                        _customInput(
                          hint: "Apellidos",
                          controller: apellidosController,
                          icon: Icons.badge_outlined,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]'))],
                        ),
                        const SizedBox(height: 15),
                        _customInput(
                          hint: "Correo",
                          controller: emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: _customInput(
                              hint: "Fecha de Nacimiento",
                              controller: fechaController,
                              icon: Icons.calendar_today_outlined,
                              readOnly: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _customInput(
                          hint: "Contraseña",
                          controller: passwordController,
                          icon: Icons.lock_outline,
                          isPassword: true,
                          helperText: "Mínimo 7 caracteres: incluye 1 mayúscula, 1 minúscula, 1 número y 1 símbolo.",
                        ),
                        const SizedBox(height: 35),
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customInput({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF7C4DFF)),
        helperText: helperText,
        helperMaxLines: 2,
        helperStyle: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 11.5, fontWeight: FontWeight.w500),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                "Registrarse",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        fechaController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _registerUser() async {
    final String nombres = nombresController.text.trim();
    final String apellidos = apellidosController.text.trim();
    final String email = emailController.text.trim();
    final String fecha = fechaController.text.trim();
    final String password = passwordController.text;

    // 1. Validación de campos completamente vacíos
    if (nombres.isEmpty || apellidos.isEmpty || email.isEmpty || fecha.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Por favor completa todos los campos"), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validación estricta del Correo Electrónico (Regex)
    final regexCorreo = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$');
    if (!regexCorreo.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Ingresa un correo electrónico válido"), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Validación de edad mínima (Mayor o igual a 16 años)
    try {
      final fechaNac = DateTime.parse(fecha);
      final fechaActual = DateTime.now();
      int edad = fechaActual.year - fechaNac.year;
      if (fechaActual.month < fechaNac.month || (fechaActual.month == fechaNac.month && fechaActual.day < fechaNac.day)) {
        edad--;
      }
      if (edad < 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Debes tener al menos 16 años para registrarte"), backgroundColor: Colors.orange),
        );
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Formato de fecha de nacimiento incorrecto"), backgroundColor: Colors.red),
      );
      return;
    }

    // 4. Validación de Contraseña Completa (Mínimo 7 caracteres, Mayúscula, Minúscula, Número y Símbolo)
    if (password.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ La contraseña debe tener como mínimo 7 caracteres"), backgroundColor: Colors.red),
      );
      return;
    }

    final tieneMayuscula = RegExp(r'[A-Z]');
    final tieneMinuscula = RegExp(r'[a-z]');
    final tieneNumero = RegExp(r'[0-9]');
    final tieneSimbolo = RegExp(r'[!@#$%^&*(),.?":{}|<>_+\-\[\]\\\/`~;]');

    if (!tieneMayuscula.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ La contraseña debe incluir al menos una letra mayúscula"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!tieneMinuscula.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ La contraseña debe incluir al menos una letra minúscula"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!tieneNumero.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ La contraseña debe incluir al menos un número"), backgroundColor: Colors.red),
      );
      return;
    }

    if (!tieneSimbolo.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ La contraseña debe incluir al menos un símbolo especial (@, =, #, &, !, %, etc.)"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService().createUser(
        nombres: nombres,
        apellidos: apellidos,
        correo: email,
        fechaNacimiento: fecha,
        clave: password,
      );

      if (result['message']?.toString().contains("exitosamente") == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Registro exitoso! Ahora puedes iniciar sesión"),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
            (route) => false,
          );
        }
      } else {
        String errorMsg = result['error']?.toString() ?? "Error al registrar usuario";

        if (errorMsg.toLowerCase().contains("correo") ||
            errorMsg.toLowerCase().contains("duplicate") ||
            errorMsg.toLowerCase().contains("ya existe")) {
          errorMsg = "Este correo electrónico ya está registrado";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de conexión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}