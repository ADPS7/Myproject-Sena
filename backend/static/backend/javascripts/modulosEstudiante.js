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
}

function mostrarvistaModulosEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarModulosEstudiante').style.display = 'block';
    activarMenuEstudiante('modulos');
    cargarModulosEstudiante();
}

function mostrarvistaNotasEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarNotasEstudiante').style.display = 'block';
    activarMenuEstudiante('notas');
}

function mostrarvistaAsistenciaEstudiante() {
    ocultarVistasEstudiante();
    document.getElementById('mostrarAsistenciaEstudiante').style.display = 'block';
    activarMenuEstudiante('asistencia');
}

async function cargarModulosEstudiante() {
    const lista = document.getElementById('listaModulosEstudiante');

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
    const lista = document.getElementById('listaModulosEstudiante');

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
