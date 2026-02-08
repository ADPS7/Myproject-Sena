import 'package:flutter/material.dart';

class loginview extends StatelessWidget {
  const loginview({
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //imagen
                  Image.network("https://image2url.com/r2/default/images/1770490852326-698c5fd0-f5e1-48cc-8548-30eb28e1596b.png", height: 140,),
                  SizedBox( height: 10,),
                  //bienvenida
                  Text("¡Hola de Nuevo!", style: TextStyle( fontSize: 34, color: Color(0xff0D1A63)),),
                  SizedBox( height: 8,),
                  Text("Bienvenido de nuevo, te hemos extrañado", style: TextStyle( fontSize: 14, color: Color(0xff0D1A63)),),
                  SizedBox( height: 25,),
              
                  //email textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff4988C4),
                          border: Border.all( color: Colors.white),
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email'),),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
              
              
                  //password textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff4988C4),
                          border: Border.all( color: Colors.white),
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
    
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Contraseña'),),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  //boton de login  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: FilledButton(
                      onPressed: () {
                        // no hace nada por ahora
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff0D1A63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 56),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text("Iniciar Sesión"),
                    ),
                  ),
                  SizedBox(height: 35,)                
                  //boton de registro
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
