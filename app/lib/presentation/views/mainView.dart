import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';
import 'Error.dart';
import 'Home_Page.dart';
import 'loading.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoadSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  HomePage()),
          );
        }
      },
      builder: (context, state) {
        if (state is HomeLoadInProgress) return const loading();
        if (state is HomeLoadFailure) return const ErrorView();

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xffF0FFDF), Color(0xffBDE8F5), Color(0xff4988C4),
                  Color(0xff1C4D8D), Color(0xff0F2854)
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
                      ),
                      const SizedBox(height: 10),
                      const Text("¡Hola de Nuevo!", style: TextStyle(fontSize: 34, color: Color(0xff0D1A63), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 25),
                      // ... Campos de texto (Email/Password) igual que antes
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: FilledButton(
                          onPressed: () => context.read<HomeBloc>().add(HomeSearchPressed()),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff0D1A63),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Text("Iniciar Sesión"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}