let cacheAdmins = [], cacheProfesores = [], cacheEstudiantes = [];
let idUsuarioAEliminar = null;

// --- 1. FUNCIÓN PARA PINTAR LAS FILAS ---
function pintarFilas(tbody, lista) {
    tbody.innerHTML = lista.length === 0 ? '<tr><td colspan="4" class="text-center py-3 text-muted">Sin resultados</td></tr>' : '';
    lista.forEach(u => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium">${u.nombre_completo}</td>
                <td class="text-secondary small">${u.correo}</td>
                <td class="text-end pe-4">
                    <button onclick="abrirModalEdicion('${u.id_usuario}','${u.nombres}','${u.apellidos}','${u.correo}','${u.fecha_nacimiento}','${u.id_rol}')" 
                            class="btn btn-sm btn-light text-primary border shadow-sm" title="Editar">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button onclick="eliminarUsuario('${u.id_usuario}', '${u.nombre_completo}', '${u.id_rol}')" 
                            class="btn btn-sm btn-light text-danger border shadow-sm" title="Eliminar">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>`;
    });
}

// --- 2. FUNCIÓN DE REFRESCO DINÁMICO ---
function refrescarTablaPorRol(idRol) {
    let endpoint = '';
    let tablaId = '';
    let cacheName = '';

    if (idRol == "1") { endpoint = 'admin'; tablaId = 'tabla-admins-body'; cacheName = 'cacheAdmins'; }
    else if (idRol == "2") { endpoint = 'estudiante'; tablaId = 'tabla-estudiantes-body'; cacheName = 'cacheEstudiantes'; }
    else if (idRol == "3") { endpoint = 'profesor'; tablaId = 'tabla-profesores-body'; cacheName = 'cacheProfesores'; }

    if (endpoint) {
        fetch(`/get_usuarios/${endpoint}`).then(res => res.json()).then(data => {
            window[cacheName] = data;
            pintarFilas(document.getElementById(tablaId), data);
        });
    }
}

// --- 3. GESTIÓN DE CARGA INICIAL Y BUSCADORES ---
function gestionarRoles() {
    const configuraciones = [
        { modal: 'modalAdmins', tabla: 'tabla-admins-body', buscador: 'buscarAdminModal', endpoint: 'admin', cache: 'cacheAdmins' },
        { modal: 'modalProfesores', tabla: 'tabla-profesores-body', buscador: 'buscarProfesorModal', endpoint: 'profesor', cache: 'cacheProfesores' },
        { modal: 'modalEstudiantes', tabla: 'tabla-estudiantes-body', buscador: 'buscarEstudianteModal', endpoint: 'estudiante', cache: 'cacheEstudiantes' }
    ];

    configuraciones.forEach(conf => {
        const modalEl = document.getElementById(conf.modal);
        modalEl.addEventListener('show.bs.modal', () => {
            fetch(`/get_usuarios/${conf.endpoint}`).then(res => res.json()).then(data => {
                window[conf.cache] = data;
                pintarFilas(document.getElementById(conf.tabla), data);
            });
        });

        document.getElementById(conf.buscador).addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase();
            const filtrados = window[conf.cache].filter(u => 
                u.nombre_completo.toLowerCase().includes(term) || u.correo.toLowerCase().includes(term)
            );
            pintarFilas(document.getElementById(conf.tabla), filtrados);
        });
    });
}

// --- 4. GESTIÓN DE EDICIÓN (CON RESTRICCIÓN DE ADMIN) ---
window.abrirModalEdicion = (id, nom, ape, mail, fecha, rol) => {
    // BLOQUEO: Si el usuario es administrador (rol 1), no permitimos editar
    if (rol == "1") {
        showToast("No tienes permisos para editar a otro Administrador", "error");
        return;
    }

    document.getElementById('edit_user_id').value = id;
    document.getElementById('edit_nombres').value = nom;
    document.getElementById('edit_apellidos').value = ape;
    document.getElementById('edit_correo').value = mail;
    document.getElementById('edit_fecha_nacimiento').value = fecha;
    document.getElementById('edit_rol').value = rol;
    document.getElementById('edit_user_id').dataset.oldRol = rol;

    const myModal = new bootstrap.Modal(document.getElementById('modalEditarUsuario'));
    myModal.show();
};

document.getElementById('formEditarUsuario').addEventListener('submit', function(e) {
    e.preventDefault();
    const id = document.getElementById('edit_user_id').value;
    const oldRol = document.getElementById('edit_user_id').dataset.oldRol;
    const newRol = document.getElementById('edit_rol').value;

    // VALIDACIÓN EXTRA: Evitar que intenten cambiar el rol a Admin desde el formulario
    if (newRol == "1") {
        showToast("No puedes asignar el rol de Administrador", "error");
        return;
    }

    const datos = {
        nombres: document.getElementById('edit_nombres').value,
        apellidos: document.getElementById('edit_apellidos').value,
        correo: document.getElementById('edit_correo').value,
        fecha_nacimiento: document.getElementById('edit_fecha_nacimiento').value,
        id_rol: newRol
    };

    fetch(`/actualizar_usuario/${id}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(datos)
    }).then(res => res.json()).then(r => {
        if(r.status === 'success') {
            bootstrap.Modal.getInstance(document.getElementById('modalEditarUsuario')).hide();
            limpiarBackdrops();
            showToast("Datos actualizados correctamente", "success");
            refrescarTablaPorRol(oldRol);
            if (oldRol !== newRol) refrescarTablaPorRol(newRol);
        } else {
            showToast("Error: " + r.message, "error");
        }
    });
});

// --- 5. GESTIÓN DE ELIMINACIÓN (CON RESTRICCIÓN) ---
window.eliminarUsuario = (id, nombre, rol) => {
    if (rol == "1") {
        showToast("No se puede eliminar a un Administrador", "error");
        return;
    }

    idUsuarioAEliminar = id;
    document.getElementById('nombreUsuarioEliminar').innerText = nombre;
    const modalConfirm = new bootstrap.Modal(document.getElementById('modalConfirmarEliminar'));
    modalConfirm.show();
};

document.getElementById('btnConfirmarEliminar').addEventListener('click', function() {
    if (!idUsuarioAEliminar) return;

    fetch(`/eliminar_usuario/${idUsuarioAEliminar}`, { method: 'DELETE' })
    .then(res => res.json()).then(r => {
        bootstrap.Modal.getInstance(document.getElementById('modalConfirmarEliminar')).hide();
        if (r.status === 'success') {
            limpiarBackdrops();
            showToast("Usuario eliminado correctamente", "success");
            refrescarTablaPorRol("2"); refrescarTablaPorRol("3");
        }
    });
});

// --- 6. UTILS (TOASTS, BACKDROP Y FOCO) ---
function showToast(message, type = "success") {
    const container = document.getElementById('toastContainer');
    const id = Date.now();
    const bgColor = type === "success" ? "#191b1d" : "#dc3545";
    const toastHTML = `
        <div id="toast-${id}" class="toast align-items-center text-white border-0 mb-2 shadow-lg" role="alert" style="background-color: ${bgColor}; border-radius: 12px;">
            <div class="d-flex p-3">
                <div class="toast-body d-flex align-items-center gap-2">
                    <i class="bi ${type === 'success' ? 'bi-check-circle-fill text-success' : 'bi-exclamation-triangle-fill text-warning'}"></i>
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
            <div style="height: 4px; background: rgba(255,255,255,0.1); width: 100%; border-bottom-left-radius: 12px; border-bottom-right-radius: 12px; overflow: hidden;">
                <div id="progress-${id}" style="height: 100%; background: ${type === 'success' ? '#198754' : '#fff'}; width: 100%;"></div>
            </div>
        </div>`;
    container.insertAdjacentHTML('beforeend', toastHTML);
    const toastEl = document.getElementById(`toast-${id}`);
    new bootstrap.Toast(toastEl, { delay: 3000 }).show();
    const pBar = document.getElementById(`progress-${id}`);
    pBar.style.transition = "width 3s linear";
    setTimeout(() => pBar.style.width = "0%", 10);
    toastEl.addEventListener('hidden.bs.toast', () => toastEl.remove());
}

function limpiarBackdrops() {
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    document.body.classList.remove('modal-open');
    document.body.style.overflow = '';
}

document.addEventListener('focusin', (e) => {
    if (e.target.closest('.modal')) e.stopImmediatePropagation();
}, true);

document.addEventListener('DOMContentLoaded', () => gestionarRoles());