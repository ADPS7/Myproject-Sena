let datosCursosAsistencia = [];
let cursoSeleccionado = null;
let modulosSeleccionados = [];
let cursosAsistenciaCargados = false;

console.log('[asistenciaProfesor.js] Script cargado, window.USER_ID =', window.USER_ID);

document.addEventListener('DOMContentLoaded', () => {
    const vista = document.getElementById('mostrarAsistenciaProfesor');
    if (vista) {
        console.log('[asistenciaProfesor.js] Vista de asistencia disponible en el DOM, precargando cursos');
        cargarCursosAsistencia();
    }
});

async function cargarCursosAsistencia() {
    if (cursosAsistenciaCargados) {
        console.log('[asistenciaProfesor.js] Cursos de asistencia ya cargados, omitiendo nueva petición');
        renderizarCursosAsistencia();
        return;
    }

    try {
        // Esperar hasta que USER_ID esté disponible
        let idProfesor = window.USER_ID;
        let intentos = 0;
        
        while (!idProfesor && intentos < 5) {
            await new Promise(resolve => setTimeout(resolve, 100));
            idProfesor = window.USER_ID;
            intentos++;
        }
        
        if (!idProfesor) {
            throw new Error('No se pudo obtener el ID del usuario');
        }

        console.log('Cargando cursos del profesor:', idProfesor);
        const response = await fetch(`/cursos/profesor/${idProfesor}`);
        const cursos = await response.json();

        if (!Array.isArray(cursos)) {
            throw new Error('Respuesta inesperada del servidor');
        }

        datosCursosAsistencia = cursos;
        cursosAsistenciaCargados = true;
        console.log('Cursos cargados:', cursos);
        renderizarCursosAsistencia();
    } catch (error) {
        console.error('Error al cargar cursos de asistencia:', error);
        const contenedor = document.getElementById('contenedor-asistencia');
        if (contenedor) {
            contenedor.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-danger shadow-sm">
                        Error: ${error.message}. Intenta recargar la página.
                    </div>
                </div>
            `;
        }
    }
}


function renderizarCursosAsistencia() {
    const contenedor = document.getElementById('contenedor-asistencia');
    const navContainer = document.getElementById('back-button-asistencia');

    if (!contenedor) {
        console.error('[renderizarCursosAsistencia] Contenedor no encontrado');
        return;
    }

    document.getElementById('view-title').innerText = 'Mis Cursos';
    document.getElementById('view-subtitle').innerText = 'Selecciona un curso para ver sus módulos y tomar asistencia.';
    if (navContainer) navContainer.innerHTML = '';

    if (!datosCursosAsistencia.length) {
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    No tienes cursos asignados para tomar asistencia.
                </div>
            </div>`;
        return;
    }

    contenedor.innerHTML = datosCursosAsistencia.map(curso => `
        <div class="col-12 col-md-6 col-lg-4">
            <div class="card card-asistencia shadow-sm p-4 h-100 cursor-pointer" onclick="verModulosAsistencia(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')">
                <div class="d-flex align-items-center">
                    <div class="bg-primary bg-opacity-10 text-primary p-3 rounded-circle me-3">
                        <i class="bi bi-book-half fs-3"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-0">${curso.nombre}</h5>
                        <small class="text-muted">Ver módulos y estudiantes</small>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

async function verModulosAsistencia(idCurso, nombreCurso) {
    try {
        const response = await fetch(`/modulos/curso/${idCurso}`);
        const modulos = await response.json();

        cursoSeleccionado = { id_curso: idCurso, nombre: nombreCurso };
        modulosSeleccionados = modulos;
        renderizarModulosAsistencia(nombreCurso, modulos);
    } catch (error) {
        console.error('Error al cargar módulos:', error);
        const contenedor = document.getElementById('contenedor-asistencia');
        if (contenedor) {
            contenedor.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-danger shadow-sm">
                        No se pudieron cargar los módulos. Intenta de nuevo.
                    </div>
                </div>
            `;
        }
    }
}

function renderizarModulosAsistencia(nombreCurso, modulos) {
    const contenedor = document.getElementById('contenedor-asistencia');
    const navContainer = document.getElementById('back-button-asistencia');

    document.getElementById('view-title').innerText = nombreCurso;
    document.getElementById('view-subtitle').innerText = 'Selecciona un módulo para tomar asistencia.';
    if (navContainer) {
        navContainer.innerHTML = `
            <button class="btn btn-outline-secondary rounded-pill btn-sm" onclick="renderizarCursosAsistencia()">
                <i class="bi bi-arrow-left"></i> Volver a Cursos
            </button>`;
    }

    if (!modulos.length) {
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    Este curso no tiene módulos registrados.
                </div>
            </div>`;
        return;
    }

    contenedor.innerHTML = modulos.map(mod => `
        <div class="col-12 col-md-6">
            <div class="card card-asistencia shadow-sm p-3 border-start border-primary border-4" 
                 onclick="verEstudiantesAsistencia(${mod.id_modulo}, '${mod.nombre.replace(/'/g, "\\'")}')" style="cursor:pointer">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="fw-bold mb-0">${mod.nombre}</h6>
                        <small class="text-muted">Ver alumnos y registrar asistencia</small>
                    </div>
                    <span class="badge bg-light text-dark border">Ver lista</span>
                </div>
            </div>
        </div>
    `).join('');
}

async function verEstudiantesAsistencia(idModulo, nombreModulo) {
    try {
        const response = await fetch(`/modulo/${idModulo}/students`);
        const estudiantes = await response.json();
        renderizarAsistenciaEstudiantes(idModulo, nombreModulo, estudiantes);
    } catch (error) {
        console.error('Error al cargar estudiantes:', error);
        const contenedor = document.getElementById('contenedor-asistencia');
        if (contenedor) {
            contenedor.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-danger shadow-sm">
                        No se pudieron cargar los estudiantes. Intenta de nuevo.
                    </div>
                </div>
            `;
        }
    }
}

function renderizarAsistenciaEstudiantes(idModulo, nombreModulo, estudiantes) {
    const contenedor = document.getElementById('contenedor-asistencia');
    const navContainer = document.getElementById('back-button-asistencia');

    document.getElementById('view-title').innerText = nombreModulo;
    document.getElementById('view-subtitle').innerText = 'Marca presente o ausente para cada estudiante.';
    if (navContainer) {
        navContainer.innerHTML = `
            <button class="btn btn-outline-secondary rounded-pill btn-sm" onclick="renderizarModulosAsistencia('${cursoSeleccionado ? cursoSeleccionado.nombre.replace(/'/g, "\\'") : ''}', modulosSeleccionados)">
                <i class="bi bi-arrow-left"></i> Volver a Módulos
            </button>`;
    }

    const hoy = new Date().toISOString().split('T')[0];
    contenedor.innerHTML = `
        <div class="col-12 mb-4">
            <div class="card border-0 shadow-sm overflow-hidden rounded-4">
                <div class="card-body p-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold">Fecha</label>
                            <input id="fecha-asistencia" type="date" class="form-control" value="${hoy}">
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="select-all-estudiantes" onchange="toggleSeleccionTodos(this.checked)">
                                <label class="form-check-label" for="select-all-estudiantes">
                                    Marcar todos como presentes
                                </label>
                            </div>
                        </div>
                        <div class="col-12 col-md-4 text-md-end">
                            <button class="btn btn-primary rounded-pill px-4" onclick="guardarAsistencia(${idModulo})">
                                <i class="bi bi-check2-circle"></i> Registrar asistencia
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12">
            <div class="card border-0 shadow-sm overflow-hidden rounded-4">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="bg-light">
                            <tr>
                                <th class="ps-4">Estado</th>
                                <th>Nombre</th>
                                <th>Correo</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${estudiantes.length > 0 ? estudiantes.map(est => `
                                <tr>
                                    <td class="ps-4">
                                        <select class="form-select form-select-sm asistencia-status" data-id="${est.id_usuario}" aria-label="Estado de asistencia">
                                            <option value="SI">Presente</option>
                                            <option value="NO">Ausente</option>
                                        </select>
                                    </td>
                                    <td class="fw-semibold">${est.nombres} ${est.apellidos}</td>
                                    <td>${est.correo}</td>
                                </tr>
                            `).join('') : `
                                <tr>
                                    <td colspan="3" class="text-center py-4 text-muted">
                                        No hay estudiantes registrados en este módulo.
                                    </td>
                                </tr>
                            `}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    `;
}

function toggleSeleccionTodos(checked) {
    document.querySelectorAll('.asistencia-status').forEach(select => {
        select.value = checked ? 'SI' : 'NO';
    });
}

async function guardarAsistencia(idModulo) {
    const fechaInput = document.getElementById('fecha-asistencia');
    if (!fechaInput) return;

    const fecha = fechaInput.value;
    if (!fecha) {
        mostrarToast('Atención', 'Selecciona una fecha para registrar la asistencia.', 'warning');
        return;
    }

    const asistenciaEstudiantes = Array.from(document.querySelectorAll('.asistencia-status')).map(select => ({
        id_usuario: Number(select.dataset.id),
        asistio: select.value === 'SI' ? 'SI' : 'NO'
    }));

    if (!asistenciaEstudiantes.length) {
        mostrarToast('Atención', 'No hay estudiantes disponibles para registrar asistencia.', 'warning');
        return;
    }

    try {
        const response = await fetch('/asistencia/registrar', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                id_modulo: idModulo,
                asistencias: asistenciaEstudiantes,
                fecha: fecha
            })
        });

        const res = await response.json();
        if (res.success) {
            mostrarToast('Éxito', 'Asistencia registrada correctamente.', 'success');
            renderizarCursosAsistencia();
        } else {
            throw new Error(res.error || 'Error al guardar la asistencia.');
        }
    } catch (error) {
        console.error('Error al guardar asistencia:', error);
        mostrarToast('Error', 'No se pudo guardar la asistencia. Revisa la consola para más detalles.', 'danger');
    }
}

function mostrarToast(titulo, mensaje, tipo = 'primary') {
    let toastContainer = document.getElementById('toastContainer');
    if (!toastContainer) {
        toastContainer = document.createElement('div');
        toastContainer.id = 'toastContainer';
        toastContainer.className = 'toast-container position-fixed bottom-0 end-0 p-3';
        document.body.appendChild(toastContainer);
    }

    const toastEl = document.createElement('div');
    toastEl.className = `toast align-items-center text-bg-${tipo} border-0 mb-2 shadow`;
    toastEl.setAttribute('role', 'alert');
    toastEl.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">
                <strong>${titulo}</strong><br>
                <span>${mensaje}</span>
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    `;

    toastContainer.appendChild(toastEl);
    const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
    toast.show();
    toastEl.addEventListener('hidden.bs.toast', () => toastEl.remove());
}

// Observador para detectar cuando la vista de asistencia se vuelve visible
(function observarVistaAsistencia() {
    const vista = document.getElementById('mostrarAsistenciaProfesor');
    if (!vista) {
        console.warn('[asistenciaProfesor.js] No se encontró el contenedor mostrarAsistenciaProfesor');
        return;
    }

    const observer = new MutationObserver(() => {
        const estilo = window.getComputedStyle(vista);
        if (estilo.display !== 'none') {
            console.log('[asistenciaProfesor.js] Vista de asistencia visible, cargando cursos...');
            observer.disconnect();
            if (typeof cargarCursosAsistencia === 'function') {
                cargarCursosAsistencia();
            }
        }
    });

    observer.observe(vista, { attributes: true, attributeFilter: ['style', 'class'] });
})();
