import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Asegúrate de que estas rutas sean las correctas en tu proyecto
import '../bloc/home_bloc.dart';
import 'Error.dart';
import 'Home_Page.dart';
import 'homescreen.dart';
import 'loading.dart';

class LoginView extends StatelessWidget {
  const LoginView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      // Usamos 'child' con un 'Builder' para crear el nuevo contexto 
      // que el BlocConsumer necesita para encontrar al HomeBloc.
      child: Builder(
        builder: (newContext) {
          return BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeLoadSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  HomeScreen()),
                );
              }
            },
            builder: (context, state) {
              // 1. Manejo de estados de carga y error
              if (state is HomeLoadInProgress) {
                return const loading();
              } else if (state is HomeLoadFailure) {
                return const ErrorView();
              }

              // 2. Diseño del Login (Estado inicial)
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
                              height: 140,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.error, size: 100, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "¡Hola de Nuevo!",
                              style: TextStyle(
                                fontSize: 34, 
                                color: Color(0xff0D1A63), 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Bienvenido de nuevo, te hemos extrañado",
                              style: TextStyle(fontSize: 14, color: Color(0xff0D1A63)),
                            ),
                            const SizedBox(height: 25),

                            // Email Textfield
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xff4988C4),
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: TextField(
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        border: InputBorder.none, 
                                        hintText: 'Email',
                                        hintStyle: TextStyle(color: Colors.white70)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Password Textfield
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xff4988C4),
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: TextField(
                                    obscureText: true,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Contraseña',
                                        hintStyle: TextStyle(color: Colors.white70)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Botón de Inicio de Sesión
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 8.0),
                              child: FilledButton(
                                onPressed: () {
                                  // Disparamos el evento al Bloc
                                  context.read<HomeBloc>().add(HomeSearchPressed());
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xff0D1A63),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  minimumSize: const Size(double.infinity, 56),
                                ),
                                child: const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 35)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}