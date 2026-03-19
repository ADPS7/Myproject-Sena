import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MisCursosView extends StatefulWidget {
  final Map<String, dynamic> user;
  const MisCursosView({super.key, required this.user});

  @override
  State<MisCursosView> createState() => _MisCursosViewState();
}

class _MisCursosViewState extends State<MisCursosView> {
  // 1. CREAMOS LA INSTANCIA PARA PODER USAR LOS MÉTODOS NO ESTÁTICOS
  final ApiService _apiService = ApiService();

  void _mostrarEstudiantes(BuildContext context, int idModulo, String nombreModulo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text("Asistencia: $nombreModulo",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0D1A63))),
                    const Text("Marque los aprendices presentes",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  // 2. USAMOS LA INSTANCIA _apiService
                  future: _apiService.getEstudiantesPorModulo(idModulo),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No hay aprendices inscritos."));
                    }

                    final estudiantes = snapshot.data!;
                    return ListView.builder(
                      itemCount: estudiantes.length,
                      itemBuilder: (context, index) {
                        final est = estudiantes[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xff0D1A63),
                            child: Text(est['nombres'][0].toString().toUpperCase(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text("${est['nombres']} ${est['apellidos']}"),
                          subtitle: Text(est['correo']),
                          trailing: const Icon(Icons.check_circle_outline,
                              color: Colors.green),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFC107),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("GUARDAR ASISTENCIA",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _mostrarModulos(BuildContext context, int idCurso, String nombreCurso) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("Módulos de $nombreCurso",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0D1A63))),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  // 3. USAMOS LA INSTANCIA _apiService
                  future: _apiService.getModulosPorCurso(idCurso),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Sin módulos registrados."));
                    }

                    final modulos = snapshot.data!;
                    return ListView.builder(
                      itemCount: modulos.length,
                      itemBuilder: (context, index) {
                        final modulo = modulos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading:
                                const Icon(Icons.menu_book, color: Color(0xff0D1A63)),
                            title: Text(modulo['nombre'],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.pop(context);
                              _mostrarEstudiantes(
                                  context, modulo['id_modulo'], modulo['nombre']);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Mis Cursos"),
          backgroundColor: const Color(0xff0D1A63),
          foregroundColor: Colors.white),
      body: FutureBuilder<List<dynamic>>(
        // 4. USAMOS LA INSTANCIA _apiService
        future: _apiService.getCursosPorProfesor(widget.user['id_usuario']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cursos = snapshot.data ?? [];
          if (cursos.isEmpty) {
            return const Center(child: Text("No tienes cursos asignados."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final curso = cursos[index];
              return GestureDetector(
                onTap: () =>
                    _mostrarModulos(context, curso['id_curso'], curso['nombre']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school, size: 40, color: Color(0xffFFC107)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(curso['nombre'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}