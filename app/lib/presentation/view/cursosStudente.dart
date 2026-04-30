import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MyCourseScreen extends StatelessWidget {
  const MyCourseScreen({super.key});

  // Paleta de colores del patrón
  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  Future<String> _getStudentCourse() async {
    return await ApiService().getStudentCourse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _getStudentCourse(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryPurple));
            }

            final String curso = snapshot.data ?? 'Sin curso asignado';

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header siguiendo el patrón de los otros
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
                            child: Icon(Icons.arrow_back_ios_new_rounded, 
                              size: 18, color: darkBlue),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("ACADEMIA", 
                          style: TextStyle(
                            color: primaryPurple, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 11, 
                            letterSpacing: 1.2
                          )),
                        const SizedBox(height: 4),
                        const Text("Mi Curso", 
                          style: TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: -1
                          )),
                        const SizedBox(height: 8),
                        Text("Detalles de tu formación actual", 
                          style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      ],
                    ),
                  ),
                ),

                // Contenido central: Tarjeta de información del curso
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Ilustración o Icono principal
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.school_rounded, 
                            size: 80, color: primaryPurple),
                        ),
                        const SizedBox(height: 32),
                        
                        // Tarjeta de información principal
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderGrey, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: darkBlue.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text("PROGRAMA DE FORMACIÓN", 
                                style: TextStyle(
                                  color: Colors.grey[400], 
                                  fontSize: 10, 
                                  fontWeight: FontWeight.w800, 
                                  letterSpacing: 1
                                )),
                              const SizedBox(height: 12),
                              Text(
                                curso,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.w900, 
                                  color: darkBlue,
                                  height: 1.2
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 24),
                              
                              // Detalles adicionales estilizados
                              Row(
                                children: [
                                  _buildInfoItem(Icons.calendar_today_rounded, "Periodo", "2026"),
                                  Container(width: 1, height: 30, color: borderGrey),
                                  _buildInfoItem(Icons.timer_outlined, "Estado", "Activo"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        // Nota al pie o información de ayuda
                        Text(
                          "Si tienes problemas con tu inscripción,\n contacta con coordinación académica.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400], 
                            fontSize: 12, 
                            height: 1.5
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: primaryPurple.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue, fontSize: 14)),
        ],
      ),
    );
  }
}