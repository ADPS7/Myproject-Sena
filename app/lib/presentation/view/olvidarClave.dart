import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'verificar_codigo.dart';


class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }

  Future<void> _handleResetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => isLoading = true);
    final result = await ApiService().checkEmailExists(email);
    if (result['exists'] == true) {
      final resetResponse = await ApiService().requestReset(email);
      setState(() => isLoading = false);
      if (mounted && resetResponse.containsKey('message')) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyCodeView(email: email)));
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['error'] ?? 'Error')));
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
              const Icon(Icons.lock_reset_rounded, size: 80, color: Color(0xFF7C4DFF)),
              const SizedBox(height: 20),
              const Text("Recuperar contraseña", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 30),
              _buildCard(Column(
                children: [
                  TextField(controller: emailController, decoration: InputDecoration(labelText: "Correo electrónico", prefixIcon: const Icon(Icons.email, color: Color(0xFF7C4DFF)), filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 58, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: isLoading ? null : _handleResetPassword, child: const Text("Verificar correo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}