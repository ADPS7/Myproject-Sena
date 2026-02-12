import 'package:app/presentation/views/Home_Page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'presentation/screenns/onboarding/onboardingScreen.dart';
import 'presentation/views/Error.dart';
import 'presentation/views/loading.dart';
import 'presentation/views/login.dart';
import 'presentation/views/mainView.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplication Platform',
      debugShowCheckedModeBanner: false,
      home: mainView(),
    );
  }
}


