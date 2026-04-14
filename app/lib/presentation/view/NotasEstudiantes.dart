import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotasEstudiantesScreen extends StatelessWidget {
  final int idAlumno;
  const NotasEstudiantesScreen({
    super.key,
    required this.idAlumno,
  });

  Future<Map<String, dynamic>> _fetchNotas() async {
    final result = await ApiService().getNotasEstudiante(idAlumno);

    if (result['success'] == true) {
      return result;
    } else {
      throw Exception(result['error'] ?? 'Error al cargar datos');
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchNotas(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if(snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final data = snapshot.data !;
          final curso = data['curso'];
          final modulos = data['modulos'];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 160,
                floating: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A1E3A),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              curso, style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Tus notas por módulo",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
                )
              ),

              SliverToBoxAdapter(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modulos.length,
                  itemBuilder: (context, index) {
                    final modulo = modulos[index];
                    final notas = (modulo['notas'] as List<dynamic>).map((e) => double.parse(e.toString())).toList();

                    double promedio = 0;
                    if (notas.isNotEmpty) {
                      promedio = notas.reduce((a, b) => a + b) / notas.length;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          modulo['nombre'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                         notas.isEmpty ? "Sin notas registradas" : "Promedio: ${promedio.toStringAsFixed(2)}",
                        style: promedio == 0 ? const TextStyle(color: Colors.grey) : (promedio < 3.0 ? const TextStyle(color: Colors.red) : const TextStyle(color: Colors.green)),
                          

                        ),
                        children: notas.asMap().entries.map<Widget>((entry) {
                          final i = entry.key + 1; 
                          final nota = entry.value;
                          return ListTile(
                            leading: Icon(
                              Icons.school,
                              color: nota < 3.0 ? Colors.red : Colors.green,
                            ),
                            title: Text("Nota $i"),
                            trailing: Text(
                              nota.toString(),
                              style: TextStyle(
                                color: nota < 3.0 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              )
            ]
          );
        },
      ),
    );
  }
}

