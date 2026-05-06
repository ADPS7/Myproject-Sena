// cursosAdmin.js - Versión con depuración
let cursosData = [];

function cargarCursos() {
    console.log("Cargando cursos...");
    fetch('/cursos')
        .then(response => response.json())
        .then(data => {
            console.log("Cursos recibidos:", data);
            cursosData = data;
            renderizarTablaCursos(data);
        })
        .catch(error => console.error('Error cargando cursos:', error));
}

function renderizarTablaCursos(cursos) {
    const tbody = document.getElementById('tbodyCursos');
    if (!tbody) return;

    tbody.innerHTML = '';

    cursos.forEach(curso => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td class="ps-4 fw-medium">${curso.id_curso}</td>
            <td>${curso.nombre}</td>
            <td class="text-center"><span class="badge bg-primary">0</span></td>
            <td class="text-center">0</td>
            <td class="text-end pe-4">
                <button class="btn btn-sm btn-light text-primary me-1" onclick="editarCurso(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')">✏️</button>
                <button class="btn btn-sm btn-light text-danger" onclick="eliminarCurso(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')">🗑️</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

// ==================== CRUD ====================

function abrirModalNuevoCurso() {
    document.getElementById('modalTitle').textContent = 'Nuevo Curso';
    document.getElementById('id_curso_editar').value = '';
    document.getElementById('nombreCurso').value = '';
    new bootstrap.Modal(document.getElementById('modalCurso')).show();
}

function editarCurso(id, nombre) {
    console.log("Editando curso:", id, nombre);
    document.getElementById('modalTitle').textContent = 'Editar Curso';
    document.getElementById('id_curso_editar').value = id;
    document.getElementById('nombreCurso').value = nombre;
    new bootstrap.Modal(document.getElementById('modalCurso')).show();
}

function guardarCurso() {
    const id = document.getElementById('id_curso_editar').value;
    const nombre = document.getElementById('nombreCurso').value.trim();

    if (!nombre) {
        alert("❌ El nombre del curso es obligatorio");
        return;
    }

    const url = id ? `/cursos/editar/${id}` : '/cursos/crear';
    const method = id ? 'PUT' : 'POST';

    console.log(`Enviando ${method} a ${url}`, { nombre });

    fetch(url, {
        method: method,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ nombre: nombre })
    })
    .then(response => {
        console.log("Status:", response.status);
        return response.json();
    })
    .then(data => {
        console.log("Respuesta del servidor:", data);
        if (data.success) {
            bootstrap.Modal.getInstance(document.getElementById('modalCurso')).hide();
            cargarCursos();
            alert(id ? "✅ Curso actualizado" : "✅ Curso creado exitosamente");
        } else {
            alert("❌ Error: " + (data.error || "Desconocido"));
        }
    })
    .catch(error => {
        console.error("Error en fetch:", error);
        alert("❌ Error de conexión con el servidor");
    });
}

function eliminarCurso(id, nombre) {
    if (confirm(`¿Eliminar "${nombre}"?`)) {
        fetch(`/cursos/eliminar/${id}`, { method: 'DELETE' })
        .then(res => res.json())
        .then(data => {
            if (data.success) cargarCursos();
            else alert(data.error || "No se pudo eliminar");
        });
    }
}

function inicializarCursosAdmin() {
    cargarCursos();
}