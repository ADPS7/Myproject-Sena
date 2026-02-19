import 'package:app/presentation/views/login.dart';
import 'package:flutter/material.dart';

import 'registro.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromRGBO(124, 77, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(124, 77, 255, 1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            height: size.height / 3.5,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/instituto-removebg-preview.png',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '¡Bienvenido a la Apicacion! registra tus datos o inicia sesion para disfrutar.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                Image.asset(
                  'assets/images/imagen2.png',
                  width: 210,
                  height: 200,
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color.fromRGBO(124, 77, 255, 0.89),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Registrarse', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),

          SizedBox(height: 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color.fromRGBO(124, 77, 255, 0.89),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),

          SizedBox(height: 50),

          Text(
            'terminos y condiciones',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
