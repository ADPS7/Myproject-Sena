import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotasProfesorView extends StatefulWidget {
  final int idUsuario; // ID del profesor
  

  const NotasProfesorView({super.key, required this.idUsuario});

  @override
  State<NotasProfesorView> createState() => _NotasProfesorViewState();
}

class _NotasProfesorViewState extends State<NotasProfesorView> {
  final ApiService _api = ApiService();

  final Color primaryPurple = const Color(0xFF7C4DFF);
  final Color darkBlue = const Color(0xFF1A202C);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color borderGrey = const Color(0xFFE2E8F0);

  Future<List<dynamic>>? _futureCursos;

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  void _cargarCursos() {
    setState(() {
      _futureCursos = _api.getCursosPorProfesor(widget.idUsuario);
    });
  }

  Future<List<dynamic>> _getModulos(int idCurso) async {
    return await _api.getModulosPorCurso(idCurso);
  }

  Future<List<dynamic>> _getEstudiantes(int idModulo) async {
    final notas = await _api.getNotasPorModulo(idModulo);
    final estudiantes = await _api.getEstudiantesPorModulo(idModulo);

    int? toInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '');
    }

    String nombreCompleto(Map estudiante) {
      final nombres = estudiante['nombres']?.toString() ?? '';
      final apellidos = estudiante['apellidos']?.toString() ?? '';
      return '$nombres $apellidos'.trim();
    }

    final correosPorUsuario = <int, String>{};
    final nombresPorUsuario = <int, String>{};

    for (final estudiante in estudiantes) {
      final idUsuario = toInt(estudiante['id_usuario']);
      if (idUsuario == null) continue;

      final nombre = nombreCompleto(estudiante);

      correosPorUsuario[idUsuario] = estudiante['correo']?.toString() ?? '';
      if (nombre.isNotEmpty) {
        nombresPorUsuario[idUsuario] = nombre;
      }
    }

    if (notas.isEmpty) {
      return estudiantes.map((estudiante) {
        return {
          'id_usuario': estudiante['id_usuario'],
          'nombre': nombreCompleto(estudiante),
          'correo': estudiante['correo'],
          'id_nota': null,
          'nota': null,
        };
      }).toList();
    }

    for (final nota in notas) {
      final idUsuario = toInt(nota['id_usuario']);
      if (idUsuario == null) continue;

      nota['correo'] ??= correosPorUsuario[idUsuario];
      nota['nombre'] ??= nombresPorUsuario[idUsuario];
    }

    return notas;
  }

  void _mostrarDialogoNota(Map estudiante, int idModulo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Notas - ${estudiante['nombre']}"),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _api.getNotasEstudiante(estudiante['id_usuario']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!;
              final allModulos = data['modulos'] as List<dynamic>? ?? [];
              final modulos = allModulos.where((m) => m['id_modulo'] == idModulo).toList();

              if (modulos.isEmpty) {
                return const Text("No hay notas registradas para este estudiante en este módulo.");
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: modulos.length,
                itemBuilder: (context, index) {
                  final modulo = modulos[index];
                  final notas = modulo['notas'] as List<dynamic>? ?? [];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderGrey, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              modulo['nombre'] ?? 'Módulo',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (notas.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.add_circle, size: 22, color: Colors.green),
                                tooltip: 'Agregar nueva nota',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _mostrarDialogoEditarNota(
                                    estudiante,
                                    modulo['nombre'] ?? 'Módulo',
                                    null,
                                    modulo['id_modulo'],
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (notas.isEmpty)
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "sin notas registradas",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              )),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18, color: Colors.blue,),
                              tooltip: 'Agregar nota',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              onPressed: () {
                                Navigator.pop(context);
                                _mostrarDialogoEditarNota(
                                  estudiante,
                                  modulo['nombre'] ?? 'Módulo',
                                  null,
                                  modulo['id_modulo'],
                                );
                              },
                            ),
                          ],
                        )
                        else
                          ...notas.map((notaItem) {
                            final notaValor = notaItem is Map ? notaItem['nota'] : notaItem;
                            final notaId = notaItem is Map ? notaItem['id_nota'] : null;
                            final notaNumero = notaValor is num
                                ? notaValor.toDouble()
                                : double.tryParse(notaValor?.toString() ?? '');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: (notaNumero != null && notaNumero < 3)
                                        ? Colors.red.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Nota: ${notaNumero?.toStringAsFixed(2) ?? 'N/A'}",
                                        style: TextStyle(
                                          color: (notaNumero != null && notaNumero < 3)
                                              ? Colors.red
                                              : Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                      tooltip: 'Editar nota',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _mostrarDialogoEditarNota(
                                          estudiante,
                                          modulo['nombre'] ?? 'Módulo',
                                          notaItem,
                                          modulo['id_modulo'],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

    void _mostrarDialogoEditarNota(Map estudiante, String moduloNombre, dynamic notaActual, int idModulo) {
    final existingNotaValue = notaActual is Map ? notaActual['nota'] : notaActual;
    final existingNotaId = notaActual is Map ? notaActual['id_nota'] as int? : null;

    final TextEditingController notaController = TextEditingController(
      text: existingNotaValue?.toString() ?? '',
    );
    final actividadActual = notaActual is Map
        ? (notaActual['nombre_actividad'] ?? notaActual['nombre'] ?? notaActual['actividad'] ?? '')
        : '';
    final TextEditingController actividadController = TextEditingController(
      text: actividadActual.toString(),
    );
    
    final bool esNuevaNota = notaActual == null;
    final String tituloDialogo = esNuevaNota 
        ? "Agregar Nota - $moduloNombre" 
        : "Editar Nota - $moduloNombre";
    final String labelBoton = esNuevaNota ? "Agregar" : "Actualizar";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tituloDialogo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // === CAMPO NUEVO: Nombre de la Actividad ===
            TextField(
              controller: actividadController,
              decoration: const InputDecoration(
                labelText: "Nombre de la Actividad",
                hintText: "Examen Parcial 1, Taller Final, Quiz 3...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: notaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Ej: 4.5",
                labelText: "Nota",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = notaController.text.trim().replaceAll(',', '.');
              final nota = double.tryParse(value);
              final nombreActividad = actividadController.text.trim();

              if (nota == null || value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una nota válida.')),
                );
                return;
              }

              // === AQUÍ USAMOS EL MÉTODO QUE SÍ ENVÍA EL NOMBRE ===
              final result = await _api.guardarNotaConActividad(
                idUsuario: estudiante['id_usuario'],
                idModulo: idModulo,
                nota: nota,
                nombreActividad: nombreActividad.isEmpty ? "Evaluación" : nombreActividad,
                idNota: existingNotaId,
              );

              Navigator.pop(context);

              if (!mounted) return;

              if (result['success'] == true) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      esNuevaNota 
                          ? 'Nota agregada correctamente.' 
                          : 'Nota actualizada correctamente.'
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['error'] ?? 'Nota actualizada correctamente')),
                );
              }
            },
            child: Text(labelBoton),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Cursos",
                          style: TextStyle(
                            color: primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          "Cursos y Notas",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: FutureBuilder<List<dynamic>>(
              future: _futureCursos,
              builder: (context, snapshotCursos) {
                if (!snapshotCursos.hasData) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final cursos = snapshotCursos.data!;
                if (cursos.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No tienes cursos asignados.")),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, indexCurso) {
                      final curso = cursos[indexCurso];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderGrey, width: 1.5),
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: primaryPurple,
                              size: 32,
                            ),
                          ),
                          title: Text(
                            curso['nombre'],
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: darkBlue,
                            ),
                          ),
                          subtitle: const Text(
                            "Gestionar notas",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          children: [
                            FutureBuilder<List<dynamic>>(
                              future: _getModulos(curso['id_curso']),
                              builder: (context, snapshotModulos) {
                                if (!snapshotModulos.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final modulos = snapshotModulos.data!;
                                if (modulos.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text("No hay módulos en este curso."),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: modulos.length,
                                  itemBuilder: (context, indexModulo) {
                                    final modulo = modulos[indexModulo];

                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: bgGrey,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: borderGrey, width: 1),
                                      ),
                                      child: ExpansionTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.book_rounded,
                                            color: Colors.blue,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          modulo['nombre'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        children: [
                                          FutureBuilder<List<dynamic>>(
                                            future: _getEstudiantes(modulo['id_modulo']),
                                            builder: (context, snapshotEstudiantes) {
                                              if (!snapshotEstudiantes.hasData) {
                                                return const Center(child: CircularProgressIndicator());
                                              }

                                              final data = snapshotEstudiantes.data!;
                                              Map<int, Map<String, dynamic>> estudiantesAgrupados = {};
                                              for (var item in data) {
                                                final idUsuario = item['id_usuario'] is int
                                                    ? item['id_usuario'] as int
                                                    : int.tryParse(item['id_usuario']?.toString() ?? '');

                                                if (idUsuario == null) continue;

                                                if (!estudiantesAgrupados.containsKey(idUsuario)) {
                                                  estudiantesAgrupados[idUsuario] = {
                                                    "id_usuario": idUsuario,
                                                    "nombre": item['nombre'] ?? 'Estudiante',
                                                    "correo": item['correo'] ?? '',
                                                    "notas": []
                                                  };
                                                }

                                                if (item['nota'] != null) {
                                                  estudiantesAgrupados[idUsuario]!['notas'].add({
                                                    "id_nota": item['id_nota'],
                                                    "nota": item['nota'],
                                                    // Leer el nombre de la actividad desde la BD
                                                    "nombre_actividad": item['nombre_actividad'] ?? 'Actividad',
                                                  });
                                                }
                                              }
                                              final estudiantes = estudiantesAgrupados.values.toList();
                                              
                                              if (estudiantes.isEmpty) {
                                                return const Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Text("No hay estudiantes en este módulo."),
                                                );
                                              }

                                              return ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: estudiantes.length,
                                                itemBuilder: (context, indexEstudiante) {
                                                  final est = estudiantes[indexEstudiante];
                                                  final correo = est['correo']?.toString().trim() ?? '';

                                                  final notasEstudiante = (est['notas'] as List<dynamic>? ?? []);

                                                  return Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: borderGrey, width: 0.5),
                                                    ),
                                                    child: ExpansionTile(
                                                      tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                      leading: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.withOpacity(0.08),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(
                                                          Icons.person,
                                                          color: Colors.green,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        est['nombre']?.toString() ?? 'Estudiante',
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      subtitle: Text(
                                                        notasEstudiante.isEmpty
                                                            ? 'Sin actividades registradas'
                                                            : '${notasEstudiante.length} actividad(es)',
                                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                      ),
                                                      children: notasEstudiante.isEmpty
                                                          ? [
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                                child: Column(
                                                                  children: [
                                                                    const Text(
                                                                      'Sin actividades registradas',
                                                                      style: TextStyle(
                                                                        color: Colors.grey,
                                                                        fontSize: 13,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(height: 10),
                                                                    IconButton(
                                                                      icon: const Icon(
                                                                        Icons.add_circle,
                                                                        color: Colors.green,
                                                                        size: 30,
                                                                      ),
                                                                      onPressed: () {
                                                                        _mostrarDialogoEditarNota(
                                                                          est,
                                                                          modulo['nombre'] ?? 'Módulo',
                                                                          null,
                                                                          modulo['id_modulo'],
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ]
                                                          : notasEstudiante.map((notaItem) {
                                                              final nombreActividad = notaItem['nombre_actividad']?.toString() ?? 'Actividad';
                                                              final notaValor = notaItem['nota'];
                                                              final notaTexto = notaValor is num
                                                                  ? notaValor.toStringAsFixed(2)
                                                                  : notaValor?.toString() ?? 'N/A';

                                                              return Padding(
                                                                padding: const EdgeInsets.only(top: 4),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        nombreActividad,
                                                                        style: const TextStyle(
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 8),
                                                                    Text(
                                                                      'Nota: $notaTexto',
                                                                      style: const TextStyle(
                                                                        fontSize: 13,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.blue,
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                                                      tooltip: 'Editar nota',
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                                      onPressed: () => _mostrarDialogoEditarNota(
                                                                        est,
                                                                        modulo['nombre'] ?? 'Módulo',
                                                                        notaItem,
                                                                        modulo['id_modulo'],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: cursos.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
