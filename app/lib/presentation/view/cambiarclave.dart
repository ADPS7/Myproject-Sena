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

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))]),
      child: child,
    );
  }

  void _update() async {
    final res = await ApiService().updatePassword(widget.email, passController.text.trim());
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contraseña actualizada")));
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['error'])));
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
              const SizedBox(height: 20),
              const Text("Nueva contraseña", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildCard(Column(
                children: [
                  TextField(controller: passController, obscureText: true, decoration: InputDecoration(labelText: "Nueva contraseña", prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7C4DFF)), filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 58, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: _update, child: const Text("Actualizar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}