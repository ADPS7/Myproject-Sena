function ocultarVistasEstudiante() {
    document.querySelectorAll('.estudiante-view').forEach(view => view.style.display = 'none');
}

function activarMenuEstudiante(viewName) {
    document.querySelectorAll('.nav-link-item').forEach(link => {
        link.classList.toggle('active', link.dataset.view === viewName);
    });
}

function mostrarvistaInicioEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarInicioEstudiante').style.display = 'block';
    activarMenuEstudiante('inicio');
    if (typeof cargarResumenInicioEstudiante === 'function') {
        cargarResumenInicioEstudiante();
    }
}

function mostrarvistaCursosEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarCursosEstudiante').style.display = 'block';
    activarMenuEstudiante('cursos');
    cargarCursoEstudiante();
}

function mostrarvistaModulosEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarModulosEstudiante').style.display = 'block';
    activarMenuEstudiante('modulos');
    cargarProfesorAsignadoModulo();
    cargarModulosEstudiante();
}

function moduloEstaCompletado(modulo) {
    if (!modulo.fecha_fin) return false;
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    const fechaFin = new Date(modulo.fecha_fin);
    fechaFin.setHours(0, 0, 0, 0);
    return fechaFin < hoy;
}

async function cargarCursoEstudiante() {
    const resumen = document.getElementById('cursoEstudianteResumen');
    if (!resumen) return;

    resumen.innerHTML = `
        <div class="card border-0 shadow-lg rounded-4 p-4">
            <div class="text-center mb-4">
                <div class="mx-auto rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center" style="width:100px; height:100px;">
                    <i class="bi bi-mortarboard-fill fs-1 text-primary"></i>
                </div>
            </div>
            <div class="text-center mb-4">
                <small class="text-uppercase text-primary fw-bold" style="letter-spacing: 1px;">Programa de formación</small>
                <h2 class="fw-bold mt-3 mb-2" id="cursoEstudianteNombre">Cargando...</h2>
                <p class="text-muted mb-2" id="cursoEstudianteDescripcion">Descripción general del curso.</p>
                <p class="text-muted small mb-0" id="cursoEstudianteProfesores">Profesor asignado: Cargando...</p>
            </div>
            <div class="row g-3 mb-3">
                <div class="col-6">
                    <div class="bg-light rounded-4 p-3 text-center h-100">
                        <div class="text-primary mb-2"><i class="bi bi-calendar-event-fill fs-5"></i></div>
                        <small class="text-muted d-block">Periodo</small>
                        <strong id="cursoEstudiantePeriodo">2026</strong>
                    </div>
                </div>
                <div class="col-6">
                    <div class="bg-light rounded-4 p-3 text-center h-100">
                        <div class="text-primary mb-2"><i class="bi bi-check-circle-fill fs-5"></i></div>
                        <small class="text-muted d-block">Estado</small>
                        <strong id="cursoEstudianteEstado">Activo</strong>
                    </div>
                </div>
            </div>
            <div class="row g-3">
                <div class="col-6">
                    <div class="bg-primary bg-opacity-10 rounded-4 p-3 text-center">
                        <small class="text-muted d-block">Módulos totales</small>
                        <h3 class="fw-bold mb-0" id="cursoEstudianteTotalModulos">0</h3>
                    </div>
                </div>
                <div class="col-6">
                    <div class="bg-success bg-opacity-10 rounded-4 p-3 text-center">
                        <small class="text-muted d-block">Módulos completados</small>
                        <h3 class="fw-bold mb-0" id="cursoEstudianteModulosCompletados">0</h3>
                    </div>
                </div>
            </div>
            <div class="mt-4 text-center">
                <p class="small text-muted mb-0">Si tienes dudas sobre tu inscripción o el contenido, contacta con coordinación académica.</p>
            </div>
        </div>
    `;

    try {
        const response = await fetch(`/curso/estudiante/${window.USER_ID}`);
        if (!response.ok) {
            throw new Error('No se encontró el curso del estudiante');
        }

        const data = await response.json();
        if (!data.success || !data.curso) {
            throw new Error(data.message || 'No hay curso asignado');
        }

        const curso = data.curso;
        const modulosResponse = await fetch(`/modulos/estudiante/${window.USER_ID}`);
        const modulosList = modulosResponse.ok ? await modulosResponse.json() : [];
        const modulosExpirados = Array.isArray(modulosList) ? modulosList.filter(isModuloVencido).length : 0;

        const cursoDescripcion = curso.curso_nombre
            ? `Curso diseñado para desarrollar tus competencias en ${curso.curso_nombre} y avanzar con ejercicios y módulos prácticos.`
            : 'Descripción general del curso.';

        document.getElementById('cursoEstudianteNombre').textContent = curso.curso_nombre || 'Curso sin nombre';
        document.getElementById('cursoEstudianteDescripcion').textContent = cursoDescripcion + (modulosExpirados > 0 ? ` ${modulosExpirados} módulo(s) ya se completaron porque se acabó el tiempo.` : '');
        document.getElementById('cursoEstudianteProfesores').textContent = curso.profesores ? `Profesor asignado: ${curso.profesores}` : 'Profesor asignado: Sin profesor asignado';
        document.getElementById('cursoEstudiantePeriodo').textContent = '2026';
        document.getElementById('cursoEstudianteEstado').textContent = 'Activo';
        document.getElementById('cursoEstudianteTotalModulos').textContent = curso.total_modulos || 0;
        document.getElementById('cursoEstudianteModulosCompletados').textContent = (Number(curso.modulos_hechos || 0) + modulosExpirados).toString();
    } catch (error) {
        console.error(error);
        resumen.innerHTML = `
            <div class="alert alert-warning shadow-sm">
                No se pudo cargar la información del curso. Recarga la página o intenta más tarde.
            </div>
        `;
    }
}

function mostrarvistaNotasEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarNotasEstudiante').style.display = 'block';
    activarMenuEstudiante('notas');
    cargarNotasEstudiante();
}

async function cargarNotasEstudiante() {
    const contenedor = document.getElementById('contenedorNotasEstudiante');
    const cursoLabel = document.getElementById('estudianteNotasCurso');

    if (!contenedor || !cursoLabel) return;

    cursoLabel.textContent = 'Cargando...';
    contenedor.innerHTML = `
        <div class="col-12">
            <div class="card border-0 shadow-sm p-4">
                <div class="text-center py-5 text-secondary">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-3 mb-0">Cargando tus notas...</p>
                </div>
            </div>
        </div>
    `;

    try {
        const response = await fetch(`/notas-alumno/${window.USER_ID}`);
        if (!response.ok) {
            throw new Error('No se pudieron cargar tus notas.');
        }

        const data = await response.json();
        cursoLabel.textContent = data.curso || 'Sin curso asignado';
        renderizarNotasEstudiante(data);
    } catch (error) {
        console.error(error);
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-danger shadow-sm">
                    Ocurrió un error al cargar tus notas. Intenta recargar la página.
                </div>
            </div>
        `;
    }
}

function calcularPromedioModulo(notas) {
    if (!Array.isArray(notas) || notas.length === 0) return null;
    const suma = notas.reduce((acc, nota) => acc + Number(nota.nota || 0), 0);
    return (suma / notas.length).toFixed(2);
}

function renderizarNotasEstudiante(data) {
    const contenedor = document.getElementById('contenedorNotasEstudiante');
    if (!contenedor) return;

    if (!data || !Array.isArray(data.modulos) || data.modulos.length === 0) {
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    No se encontraron notas para tu curso o todavía no se han registrado calificaciones.
                </div>
            </div>
        `;
        return;
    }

    const tarjetas = data.modulos.map(modulo => {
        const promedioModulo = calcularPromedioModulo(modulo.notas);
        
        const notasHTML = Array.isArray(modulo.notas) && modulo.notas.length
            ? modulo.notas.map((nota, index) => {
                const nombreActividad = nota.nombre_actividad || nota.nombre || nota.actividad || `Actividad ${index + 1}`;
                return `
                    <li class="list-group-item d-flex justify-content-between align-items-center py-3 px-0 border-0 border-bottom">
                        <span class="fw-medium">${nombreActividad}</span>
                        <span class="badge bg-${nota.nota >= 3 ? 'success' : 'danger'} bg-opacity-10 text-${nota.nota >= 3 ? 'success' : 'danger'} rounded-pill py-2 px-3">
                            ${Number(nota.nota).toFixed(2)}
                        </span>
                    </li>
                `;
            }).join('')
            : `
                <div class="alert alert-warning py-3 mb-0 small">
                    No tienes notas registradas en este módulo.
                </div>
            `;

        const mostrarScroll = Array.isArray(modulo.notas) && modulo.notas.length > 5;

        return `
            <div class="col-12 col-md-6 col-xl-4 mb-4">
                <div class="card border-0 shadow-sm notas-card h-100">
                    <div class="card-body d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                            <div>
                                <small class="text-uppercase text-primary fw-bold">Módulo</small>
                                <h5 class="fw-bold mt-2 mb-1">${modulo.nombre || 'Sin nombre'}</h5>
                            </div>
                            <div class="text-end">
                                <span class="badge ${promedioModulo ? 'bg-success text-white' : 'bg-secondary text-white'} rounded-pill py-2 px-3">
                                    ${promedioModulo ? promedioModulo + ' / 5.0' : 'Sin nota'}
                                </span>
                            </div>
                        </div>
                        ${Array.isArray(modulo.notas) && modulo.notas.length ? `
                            <div class="notas-scroll ${mostrarScroll ? 'has-scroll' : ''}">
                                <ul class="list-group list-group-flush mb-0 notas-list">
                                    ${notasHTML}
                                </ul>
                            </div>
                            ${mostrarScroll ? '<p class="text-muted small mt-2 mb-0">Desplázate para ver más notas.</p>' : ''}
                        ` : notasHTML}
                    </div>
                </div>
            </div>
        `;
    }).join('');

    contenedor.innerHTML = tarjetas;
}

async function cargarResumenInicioEstudiante() {
    const cursoLabel = document.getElementById('inicioCursoActual');
    const cursoTitulo = document.getElementById('inicioTituloCurso');
    const cursoDescripcion = document.getElementById('inicioDescripcionCurso');
    const modulosInscritos = document.getElementById('inicioModulosInscritos');
    const modulosPendientes = document.getElementById('inicioModulosPendientes');
    const modulosCompletadosEl = document.getElementById('cursoEstudianteModulosCompletados');
    const promedioActual = document.getElementById('inicioPromedioActual');
    const promedioTexto = document.getElementById('inicioPromedioTexto');
    const asistenciaLabel = document.getElementById('inicioAsistencia');
    const asistenciaTexto = document.getElementById('inicioAsistenciaTexto');

    if (!cursoLabel || !modulosInscritos || !modulosPendientes || !promedioActual || !promedioTexto || !asistenciaLabel || !asistenciaTexto) {
        return;
    }

    try {
        const [cursoResp, modulosResp, notasResp, asistResp] = await Promise.all([
            fetch(`/curso/estudiante/${window.USER_ID}`),
            fetch(`/modulos/estudiante/${window.USER_ID}`),
            fetch(`/notas-alumno/${window.USER_ID}`),
            fetch(`/asistencias/${window.USER_ID}`)
        ]);

        const cursoData = cursoResp.ok ? await cursoResp.json() : null;
        const modulosData = modulosResp.ok ? await modulosResp.json() : [];
        const notasData = notasResp.ok ? await notasResp.json() : null;
        const asistData = asistResp.ok ? await asistResp.json() : null;

        const cursoInfo = cursoData && cursoData.curso ? cursoData.curso : cursoData;
        const cursoNombre = cursoInfo?.curso_nombre || cursoInfo?.nombre || 'Sin curso asignado';

        cursoLabel.textContent = `Curso actual: ${cursoNombre}`;

        if (cursoTitulo) {
            cursoTitulo.textContent = cursoNombre || 'Tu curso actual';
        }

        if (cursoDescripcion) {
            cursoDescripcion.textContent = cursoNombre
                ? `Estás cursando ${cursoNombre}. Revisa módulos, notas y asistencia desde esta vista.`
                : 'Aún no tienes un curso asignado en la plataforma.';
        }

        const totalModulos = Array.isArray(modulosData) ? modulosData.length : 0;
        const modulosCompletados = Array.isArray(modulosData) 
            ? modulosData.filter(moduloEstaCompletado).length 
            : 0;

        // Actualizar contadores en la tarjeta
        if (modulosInscritos) modulosInscritos.textContent = totalModulos;
        if (modulosCompletadosEl) modulosCompletadosEl.textContent = modulosCompletados;
        if (modulosPendientes) {
            modulosPendientes.textContent = `Completados: ${modulosCompletados} • Pendientes: ${Math.max(0, totalModulos - modulosCompletados)}`;
        }

        let promedioGlobal = null;
        if (notasData && Array.isArray(notasData.modulos)) {
            const notasPlanas = notasData.modulos.flatMap(mod => Array.isArray(mod.notas) ? mod.notas.map(n => Number(n.nota || 0)) : []);
            if (notasPlanas.length) {
                const total = notasPlanas.reduce((sum, value) => sum + value, 0);
                promedioGlobal = (total / notasPlanas.length).toFixed(2);
            }
        }

        if (promedioGlobal !== null) {
            promedioActual.textContent = promedioGlobal;
            promedioTexto.textContent = `Promedio basado en ${notasData.modulos.length} módulo(s)`;
        } else {
            promedioActual.textContent = 'Sin nota';
            promedioTexto.textContent = 'Aún no hay calificaciones registradas.';
        }

        if (asistData && Array.isArray(asistData.asistencias)) {
            const registros = asistData.asistencias;
            const totales = registros.length;
            const asistidos = registros.filter(item => String(item.asistio).toUpperCase() === 'SI').length;
            const porcentaje = totales ? Math.round((asistidos / totales) * 100) : 0;
            asistenciaLabel.textContent = `${porcentaje}%`;
            asistenciaTexto.textContent = totales ? `Asistencias: ${asistidos} de ${totales} clases asistidas` : 'Aún no hay registros de asistencia';
        } else {
            asistenciaLabel.textContent = '0%';
            asistenciaTexto.textContent = 'Aún no hay registros de asistencia';
        }
    } catch (error) {
        console.error('Error cargando el resumen del estudiante:', error);
        if (cursoLabel) cursoLabel.textContent = 'Curso actual: error al cargar';
        if (cursoTitulo) cursoTitulo.textContent = 'Tu curso actual';
        if (cursoDescripcion) cursoDescripcion.textContent = 'No se pudo cargar la descripción del curso en este momento.';
        modulosPendientes.textContent = 'No se pudieron obtener datos completos.';
        promedioTexto.textContent = 'Intenta recargar la página.';
        asistenciaTexto.textContent = 'Intenta recargar la página.';
    }
}

function mostrarvistaAsistenciaEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarAsistenciaEstudiante').style.display = 'block';
    activarMenuEstudiante('asistencia');
    if (typeof cargarAsistenciasEstudiante === 'function') {
        cargarAsistenciasEstudiante();
    }
}

if (window.USER_ID) {
    const cargarInicioSiEstaVisible = () => {
        if (document.getElementById('mostrarInicioEstudiante')?.style.display !== 'none') {
            cargarResumenInicioEstudiante();
        }
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', cargarInicioSiEstaVisible);
    } else {
        cargarInicioSiEstaVisible();
    }
}

async function cargarProfesorAsignadoModulo() {
    const profesorLabel = document.getElementById('profesorAsignadoModulo');

    if (!profesorLabel) return;

    try {
        const response = await fetch(`/curso/estudiante/${window.USER_ID}`);
        if (!response.ok) {
            throw new Error('No se pudo cargar el profesor asignado');
        }

        const data = await response.json();

        if (!data.success || !data.curso) {
            throw new Error(data.message || 'No hay información del curso');
        }

        profesorLabel.textContent = data.curso.profesores
            ? `Profesor asignado: ${data.curso.profesores}`
            : 'Profesor asignado: Sin profesor asignado';
    } catch (error) {
        console.error(error);
        profesorLabel.textContent = 'Profesor asignado: No disponible';
    }
}

async function cargarModulosEstudiante() {
    const lista = document.getElementById('cursoEstudianteModulos') || document.getElementById('listaModulosEstudiante');

    if (!lista) {
        console.error('No se encontró el contenedor de módulos del estudiante.');
        return;
    }

    lista.innerHTML = `
        <div class="col-12 text-center py-5">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Cargando...</span>
            </div>
        </div>
    `;

    try {
        const response = await fetch(`/modulos/estudiante/${window.USER_ID}`);

        if (!response.ok) {
            throw new Error('Error al cargar los módulos');
        }

        const modulos = await response.json();

        renderizarModulosEstudiante(modulos);
    } catch (error) {
        console.error(error);
        document.getElementById('listaModulosEstudiante').innerHTML = `
            <div class="col-12">
                <div class="alert alert-danger shadow-sm">
                    No se pudieron cargar los módulos. Intenta recargar la página.
                </div>
            </div>
        `;
    }
}

function formatDate(dateString) {
    if (!dateString) return 'Sin fecha';
    const parsed = String(dateString).split('T')[0].split('-');
    if (parsed.length !== 3) return String(dateString);

    const [year, month, day] = parsed.map(Number);
    if (!year || !month || !day) return String(dateString);

    const date = new Date(year, month - 1, day);
    return date.toLocaleDateString('es-CO', {
        day: '2-digit',
        month: 'short',
        year: 'numeric'
    });
}

function parseDateYMD(dateString) {
    if (!dateString) return null;
    const text = String(dateString).split('T')[0];
    const parts = text.split('-').map(Number);
    if (parts.length !== 3 || parts.some(isNaN)) return null;
    return new Date(parts[0], parts[1] - 1, parts[2]);
}

function isModuloVencido(modulo) {
    if (!modulo || !modulo.fecha_fin) return false;
    const fechaFin = parseDateYMD(modulo.fecha_fin);
    if (!fechaFin) return false;
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    return fechaFin < hoy;
}

function renderizarModulosEstudiante(modulos) {
    const lista = document.getElementById('cursoEstudianteModulos') || document.getElementById('listaModulosEstudiante');

    if (!lista) {
        console.error('No se encontró el contenedor de módulos del estudiante.');
        return;
    }

    if (!modulos || !modulos.length) {
        document.getElementById('listaModulosCompletados').innerHTML = `
            <div class="col-12">
                <div class="alert alert-secondary shadow-sm">
                    No hay módulos completados aún.
                </div>
            </div>
        `;
        lista.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    No hay módulos con fecha asignada para tu curso.
                </div>
            </div>
        `;
        return;
    }

    const modulosCompletados = modulos.filter(isModuloVencido);
    const modulosActivos = modulos.filter(modulo => !isModuloVencido(modulo));

    document.getElementById('listaModulosCompletados').innerHTML = modulosCompletados.length
        ? modulosCompletados.map(modulo => renderModuloCard(modulo, true)).join('')
        : `
            <div class="col-12">
                <div class="alert alert-secondary shadow-sm">
                    No hay módulos completados aún.
                </div>
            </div>
        `;

    lista.innerHTML = modulosActivos.length
        ? modulosActivos.map(modulo => renderModuloCard(modulo, false)).join('')
        : `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    No hay módulos activos disponibles.
                </div>
            </div>
        `;

    function renderModuloCard(modulo, expirado) {
        const notas = Array.isArray(modulo.notas) ? modulo.notas : [];
        const promedio = notas.length
            ? (notas.reduce((sum, nota) => sum + Number(nota.nota || 0), 0) / notas.length).toFixed(1)
            : null;
        const badgeHtml = expirado
            ? `<span class="badge bg-success bg-opacity-10 text-success mb-3">Completado</span>`
            : `<span class="badge bg-primary bg-opacity-10 text-primary mb-3">Activo</span>`;

        return `
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card border-0 shadow-lg modulo-card overflow-hidden h-100 ${expirado ? 'border-success' : ''}" style="cursor: default;">
                    <div class="bg-primary p-4 text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <small class="text-white-50">MÓDULO</small>
                                <h5 class="fw-bold mb-0 mt-2 text-white">${modulo.nombre}</h5>
                            </div>
                            <div class="bg-white bg-opacity-25 rounded-circle p-3">
                                <i class="bi bi-journal-bookmark-fill fs-4"></i>
                            </div>
                        </div>
                    </div>
                    <div class="card-body p-4">
                        ${badgeHtml}
                        <div class="bg-light rounded-4 p-3 mb-3">
                            <div class="d-flex justify-content-between mb-2">
                                <small class="text-muted">Inicio</small>
                                <span class="fw-semibold">${formatDate(modulo.fecha_inicio)}</span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <small class="text-muted">Finaliza</small>
                                <span class="fw-semibold">${formatDate(modulo.fecha_fin)}</span>
                            </div>
                        </div>
                        ${expirado ? `<div class="alert alert-success py-2 mb-0 small">Este módulo ya venció y se ha colocado como completado.</div>` : ''}
                    </div>
                </div>
            </div>
        `;
    }
}
