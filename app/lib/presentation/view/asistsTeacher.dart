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

  // ==================== HEADER ====================
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

  // ==================== MOSTRAR MÓDULOS (Con botón Historial) ====================
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
                                    "Gestión de asistencias",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Botón Abrir - Tomar Asistencia
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
                                                      final List<
                                                        Map<String, dynamic>
                                                      >
                                                      asistenciasList =
                                                          asistencia.entries
                                                              .map((entry) {
                                                                return {
                                                                  'id_usuario':
                                                                      entry.key,
                                                                  'asistio':
                                                                      entry
                                                                          .value
                                                                      ? 'SI'
                                                                      : 'NO',
                                                                };
                                                              })
                                                              .toList();

                                                      final result = await _apiService
                                                          .guardarAsistencia(
                                                            idModulo:
                                                                modulo['id_modulo'],
                                                            idsEstudiantes: [],
                                                            asistencias:
                                                                asistenciasList,
                                                          );

                                                      if (result['success'] ==
                                                          true) {
                                                        if (!context.mounted)
                                                          return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "✅ Asistencia guardada correctamente",
                                                              style: TextStyle(
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
                                                        Navigator.pop(
                                                          context,
                                                        ); // Cierra Dialog
                                                        Navigator.pop(
                                                          context,
                                                        ); // Cierra BottomSheet
                                                      } else {
                                                        // ←←← Agrega este else bien claro
                                                        if (!context.mounted)
                                                          return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              result['error'] ??
                                                                  'No se pudo guardar la asistencia',
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .orange[700],
                                                            duration:
                                                                const Duration(
                                                                  seconds: 4,
                                                                ),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
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
                            const SizedBox(width: 8),
                            // Botón Historial
                            ElevatedButton(
                              onPressed: () async {
                                final reporte = await _apiService
                                    .getReporteAsistenciaPorModulo(
                                      modulo['id_modulo'],
                                    );

                                if (!context.mounted) return;

                                if (reporte['success'] == true) {
                                  _mostrarReporteAsistencia(
                                    context,
                                    reporte['asistencias'] ?? [],
                                    modulo['nombre'],
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        reporte['error'] ??
                                            'Error al cargar el historial',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                foregroundColor: Colors.grey[700],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                "Historial",
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

  // ==================== NUEVA FUNCIÓN: MOSTRAR REPORTE DE ASISTENCIA ====================
  void _mostrarReporteAsistencia(
    BuildContext context,
    List<dynamic> asistencias,
    String nombreModulo,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: primaryPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Historial - $nombreModulo",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: asistencias.isEmpty
                    ? const Center(
                        child: Text("No hay registros de asistencia"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: asistencias.length,
                        itemBuilder: (context, index) {
                          final estudiante = asistencias[index];
                          final historial = estudiante['historial'] as List;
                          final total = historial.length;
                          final presentes = historial
                              .where(
                                (h) =>
                                    h['asistio'] == true ||
                                    h['asistio'] == 'SI',
                              )
                              .length;
                          final porcentaje = total > 0
                              ? (presentes / total * 100).round()
                              : 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderGrey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: primaryPurple
                                          .withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        color: primaryPurple,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "${estudiante['nombres']} ${estudiante['apellidos']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: porcentaje >= 70
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "$porcentaje%",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: porcentaje >= 70
                                              ? Colors.green[800]
                                              : Colors.orange[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Historial de asistencias:",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: historial.map<Widget>((registro) {
                                    final bool asistio =
                                        registro['asistio'] == true ||
                                        registro['asistio'] == 'SI';
                                    return Chip(
                                      label: Text(registro['fecha']),
                                      backgroundColor: asistio
                                          ? Colors.green[50]
                                          : Colors.red[50],
                                      labelStyle: TextStyle(
                                        color: asistio
                                            ? Colors.green[900]
                                            : Colors.red[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== BUILD PRINCIPAL ====================
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
