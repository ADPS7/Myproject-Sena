import 'package:flutter/material.dart';

class Homeadmin extends StatelessWidget {
  const Homeadmin({super.key});

  void _mostrarPerfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Información del Perfil",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff0D1A63)),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.person, color: Color(0xff0D1A63)),
                title: Text("Nombre completo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("Administrador Principal", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const ListTile(
                leading: Icon(Icons.email, color: Color(0xff0D1A63)),
                title: Text("Correo electrónico", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("admin@llinasiano.edu.co", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const ListTile(
                leading: Icon(Icons.cake, color: Color(0xff0D1A63)),
                title: Text("Fecha de nacimiento", style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text("10 de Marzo de 1995", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFC107),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Cambiar Contraseña", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

}