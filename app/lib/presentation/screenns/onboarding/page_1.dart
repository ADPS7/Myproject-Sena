import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class page_1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF7C4DFF),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('¡Estamos contigo!', style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),

          Lottie.asset('assets/animations/Learning.json',
          width: 300,
          height: 300,
          repeat: false,),
          
        const SizedBox(height: 40),
        const Text(
          'Bienvenido a la Plataforma Academica LLinasiano',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ],
      ),
    );
  }
}