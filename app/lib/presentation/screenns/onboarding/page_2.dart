import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class page_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF7C4DFF),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('¿Qué ofrecemos?', style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),

          Lottie.asset('assets/animations/Teacher.json',
          width: 300,
          height: 300,
          repeat: false,),
          
        const SizedBox(height: 40),
        const Text(
          'Ofrecemos una amplia variedad de modulos en diferentes áreas de conocimiento, una excelente experiencia en el proceso del control de notas y asistencias.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        ],
      ),
    );
  }
}

