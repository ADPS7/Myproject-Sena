import 'package:flutter/material.dart';

class NotasEstudiante extends StatelessWidget {

  final List<Map<String, dynamic>> notas = [
    {"materia": "Matemáticas", "nota": 4.5},
    {"materia": "Español", "nota": 4.0},
    {"materia": "Inglés", "nota": 3.8},
    {"materia": "Ciencias", "nota": 4.2},
    {"materia": "Historia", "nota": 3.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nota"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: notas.length,
        itemBuilder: (context, index) {

          final materia = notas[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.book, color: Colors.blue),
              title: Text(
                materia["materia"],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                materia["nota"].toString(),
                style: TextStyle(
                  fontSize: 18,
                  color: materia["nota"] >= 3 ? const Color.fromARGB(255, 253, 56, 1) : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}