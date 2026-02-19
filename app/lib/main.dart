import 'package:app/presentation/views/Error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// REVISA EL NOMBRE 'app': Si tu proyecto se llama distinto en el pubspec.yaml, cámbialo.
import 'package:app/presentation/bloc/home_bloc.dart';
import 'package:app/presentation/views/login.dart';

import 'presentation/views/Home_Page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => HomeBloc())],
      child: MaterialApp(
        title: 'Tu App',
        debugShowCheckedModeBanner: false, // Quita la banda roja de "Debug"
        theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
        home: LoginView(),
      ),
    );
  }
}
