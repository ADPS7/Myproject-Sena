// backend/javascripts/cursosAdmin.js

let cursosData = [];

function inicializarCursosAdmin() {
    cargarCursos();
}

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
                <tr><td colspan="5" class="text-center py-4 text-danger">
                    Error al cargar los cursos
                </td></tr>`;
        });
}

function renderizarTablaCursos(cursos) {
    const tbody = document.getElementById('tbodyCursos');
    tbody.innerHTML = '';

    if (cursos.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" class="text-center py-4">No hay cursos registrados aún.</td></tr>`;
        return;
    }

    cursos.forEach(curso => {
        const fila = document.createElement('tr');
        fila.innerHTML = `
            <td class="ps-4 fw-medium">${curso.id_curso}</td>
            <td>${curso.nombre}</td>
            <td class="text-end pe-4">
                <button class="btn btn-sm btn-light text-primary me-1" onclick="editarCurso(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')">
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

    if (!nombre) {
    mostrarToast("El nombre del curso es obligatorio", "warning");
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
            alert(data.error || "Error al guardar");
        }
    })
    .catch(() => alert("Error de conexión"));
}

function eliminarCurso(id, nombre) {
    if (confirm(`¿Eliminar el curso "${nombre}"?`)) {
        fetch(`/cursos/eliminar/${id}`, { method: 'DELETE' })
        .then(res => res.json())
        .then(data => {
            if (data.success) cargarCursos();
            else alert(data.error || "No se pudo eliminar");
        });
    }
}

function filtrarCursos() {
    const texto = document.getElementById('buscarCurso').value.toLowerCase();
    const filtrados = cursosData.filter(c => c.nombre.toLowerCase().includes(texto));
    renderizarTablaCursos(filtrados);
}

function mostrarToast(mensaje, tipo = "primary") {
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

    const toast = new bootstrap.Toast(toastEl);
    toast.show();

    // Eliminar después de ocultarse
    toastEl.addEventListener('hidden.bs.toast', () => {
        toastEl.remove();
    });
}