import 'package:flutter/material.dart';

class loading extends StatelessWidget {
  const loading({
    super.key,
  });

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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/cargando.gif',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 10),
              const Text(
                "Cargando...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}