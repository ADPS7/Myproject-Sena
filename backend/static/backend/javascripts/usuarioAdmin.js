// Declaración de cachés compartidas
let cacheProfesores = [], cacheEstudiantes = [], cacheCoordinadores = [];
let idUsuarioAEliminar = null;

// --- 1. FUNCIÓN PARA PINTAR LAS FILAS ---
function pintarFilas(tbody, lista) {
    tbody.innerHTML = lista.length === 0
        ? '<tr><td colspan="4" class="text-center py-3 text-muted">Sin resultados</td></tr>'
        : '';
    lista.forEach(u => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium">${u.nombre_completo}</td>
                <td class="text-secondary small">${u.correo}</td>
                <td class="text-end pe-4">
                    <button onclick="abrirModalEdicion('${u.id_usuario}', '${u.id_rol}')"
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
    let endpoint = '', tablaId = '', cacheName = '';

    if      (idRol == "2") { endpoint = 'estudiante';   tablaId = 'tabla-estudiantes-body';   cacheName = 'cacheEstudiantes'; }
    else if (idRol == "3") { endpoint = 'profesor';     tablaId = 'tabla-profesores-body';    cacheName = 'cacheProfesores'; }
    else if (idRol == "4") { endpoint = 'coordinador';  tablaId = 'tabla-coordinadores-body'; cacheName = 'cacheCoordinadores'; }

    if (endpoint) {
        fetch(`/get_usuarios/${endpoint}`)
            .then(res => res.json())
            .then(data => {
                window[cacheName] = data;
                pintarFilas(document.getElementById(tablaId), data);
            });
    }
}

// --- 3. GESTIÓN DE CARGA INICIAL Y BUSCADORES ---
function gestionarRoles() {
    const configuraciones = [
        { modal: 'modalProfesores',    tabla: 'tabla-profesores-body',    buscador: 'buscarProfesorModal',    endpoint: 'profesor',    cache: 'cacheProfesores' },
        { modal: 'modalEstudiantes',   tabla: 'tabla-estudiantes-body',   buscador: 'buscarEstudianteModal',  endpoint: 'estudiante',  cache: 'cacheEstudiantes' },
        { modal: 'modalCoordinadores', tabla: 'tabla-coordinadores-body', buscador: 'buscarCoordinadorModal', endpoint: 'coordinador', cache: 'cacheCoordinadores' }
    ];

    configuraciones.forEach(conf => {
        const modalEl = document.getElementById(conf.modal);
        if (!modalEl) return;

        modalEl.addEventListener('show.bs.modal', () => {
            fetch(`/get_usuarios/${conf.endpoint}`)
                .then(res => res.json())
                .then(data => {
                    window[conf.cache] = data;
                    pintarFilas(document.getElementById(conf.tabla), data);
                });
        });

        document.getElementById(conf.buscador).addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase();
            const filtrados = window[conf.cache].filter(u =>
                u.nombre_completo.toLowerCase().includes(term) ||
                u.correo.toLowerCase().includes(term)
            );
            pintarFilas(document.getElementById(conf.tabla), filtrados);
        });
    });
}

// --- 4. ABRIR MODAL: carga datos frescos desde el servidor ---
window.abrirModalEdicion = (id, rol) => {
    if (rol == "1") {
        showToast("No tienes permisos para editar a un Administrador", "error");
        return;
    }

    // Cargar datos completos del usuario antes de abrir el modal
    fetch(`/obtener_perfil_completo?id_usuario=${id}`)
        .then(res => res.json())
        .then(response => {
            if (response.status !== 'success') {
                showToast(response.message || "No se pudieron cargar los datos del usuario", "error");
                return;
            }

            const u = response.data || {};

            // Formatear fecha a YYYY-MM-DD
            let fecha = u.fecha_nacimiento || '';
            if (fecha) {
                try {
                    const d = new Date(fecha);
                    if (!isNaN(d.getTime())) {
                        fecha = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
                    }
                } catch(_) {}
            }

            // Datos básicos
            document.getElementById('edit_user_id').value = u.id_usuario;
            document.getElementById('edit_user_id').dataset.oldRol = u.id_rol;
            document.getElementById('edit_nombres').value = u.nombres || '';
            document.getElementById('edit_apellidos').value = u.apellidos || '';
            document.getElementById('edit_correo').value = u.correo || '';
            document.getElementById('edit_fecha_nacimiento').value = fecha;
            document.getElementById('edit_rol').value = u.id_rol || '';
            document.getElementById('edit_sexo').value = u.Sexo || '';

            // Documento
            document.getElementById('edit_tipo_documento').value = u.tipo_documento || '';
            document.getElementById('edit_numero_documento').value = u.numero_documento || '';

            // Ubicación y contacto
            document.getElementById('edit_departamento').value = u.departamento || '';
            document.getElementById('edit_municipio').value = u.municipio || '';
            document.getElementById('edit_direccion').value = u.direccion || '';
            document.getElementById('edit_telefono').value = u.telefono || '';
            document.getElementById('edit_telefono_emergencia').value = u.telefono_emergencia || '';

            // Otros datos
            document.getElementById('edit_estrato').value = u.Estrato || '';
            document.getElementById('edit_eps').value     = u.eps || '';

            new bootstrap.Modal(document.getElementById('modalEditarUsuario')).show();
        })
        .catch(() => showToast("Error al conectar con el servidor", "error"));
};

// --- 5. SUBMIT: enviar todos los campos al endpoint ---
document.getElementById('formEditarUsuario').addEventListener('submit', function(e) {
    e.preventDefault();

    const id = document.getElementById('edit_user_id').value;
    const oldRol = document.getElementById('edit_user_id').dataset.oldRol;
    const newRol = document.getElementById('edit_rol').value;

    if (newRol === '1' || !newRol) {
        showToast('Acción denegada: No se puede asignar el rol de Administrador', 'error');
        return;
    }

    const telefono = document.getElementById('edit_telefono').value.trim();
    const telefonoEmergencia = document.getElementById('edit_telefono_emergencia').value.trim();

    if (telefono && telefonoEmergencia && telefono === telefonoEmergencia) {
        showToast('El teléfono personal y el de emergencia no pueden ser iguales.', 'error');
        document.getElementById('edit_telefono_emergencia').focus();
        return;
    }

    const datos = {
        nombres: document.getElementById('edit_nombres').value.trim(),
        apellidos: document.getElementById('edit_apellidos').value.trim(),
        correo: document.getElementById('edit_correo').value.trim(),
        fecha_nacimiento: document.getElementById('edit_fecha_nacimiento').value,
        id_rol: newRol,
        sexo: document.getElementById('edit_sexo').value,
        tipo_documento: document.getElementById('edit_tipo_documento').value,
        numero_documento: document.getElementById('edit_numero_documento').value.trim(),
        departamento: document.getElementById('edit_departamento').value.trim(),
        municipio: document.getElementById('edit_municipio').value.trim(),
        direccion: document.getElementById('edit_direccion').value.trim(),
        telefono: telefono,
        telefono_emergencia: telefonoEmergencia,
        estrato: document.getElementById('edit_estrato').value,
        eps: document.getElementById('edit_eps').value.trim()
    };

    fetch(`/actualizar_usuario/${id}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(datos)
    })
    .then(res => res.json())
    .then(r => {
        if (r.status === 'success') {
            bootstrap.Modal.getInstance(document.getElementById('modalEditarUsuario')).hide();
            limpiarBackdrops();
            showToast('Datos actualizados correctamente', 'success');
            refrescarTablaPorRol(oldRol);
            if (oldRol !== newRol) {
                refrescarTablaPorRol(newRol);
            }
        } else {
            showToast('Error: ' + r.message, 'error');
        }
    })
    .catch(() => showToast('No se pudo conectar con el servidor', 'error'));
});

// --- 6. GESTIÓN DE ELIMINACIÓN ---
window.eliminarUsuario = (id, nombre, rol) => {
    if (rol == "1") {
        showToast("No se puede eliminar a un Administrador", "error");
        return;
    }
    idUsuarioAEliminar = id;
    document.getElementById('nombreUsuarioEliminar').innerText = nombre;
    new bootstrap.Modal(document.getElementById('modalConfirmarEliminarUsuario')).show();
};

document.getElementById('btnConfirmarEliminar').addEventListener('click', function() {
    if (!idUsuarioAEliminar) return;

    fetch(`/eliminar_usuario/${idUsuarioAEliminar}`, { method: 'DELETE' })
        .then(res => res.json())
        .then(r => {
            bootstrap.Modal.getInstance(document.getElementById('modalConfirmarEliminarUsuario')).hide();
            if (r.status === 'success') {
                limpiarBackdrops();
                showToast("Usuario eliminado correctamente", "success");
                refrescarTablaPorRol("2");
                refrescarTablaPorRol("3");
                refrescarTablaPorRol("4");
            }
        });
});

// --- 7. UTILS ---
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

let cacheInactivos = [];

function cargarUsuariosInactivos() {
    fetch('/get_usuarios/inactivo')
        .then(res => res.json())
        .then(data => {
            cacheInactivos = data || [];
            pintarFilasInactivos(document.getElementById('tabla-inactivos-body'), cacheInactivos);
        })
        .catch(err => {
            console.error(err);
            showToast("Error al cargar usuarios inactivos", "error");
        });
}

function pintarFilasInactivos(tbody, lista) {
    tbody.innerHTML = lista.length === 0 
        ? `<tr><td colspan="3" class="text-center py-4 text-muted">No hay usuarios inactivos</td></tr>`
        : '';

    lista.forEach(u => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium">${u.nombre_completo}</td>
                <td class="text-secondary small">${u.correo}</td>
                <td class="text-end pe-4">
                    <button onclick="activarUsuario(${u.id_usuario}, '${u.nombre_completo}')"
                            class="btn btn-sm btn-success border shadow-sm px-3">
                        <i class="bi bi-check-circle me-1"></i> Activar
                    </button>
                </td>
            </tr>`;
    });
}

window.activarUsuario = (idUsuario, nombre) => {
    fetch(`/usuarios/${idUsuario}/rol`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rol: 'estudiante' })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            showToast(`✅ Usuario ${nombre} activado correctamente`, 'success');
            cargarUsuariosInactivos();
        } else {
            showToast(data.message || 'Error al activar el usuario', 'error');
        }
    })
    .catch(() => {
        showToast('Error de conexión con el servidor', 'error');
    });
};

document.getElementById('modalInactivos').addEventListener('show.bs.modal', cargarUsuariosInactivos);

document.getElementById('buscarInactivosModal').addEventListener('input', (e) => {
    const term = e.target.value.toLowerCase().trim();
    const filtrados = cacheInactivos.filter(u => 
        u.nombre_completo.toLowerCase().includes(term) || 
        u.correo.toLowerCase().includes(term)
    );
    pintarFilasInactivos(document.getElementById('tabla-inactivos-body'), filtrados);
});