import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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

  DateTime? selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        fechaController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget customTextField({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff4988C4),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (nombresController.text.isEmpty ||
        apellidosController.text.isEmpty ||
        emailController.text.isEmpty ||
        fechaController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiService = ApiService();
      final result = await apiService.createUser(
        nombres: nombresController.text,
        apellidos: apellidosController.text,
        correo: emailController.text,
        fechaNacimiento: fechaController.text,
        clave: passwordController.text,
      );

      if (result.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado exitosamente')),
        );
        nombresController.clear();
        apellidosController.clear();
        emailController.clear();
        fechaController.clear();
        passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['detail'] ?? 'Desconocido'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xffF0FFDF),
              Color(0xffBDE8F5),
              Color(0xff4988C4),
              Color(0xff1C4D8D),
              Color(0xff0F2854)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  Image.network(
                    "https://image2url.com/r2/default/images/1770490852326-698c5fd0-f5e1-48cc-8548-30eb28e1596b.png",
                    height: 120,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Crear Cuenta",
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xff0D1A63),
                    ),
                  ),

                  const SizedBox(height: 25),

                  customTextField(
                    hint: "Nombres",
                    controller: nombresController,
                  ),

                  const SizedBox(height: 10),

                  customTextField(
                    hint: "Apellidos",
                    controller: apellidosController,
                  ),

                  const SizedBox(height: 10),

                  customTextField(
                    hint: "Correo",
                    controller: emailController,
                  ),

                  const SizedBox(height: 10),

                  customTextField(
                    hint: "Fecha de Nacimiento",
                    controller: fechaController,
                    readOnly: true,
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: 10),

                  customTextField(
                    hint: "Contraseña",
                    controller: passwordController,
                    obscure: true,
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: FilledButton(
                      onPressed: isLoading ? null : _registerUser,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff0D1A63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Registrarse"),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
