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
    cargarModulosEstudiante();
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
                <p class="text-muted small mb-0" id="cursoEstudianteProfesores">Profesor: Cargando...</p>
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
        document.getElementById('cursoEstudianteNombre').textContent = curso.curso_nombre || 'Curso sin nombre';
        document.getElementById('cursoEstudianteDescripcion').textContent = curso.curso_nombre
            ? `Curso diseñado para desarrollar tus competencias en ${curso.curso_nombre} y avanzar con ejercicios y módulos prácticos.`
            : 'Descripción general del curso.';
        document.getElementById('cursoEstudianteProfesores').textContent = curso.profesores ? `Profesor: ${curso.profesores}` : 'Profesor no asignado';
        document.getElementById('cursoEstudiantePeriodo').textContent = '2026';
        document.getElementById('cursoEstudianteEstado').textContent = 'Activo';
        document.getElementById('cursoEstudianteTotalModulos').textContent = curso.total_modulos || 0;
        document.getElementById('cursoEstudianteModulosCompletados').textContent = curso.modulos_hechos || 0;
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
            ? modulo.notas.map((nota, index) => `
                <li class="list-group-item d-flex justify-content-between align-items-center py-3 px-0 border-0 border-bottom">
                    <span>Actividad ${index + 1}</span>
                    <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill py-2 px-3">${Number(nota.nota).toFixed(2)}</span>
                </li>
              `).join('')
            : `
                <div class="alert alert-warning py-3 mb-0 small">
                    No tienes notas registradas en este módulo.
                </div>
              `;

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
                            <ul class="list-group list-group-flush mb-0 notas-list">
                                ${notasHTML}
                            </ul>
                        ` : notasHTML}
                    </div>
                </div>
            </div>
        `;
    }).join('');

    contenedor.innerHTML = `${tarjetas}`;
}

function mostrarvistaAsistenciaEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarAsistenciaEstudiante').style.display = 'block';
    activarMenuEstudiante('asistencia');
    if (typeof cargarAsistenciasEstudiante === 'function') {
        cargarAsistenciasEstudiante();
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

function renderizarModulosEstudiante(modulos) {
    const lista = document.getElementById('cursoEstudianteModulos') || document.getElementById('listaModulosEstudiante');

    if (!lista) {
        console.error('No se encontró el contenedor de módulos del estudiante.');
        return;
    }

    if (!modulos || !modulos.length) {
        lista.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    No hay módulos con fecha asignada para tu curso.
                </div>
            </div>
        `;
        return;
    }

    lista.innerHTML = modulos.map(modulo => {
        return `
            <div class="col-12 col-sm-6 col-xl-4">
                <div class="card border-0 shadow-lg modulo-card overflow-hidden h-100">
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
                        <div class="bg-light rounded-4 p-3 mb-4">
                            <div class="d-flex justify-content-between mb-2">
                                <small class="text-muted">Inicio</small>
                                <span class="fw-semibold">${formatDate(modulo.fecha_inicio)}</span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <small class="text-muted">Finaliza</small>
                                <span class="fw-semibold">${formatDate(modulo.fecha_fin)}</span>
                            </div>
                        </div>
                        <div class="d-flex justify-content-end align-items-center">
                            <span class="text-primary fw-semibold">Ver detalles →</span>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}
