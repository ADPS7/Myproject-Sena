import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 216, 230),
        title: Row(
          children: [
            Image.asset('assets/images/imagen2.png', height: 30),
            const SizedBox(width: 12),
            const Text(
              'Lucy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        elevation: 2,
      ),

      // Menú lateral
      drawer: Drawer(
        width: 240,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                'Piolin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text('piolin@gmail.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
            SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Mis Cursos'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Calificaciones'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Horario'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                
              },
            ),
          ],
        ),
      ),

      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Bienvenido de nuevo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Aquí tienes un resumen de tu progreso',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            
            _buildInfoCard(
              title: 'Cursos Activos',
              value: '?',
              subtitle: '???????????',
              icon: Icons.book_rounded,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Módulos Completados',
              value: 'No se sabe todavia ',
              subtitle: 'Progreso general',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Próxima Evaluación',
              value: 'Matemáticas II',
              subtitle: '45 Feb 9990 - 08:00 am',
              icon: Icons.event,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Promedio General',
              value: '-4.2 / 5.0',
              subtitle: 'Último corte',
              icon: Icons.trending_up,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
