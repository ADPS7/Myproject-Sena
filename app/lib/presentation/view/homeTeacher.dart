import 'package:app/presentation/view/asistsTeacher.dart';
import 'package:app/presentation/view/notaPro.dart'; 
import 'package:flutter/material.dart';
import '../widget/login_widget.dart';

class HomeTeacher extends StatelessWidget {
  final Map<String, dynamic> user;
  const HomeTeacher({super.key, required this.user});

  void _cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  // DISEÑO MEJORADO: Menú desplegable para Docente
  void _mostrarPerfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xffF5F6FA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xff0D1A63),
                child: Icon(Icons.person_pin_rounded, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 15),
              Text(
                "${user['nombres'] + ' ' + user['apellidos']}",
                style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xff0D1A63)
                ),
              ),
              Text(
                (user['rol'] ?? 'INSTRUCTOR').toString().toUpperCase(),
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey, letterSpacing: 1.2),
              ),
              const SizedBox(height: 30),
              
              // Tarjeta de información blanca
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileItem(Icons.email_outlined, "Correo", "${user['correo']}"),
                    Divider(height: 1, color: Colors.grey[100], indent: 70),
                    _buildProfileItem(Icons.badge_outlined, "Rol","Instructor"),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              
              // Botón de Horarios (Acción secundaria)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month, color: Color(0xff0D1A63)),
                  label: const Text("VER MIS HORARIOS", style: TextStyle(color: Color(0xff0D1A63), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Color(0xff0D1A63)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Botón de Cerrar Sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _cerrarSesion(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text("CERRAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xff0D1A63).withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xff0D1A63)),
      ),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xff0D1A63),
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Panel de Control,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                            Text(
                              user['nombres'] ?? "Docente", 
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        // Avatar activador del menú
                        GestureDetector(
                          onTap: () => _mostrarPerfil(context),
                          child: Container(
                            height: 75,
                            width: 75,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.account_circle, color: Color(0xff0D1A63), size: 55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            _buildLegacyContainer(
              context, 
              Icons.class_rounded, 
              "Mis Cursos", 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MisCursosView(user: user)),
                );
              }
            ),
            const SizedBox(height: 20),
            
            _buildLegacyContainer(context, Icons.group_rounded, "Mis Alumnos", () {}),
            const SizedBox(height: 20),
            
            _buildLegacyContainer(
              context, 
              Icons.assignment_turned_in_rounded,
              "Calificar Notas", 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotasProfesorView(idUsuario: user['id_usuario'])),
                );
              }
            ),
            const SizedBox(height: 20),
            
            _buildLegacyContainer(context, Icons.layers_rounded, "Contenido de Módulos", () {}),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                "Tablero de Información Académica", 
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyContainer(BuildContext context, IconData icono, String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff0D1A63).withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icono, color: const Color(0xff0D1A63), size: 28),
            ),
            const SizedBox(width: 18),
            Text(texto, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff2D3142))),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}