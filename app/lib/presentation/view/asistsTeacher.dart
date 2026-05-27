import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AsistsTeacher extends StatefulWidget {
  final int idUsuario;

  const AsistsTeacher({super.key, required this.idUsuario});

  @override
  State<AsistsTeacher> createState() => _AsistsTeacherState();
}

class _AsistsTeacherState extends State<AsistsTeacher> {
  final ApiService _apiService = ApiService();

  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: darkBlue,
              size: 28,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CONTROL ACADÉMICO",
                  style: TextStyle(
                    color: primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Asistencias",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),

          CircleAvatar(
            radius: 25,
            backgroundColor: primaryPurple,
            child: const Icon(Icons.fact_check_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _mostrarModulos(BuildContext context, int idCurso, String nombreCurso) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.82,

        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(34),
            topRight: Radius.circular(34),
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 14),

            Container(
              width: 55,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [
                  Text(
                    nombreCurso,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Selecciona un módulo",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _apiService.getModulosPorCurso(idCurso),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryPurple),
                    );
                  }

                  final modulos = snapshot.data ?? [];

                  if (modulos.isEmpty) {
                    return const Center(
                      child: Text("No hay módulos disponibles"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    itemCount: modulos.length,

                    itemBuilder: (context, index) {
                      final modulo = modulos[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderGrey),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),

                              decoration: BoxDecoration(
                                color: primaryPurple.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Icon(
                                Icons.layers_rounded,
                                color: primaryPurple,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    modulo['nombre'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: darkBlue,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "Tomar asistencia",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () async {
                                final estudiantes = await _apiService
                                    .getEstudiantesPorModulo(
                                      modulo['id_modulo'],
                                    );

                                if (!context.mounted) return;

                                showDialog(
                                  context: context,

                                  builder: (_) {
                                    Map<int, bool> asistencia = {};

                                    for (var est in estudiantes) {
                                      asistencia[est['id_usuario']] = true;
                                    }

                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),

                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            constraints: const BoxConstraints(
                                              maxHeight: 650,
                                            ),

                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.fact_check_rounded,
                                                      color: primaryPurple,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        modulo['nombre'],
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 20),

                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount:
                                                        estudiantes.length,
                                                    itemBuilder: (context, index) {
                                                      final est =
                                                          estudiantes[index];
                                                      final id =
                                                          est['id_usuario'];
                                                      final presente =
                                                          asistencia[id] ??
                                                          true;

                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 14,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              16,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          border: Border.all(
                                                            color: borderGrey,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 24,
                                                              backgroundColor:
                                                                  primaryPurple
                                                                      .withOpacity(
                                                                        0.10,
                                                                      ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color:
                                                                    primaryPurple,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 14,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "${est['nombres']} ${est['apellidos']}",
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    est['correo'] ??
                                                                        '',
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .grey[500],
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      setModalState(
                                                                        () => asistencia[id] =
                                                                            true,
                                                                      ),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          14,
                                                                      vertical:
                                                                          10,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          presente
                                                                          ? Colors.green
                                                                          : Colors.grey[200],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    child: Text(
                                                                      "Presente",
                                                                      style: TextStyle(
                                                                        color:
                                                                            presente
                                                                            ? Colors.white
                                                                            : Colors.black54,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      setModalState(
                                                                        () => asistencia[id] =
                                                                            false,
                                                                      ),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          14,
                                                                      vertical:
                                                                          10,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          !presente
                                                                          ? Colors.red
                                                                          : Colors.grey[200],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    child: Text(
                                                                      "Ausente",
                                                                      style: TextStyle(
                                                                        color:
                                                                            !presente
                                                                            ? Colors.white
                                                                            : Colors.black54,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),

                                                const SizedBox(height: 10),

                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      final presentes =
                                                          asistencia.entries
                                                              .where(
                                                                (e) => e.value,
                                                              )
                                                              .map((e) => e.key)
                                                              .toList();

                                                      final result =
                                                          await _apiService
                                                              .guardarAsistencia(
                                                                idModulo:
                                                                    modulo['id_modulo'],
                                                                idsEstudiantes:
                                                                    presentes,
                                                              );

                                                      if (result['success'] ==
                                                          true) {
                                                        if (!context.mounted)
                                                          return;

                                                        // Mostrar mensaje ANTES de cerrar
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "✅ Asistencia guardada correctamente",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Colors.green,
                                                            duration: Duration(
                                                              seconds: 2,
                                                            ),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );

                                                        // Cerrar diálogos
                                                        Navigator.pop(
                                                          context,
                                                        ); // Cierra Dialog
                                                        Navigator.pop(
                                                          context,
                                                        ); // Cierra BottomSheet
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.save_rounded,
                                                    ),
                                                    label: const Text(
                                                      "GUARDAR ASISTENCIA",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          primaryPurple,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 16,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              18,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryPurple.withOpacity(
                                  0.10,
                                ),
                                foregroundColor: primaryPurple,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Abrir",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _apiService.getCursosPorProfesor(widget.idUsuario),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryPurple),
              );
            }

            final cursos = snapshot.data ?? [];

            if (cursos.isEmpty) {
              return const Center(child: Text("No tienes cursos asignados"));
            }

            return Column(
              children: [
                buildHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: cursos.length,
                    itemBuilder: (context, index) {
                      final curso = cursos[index];

                      return GestureDetector(
                        onTap: () => _mostrarModulos(
                          context,
                          curso['id_curso'],
                          curso['nombre'],
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderGrey),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: primaryPurple.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Icon(
                                  Icons.school_rounded,
                                  color: primaryPurple,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      curso['nombre'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        color: darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Gestiona módulos y asistencias",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}