import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'cambiarclave.dart';

class VerifyCodeView extends StatefulWidget {
  final String email;
  const VerifyCodeView({super.key, required this.email});

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))]),
      child: child,
    );
  }

  void _verify() async {
    setState(() => isLoading = true);
    final res = await ApiService().verifyCode(widget.email, codeController.text.trim());
    setState(() => isLoading = false);
    if (res['success'] == true) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NewPasswordView(email: widget.email)));
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
              const Icon(Icons.mark_email_read_rounded, size: 80, color: Color(0xFF7C4DFF)),
              const SizedBox(height: 20),
              const Text("Verificar código", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildCard(Column(
                children: [
                  TextField(controller: codeController, keyboardType: TextInputType.number, maxLength: 6, decoration: InputDecoration(labelText: "Código de 6 dígitos", prefixIcon: const Icon(Icons.pin, color: Color(0xFF7C4DFF)), filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 58, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: isLoading ? null : _verify, child: const Text("Validar código", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}