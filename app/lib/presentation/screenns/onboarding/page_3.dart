import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class page_3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF7C4DFF),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('¿Que esperas?', style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),

          Lottie.asset('assets/animations/Book.json',
          width: 300,
          height: 300,
          repeat: false,),
          
        const SizedBox(height: 40),
        const Text(
          '¡Únete a nosotros y comienza tu viaje académico con LLinasiano!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        ],
      ),
    );
  }
}