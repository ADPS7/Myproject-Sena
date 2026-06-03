// backend/javascripts/cursosAdmin.js

let cursosData = [];
let cursoSeleccionado = null;
let estudiantesDisponiblesCache = [];
let profesoresDisponiblesCache = [];

function cargarCursos() {
    fetch('/cursos')
        .then(res => res.json())
        .then(data => {
            cursosData = data;
            renderizarTablaCursos(data);
        })
        .catch(err => {
            console.error(err);
            document.getElementById('tbodyCursos').innerHTML = `
                <tr><td colspan="3" class="text-center py-4 text-danger">
                    Error al cargar los cursos
                </td></tr>`;
        });
}

function renderizarTablaCursos(cursos) {
    const tbody = document.getElementById('tbodyCursos');
    tbody.innerHTML = '';

    if (cursos.length === 0) {
        tbody.innerHTML = `<tr><td colspan="3" class="text-center py-4">No hay cursos registrados aún.</td></tr>`;
        return;
    }

    cursos.forEach(curso => {
        const fila = document.createElement('tr');
        fila.innerHTML = `
            <td class="ps-4 fw-medium">${curso.id_curso}</td>
            <td>${curso.nombre}</td>
            <td class="text-end pe-4">                <button class="btn btn-sm btn-light text-info me-1" onclick="abrirModalDetalleCurso(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')" title="Ver y gestionar usuarios">
                    <i class="bi bi-people-fill"></i>
                </button>                <button class="btn btn-sm btn-light text-primary me-1" onclick="editarCurso(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')">
                    <i class="bi bi-pencil"></i>
                </button>
                <button class="btn btn-sm btn-light text-danger" onclick="eliminarCurso(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')">
                    <i class="bi bi-trash"></i>
                </button>
            </td>
        `;
        tbody.appendChild(fila);
    });
}

function abrirModalDetalleCurso(id, nombre) {
    cursoSeleccionado = { id, nombre };
    document.getElementById('modalDetalleCursoTitle').textContent = `Curso #${id}`;
    document.getElementById('modalDetalleCursoSubtitle').textContent = nombre;
    cargarEstudiantesCurso();
    cargarProfesoresCurso();
    new bootstrap.Modal(document.getElementById('modalDetalleCurso')).show();
}

function cargarEstudiantesCurso() {
    if (!cursoSeleccionado) return;
    fetch(`/cursos/${cursoSeleccionado.id}/estudiantes`)
        .then(res => res.json())
        .then(data => renderizarEstudiantesCurso(data))
        .catch(err => {
            console.error(err);
            document.getElementById('tablaEstudiantesCurso').innerHTML = '<tr><td colspan="3" class="text-center py-3 text-danger">Error al cargar estudiantes</td></tr>';
        });
}

function cargarProfesoresCurso() {
    if (!cursoSeleccionado) return;
    fetch(`/cursos/${cursoSeleccionado.id}/profesores`)
        .then(res => res.json())
        .then(data => renderizarProfesoresCurso(data))
        .catch(err => {
            console.error(err);
            document.getElementById('tablaProfesoresCurso').innerHTML = '<tr><td colspan="3" class="text-center py-3 text-danger">Error al cargar profesores</td></tr>';
        });
}

function renderizarEstudiantesCurso(estudiantes) {
    const tbody = document.getElementById('tablaEstudiantesCurso');
    if (!Array.isArray(estudiantes) || estudiantes.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">No hay estudiantes asignados</td></tr>';
        return;
    }
    tbody.innerHTML = '';
    estudiantes.forEach(u => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium">${u.nombres} ${u.apellidos}</td>
                <td class="text-secondary small">${u.correo}</td>
                <td class="text-end pe-4">
                    <button class="btn btn-sm btn-light text-danger" onclick="desasignarEstudiante(${u.id_usuario})">
                        <i class="bi bi-person-dash"></i> Desasignar
                    </button>
                </td>
            </tr>`;
    });
}

function renderizarProfesoresCurso(profesores) {
    const tbody = document.getElementById('tablaProfesoresCurso');
    if (!Array.isArray(profesores) || profesores.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">No hay profesores asignados</td></tr>';
        return;
    }
    tbody.innerHTML = '';
    profesores.forEach(u => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium">${u.nombres} ${u.apellidos}</td>
                <td class="text-secondary small">${u.correo}</td>
                <td class="text-end pe-4">
                    <button class="btn btn-sm btn-light text-danger" onclick="desasignarProfesor(${u.id_usuario})">
                        <i class="bi bi-person-dash"></i> Desasignar
                    </button>
                </td>
            </tr>`;
    });
}

function abrirModalAsignarEstudiante() {
    if (!cursoSeleccionado) return;
    fetch('/estudiantes-sin-curso')
        .then(res => res.json())
        .then(data => {
            estudiantesDisponiblesCache = data;
            renderizarEstudiantesDisponibles(data);
            new bootstrap.Modal(document.getElementById('modalAsignarEstudiante')).show();
        })
        .catch(err => {
            console.error(err);
            mostrarToast('Error al cargar estudiantes disponibles', 'danger');
        });
}

function abrirModalAsignarProfesor() {
    if (!cursoSeleccionado) return;
    fetch(`/profesores-disponibles/${cursoSeleccionado.id}`)
        .then(res => res.json())
        .then(data => {
            profesoresDisponiblesCache = data;
            renderizarProfesoresDisponibles(data);
            new bootstrap.Modal(document.getElementById('modalAsignarProfesor')).show();
        })
        .catch(err => {
            console.error(err);
            mostrarToast('Error al cargar profesores disponibles', 'danger');
        });
}

function renderizarEstudiantesDisponibles(estudiantes) {
    const tbody = document.getElementById('tablaEstudiantesDisponibles');
    if (!Array.isArray(estudiantes) || estudiantes.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">No hay estudiantes disponibles</td></tr>';
        return;
    }
    tbody.innerHTML = '';
    estudiantes.forEach(u => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium">${u.nombres} ${u.apellidos}</td>
                <td class="text-secondary small">${u.correo}</td>
                <td class="text-end pe-4">
                    <button class="btn btn-sm btn-light text-success" onclick="asignarEstudiante(${u.id_usuario})">
                        <i class="bi bi-person-plus"></i> Asignar
                    </button>
                </td>
            </tr>`;
    });
}

function renderizarProfesoresDisponibles(profesores) {
    const tbody = document.getElementById('tablaProfesoresDisponibles');
    if (!Array.isArray(profesores) || profesores.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">No hay profesores disponibles</td></tr>';
        return;
    }
    tbody.innerHTML = '';
    profesores.forEach(u => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium">${u.nombres} ${u.apellidos}</td>
                <td class="text-secondary small">${u.correo}</td>
                <td class="text-end pe-4">
                    <button class="btn btn-sm btn-light text-success" onclick="asignarProfesor(${u.id_usuario})">
                        <i class="bi bi-person-plus"></i> Asignar
                    </button>
                </td>
            </tr>`;
    });
}

function asignarEstudiante(idUsuario) {
    if (!cursoSeleccionado) return;
    fetch('/asignar-alumno', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id_usuario: idUsuario, id_curso: cursoSeleccionado.id })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            bootstrap.Modal.getInstance(document.getElementById('modalAsignarEstudiante')).hide();
            mostrarToast(data.message, 'success');
            cargarEstudiantesCurso();
        } else {
            mostrarToast(data.error || 'No se pudo asignar al estudiante', 'danger');
        }
    })
    .catch(() => mostrarToast('Error de conexión', 'danger'));
}

function asignarProfesor(idUsuario) {
    if (!cursoSeleccionado) return;
    fetch('/asignar-profesor', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id_usuario: idUsuario, id_curso: cursoSeleccionado.id })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            bootstrap.Modal.getInstance(document.getElementById('modalAsignarProfesor')).hide();
            mostrarToast(data.message, 'success');
            cargarProfesoresCurso();
        } else {
            mostrarToast(data.error || 'No se pudo asignar al profesor', 'danger');
        }
    })
    .catch(() => mostrarToast('Error de conexión', 'danger'));
}

function desasignarEstudiante(idUsuario) {
    fetch('/desasignar-alumno', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id_usuario: idUsuario })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            mostrarToast(data.message, 'success');
            cargarEstudiantesCurso();
        } else {
            mostrarToast(data.error || 'No se pudo desasignar al estudiante', 'danger');
        }
    })
    .catch(() => mostrarToast('Error de conexión', 'danger'));
}

function desasignarProfesor(idUsuario) {
    if (!cursoSeleccionado) return;
    fetch('/desasignar-profesor', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id_usuario: idUsuario, id_curso: cursoSeleccionado.id })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            mostrarToast(data.message, 'success');
            cargarProfesoresCurso();
        } else {
            mostrarToast(data.error || 'No se pudo desasignar al profesor', 'danger');
        }
    })
    .catch(() => mostrarToast('Error de conexión', 'danger'));
}

function filtrarEstudiantesDisponibles() {
    const termino = document.getElementById('buscarEstudianteDisponible').value.toLowerCase();
    const filtrados = estudiantesDisponiblesCache.filter(u =>
        `${u.nombres} ${u.apellidos}`.toLowerCase().includes(termino) || u.correo.toLowerCase().includes(termino)
    );
    renderizarEstudiantesDisponibles(filtrados);
}

function filtrarProfesoresDisponibles() {
    const termino = document.getElementById('buscarProfesorDisponible').value.toLowerCase();
    const filtrados = profesoresDisponiblesCache.filter(u =>
        `${u.nombres} ${u.apellidos}`.toLowerCase().includes(termino) || u.correo.toLowerCase().includes(termino)
    );
    renderizarProfesoresDisponibles(filtrados);
}

document.addEventListener('DOMContentLoaded', () => {
    const inputNombre = document.getElementById('nombreCurso');
    if (inputNombre) {
        inputNombre.addEventListener('input', function() {
            // Filtra cualquier carácter que NO sea letra o espacio
            this.value = this.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]/g, '');
        });
    }
    cargarCursos();

    const buscadorEstudiantes = document.getElementById('buscarEstudianteDisponible');
    if (buscadorEstudiantes) {
        buscadorEstudiantes.addEventListener('input', filtrarEstudiantesDisponibles);
    }

    const buscadorProfesores = document.getElementById('buscarProfesorDisponible');
    if (buscadorProfesores) {
        buscadorProfesores.addEventListener('input', filtrarProfesoresDisponibles);
    }

    const botonConfirmarEliminar = document.getElementById('btnConfirmarEliminarDoc');
    if (botonConfirmarEliminar) {
        botonConfirmarEliminar.addEventListener('click', () => {
            if (!cursoAEliminar) return;

            const { id, nombre } = cursoAEliminar;

            fetch(`/cursos/eliminar/${id}`, { method: 'DELETE' })
                .then(res => res.json())
                .then(data => {
                    const modalEl = document.getElementById('modalConfirmarEliminarCurso');
                    const modalInstance = bootstrap.Modal.getInstance(modalEl);
                    if (modalInstance) modalInstance.hide();

                    if (data.success) {
                        cargarCursos();
                        mostrarToast(`El curso "${nombre}" ha sido eliminado`, "danger");
                    } else {
                        mostrarToast(data.error || "No se pudo eliminar", "danger");
                    }
                })
                .catch(() => {
                    mostrarToast("Error de conexión", "danger");
                });
        });
    }
});

function abrirModalNuevoCurso() {
    document.getElementById('modalTitle').textContent = 'Nuevo Curso';
    document.getElementById('idCurso').value = '';
    document.getElementById('nombreCurso').value = '';
    new bootstrap.Modal(document.getElementById('modalCurso')).show();
}

function editarCurso(id, nombre) {
    document.getElementById('modalTitle').textContent = 'Editar Curso';
    document.getElementById('idCurso').value = id;
    document.getElementById('nombreCurso').value = nombre;
    new bootstrap.Modal(document.getElementById('modalCurso')).show();
}

function guardarCurso() {
    const id = document.getElementById('idCurso').value;
    const nombre = document.getElementById('nombreCurso').value.trim();
    
    // Nueva validación de seguridad
    const regexSoloLetras = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/;

    if (!nombre) {
        mostrarToast("El nombre del curso es obligatorio", "warning");
        return;
    }

    if (!regexSoloLetras.test(nombre)) {
        mostrarToast("El nombre solo debe contener letras", "danger");
        return;
    }

    const url = id ? `/cursos/editar/${id}` : '/cursos/crear';
    const method = id ? 'PUT' : 'POST';

    fetch(url, {
        method: method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nombre: nombre })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            bootstrap.Modal.getInstance(document.getElementById('modalCurso')).hide();
            cargarCursos();
            mostrarToast(
                id ? "Curso actualizado correctamente" : "Curso creado exitosamente",
                "success"
            );
        } else {
            mostrarToast(data.error || "Error al guardar el curso", "danger");
        }
    })
    .catch(() => mostrarToast("Error de conexión", "danger"));
}

// Variable global temporal para guardar qué curso queremos borrar
let cursoAEliminar = null;

function eliminarCurso(id, nombre) {
    // 1. Guardamos los datos en la variable temporal
    cursoAEliminar = { id, nombre };

    // 2. Mostramos el modal de Bootstrap
    const modalConfirm = new bootstrap.Modal(document.getElementById('modalConfirmarEliminarCurso'));
    modalConfirm.show();
}

function filtrarCursos() {
    const texto = document.getElementById('buscarCurso').value.toLowerCase();
    const filtrados = cursosData.filter(c => c.nombre.toLowerCase().includes(texto));
    renderizarTablaCursos(filtrados);
}

function mostrarToast(mensaje, tipo = "primary") {
    console.log(`[${tipo.toUpperCase()}] ${mensaje}`);
    let toastContainer = document.getElementById("toastContainer");

    // Si no existe, lo creamos
    if (!toastContainer) {
        toastContainer = document.createElement("div");
        toastContainer.id = "toastContainer";
        toastContainer.className = "toast-container position-fixed bottom-0 end-0 p-3";
        document.body.appendChild(toastContainer);
    }

    // Crear toast
    const toastEl = document.createElement("div");
    toastEl.className = `toast align-items-center text-bg-${tipo} border-0`;
    toastEl.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">${mensaje}</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    `;

    toastContainer.appendChild(toastEl);

    const toast = bootstrap.Toast.getOrCreateInstance(toastEl, { autohide: true, delay: 3000 });
    toastEl.classList.add('show');
    toast.show();

    // Eliminar después de ocultarse
    toastEl.addEventListener('hidden.bs.toast', () => {
        toastEl.remove();
    });
}