import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MyModulesScreen extends StatelessWidget {
  const MyModulesScreen({super.key});

  // Paleta de colores consistente
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  Future<Map<String, dynamic>> _getMyModules() async {
    try {
      final data = await ApiService().getMyModules();
      // Si el curso viene vacío o nulo, forzamos "Enfermería"
      if (data['curso'] == null || data['curso'].toString().isEmpty) {
        data['curso'] = 'Enfermería';
      }
      return data;
    } catch (e) {
      return {
        'curso': 'Enfermería', // Valor por defecto tipo Patricia Terán
        'modulos': []
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getMyModules(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryPurple));
            }

            final data = snapshot.data ?? {'curso': 'Enfermería', 'modulos': []};
            final String curso = data['curso'];
            final List<dynamic> modulos = data['modulos'];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header estilizado (Igual a Notas y Asistencias)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderGrey),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: darkBlue),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("PLAN DE ESTUDIOS", 
                          style: TextStyle(
                            color: primaryPurple, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 11, 
                            letterSpacing: 1.2
                          )),
                        const SizedBox(height: 4),
                        Text(curso, 
                          style: const TextStyle(
                            fontSize: 26, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: -1
                          )),
                        const SizedBox(height: 8),
                        Text("Módulos registrados en tu formación", 
                          style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Lista de Módulos
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: modulos.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text("No hay módulos disponibles en este momento"),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final modulo = modulos[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderGrey, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: darkBlue.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryPurple.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.auto_stories_rounded, // Ícono moderno de libro
                                      color: primaryPurple,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    modulo['nombre'] ?? 'Módulo',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold, 
                                      color: darkBlue
                                    ),
                                  ),
                                  subtitle: const Text("Programa Técnico", 
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  trailing: Icon(Icons.chevron_right_rounded, color: borderGrey),
                                  onTap: () {
                                    // Aquí puedes añadir navegación a detalle del módulo
                                  },
                                ),
                              );
                            },
                            childCount: modulos.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}