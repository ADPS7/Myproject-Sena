import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NewPasswordView extends StatefulWidget {
  final String email;
  const NewPasswordView({super.key, required this.email});

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  final TextEditingController passController = TextEditingController();
  bool _isObscure = true;

  // Lógica de validación
  bool _hasMinLength(String p) => p.length >= 8;
  bool _hasUppercase(String p) => p.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String p) => p.contains(RegExp(r'[a-z]'));
  bool _hasNumber(String p) => p.contains(RegExp(r'[0-9]'));
  bool _hasSpecial(String p) => p.contains(RegExp(r'[!@#\$&*~]'));
  
  bool get _isAllValid => _hasMinLength(passController.text) && 
                         _hasUppercase(passController.text) && 
                         _hasLowercase(passController.text) && 
                         _hasNumber(passController.text) && 
                         _hasSpecial(passController.text);

  void _update() async {
    if (!_isAllValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La contraseña no cumple con todos los requisitos.")));
      return;
    }

    final res = await ApiService().updatePassword(widget.email, passController.text.trim());
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Contraseña actualizada!")));
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'] ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF1E293B))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(Icons.lock_open_rounded, size: 80, color: Color(0xFF7C4DFF)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))]),
                child: Column(
                  children: [
                    TextField(
                      controller: passController,
                      obscureText: _isObscure,
                      onChanged: (val) => setState(() {}), // Refresca la UI al escribir
                      decoration: InputDecoration(
                        labelText: "Nueva contraseña",
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7C4DFF)),
                        suffixIcon: IconButton(icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isObscure = !_isObscure)),
                        filled: true, fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Lista de validación visual
                    _validationTile("8+ caracteres", _hasMinLength(passController.text)),
                    _validationTile("Una mayúscula", _hasUppercase(passController.text)),
                    _validationTile("Una minúscula", _hasLowercase(passController.text)),
                    _validationTile("Un número", _hasNumber(passController.text)),
                    _validationTile("Un caracter especial", _hasSpecial(passController.text)),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, height: 58, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _isAllValid ? const Color(0xFF7C4DFF) : Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: _update, child: const Text("Actualizar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _validationTile(String text, bool isValid) {
    return Row(
      children: [
        Icon(isValid ? Icons.check_circle : Icons.radio_button_unchecked, color: isValid ? Colors.green : Colors.grey, size: 18),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: isValid ? Colors.green : Colors.grey, fontSize: 13)),
      ],
    );
  }
}