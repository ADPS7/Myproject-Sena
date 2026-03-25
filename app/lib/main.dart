import 'package:app/presentation/view/asiststudent.dart';
import 'package:app/presentation/view/nota.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app/presentation/bloc/home_bloc.dart';

import 'presentation/widget/home_widget.dart';

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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
        home: NotasView(estudianteId: 1),
      ),
    );
  }
}
