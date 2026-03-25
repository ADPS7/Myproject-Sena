import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotasView extends StatefulWidget {
  final int estudianteId;

  const NotasView({super.key, required this.estudianteId});

  @override
  State<NotasView> createState() => _NotasViewState();
}

class _NotasViewState extends State<NotasView> {
  List notas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotas();
  }

  Future<void> fetchNotas() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/notas/${widget.estudianteId}')
    );

    if (response.statusCode == 200) {
      setState(() {
        notas = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar notas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notas.isEmpty
              ? const Center(child: Text('No hay notas disponibles'))
              : ListView.builder(
                  itemCount: notas.length,
                  itemBuilder: (context, index) {
                    final nota = notas[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(nota['modulo']),
                        subtitle: Text('Nota: ${nota['nota']}'),
                        trailing: Icon(
                          Icons.grade,
                          color: nota['nota'] >= 3 ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}