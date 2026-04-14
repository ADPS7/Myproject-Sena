import 'package:app/services/aut_service.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class MyModulesScreen extends StatelessWidget {
  const MyModulesScreen({super.key});

  Future<Map<String, dynamic>> _getMyModules() async {
    return await ApiService().getMyModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getMyModules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {'curso': 'Sin curso asignado', 'modulos': []};
          final String curso = data['curso'];
          final List<dynamic> modulos = data['modulos'];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 205,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A1E3A),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(55),
                        bottomRight: Radius.circular(55),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              "Mis Módulos",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              curso,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 35),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: modulos.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(child: Text("No hay módulos disponibles")),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final modulo = modulos[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                leading: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 40,
                                  color: Color(0xFF0A1E3A),
                                ),
                                title: Text(
                                  modulo['nombre'] ?? 'Módulo',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: modulos.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}