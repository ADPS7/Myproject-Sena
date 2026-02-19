import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class mainView extends StatelessWidget {
  const mainView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff4988C4),
        title: Row(
          children: [
            Image.asset('assets/images/logo-app.png', height: 62),
            SizedBox(width: 10),
            Text("Lucy",
            style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:0 ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 295,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16/9,
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    viewportFraction: 1.1,
                  ), 
                  items: [
                    "assets/images/preview1.jpg",
                    "assets/images/preview2.jpg",
                    "assets/images/preview3.jpg",
                    "assets/images/preview4.jpg",
                    "assets/images/preview5.jpg",
                  ].map((imagePath){
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(9.0),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (){
              
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)
                            ),
                          ),
                          child: const Text(
                            "Iniciar Sesión",
                            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)
                            ),
                          ),
                          child: const Text(
                            "Registrarse",
                            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}