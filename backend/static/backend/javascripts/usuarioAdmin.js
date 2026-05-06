let cacheAdmins = [], cacheProfesores = [], cacheEstudiantes = [];

// --- 1. FUNCIÓN PARA PINTAR LAS FILAS (REUTILIZABLE) ---
function pintarFilas(tbody, lista) {
    tbody.innerHTML = lista.length === 0 ? '<tr><td colspan="4" class="text-center py-3">Sin resultados</td></tr>' : '';
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
                    <button onclick="eliminarUsuario('${u.id_usuario}', '${u.nombre_completo}')" 
                            class="btn btn-sm btn-light text-danger border shadow-sm" title="Eliminar">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>`;
    });
}

// --- 2. FUNCIONES INDEPENDIENTES POR ROL ---

function gestionarAdmins() {
    const modal = document.getElementById('modalAdmins');
    const tabla = document.getElementById('tabla-admins-body');
    const buscador = document.getElementById('buscarAdminModal');

    modal.addEventListener('show.bs.modal', () => {
        fetch('/get_usuarios/admin').then(res => res.json()).then(data => {
            cacheAdmins = data;
            pintarFilas(tabla, data);
        });
    });

    buscador.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const filtrados = cacheAdmins.filter(u => u.nombre_completo.toLowerCase().includes(term) || u.correo.toLowerCase().includes(term));
        pintarFilas(tabla, filtrados);
    });
}

function gestionarProfesores() {
    const modal = document.getElementById('modalProfesores');
    const tabla = document.getElementById('tabla-profesores-body');
    const buscador = document.getElementById('buscarProfesorModal');

    modal.addEventListener('show.bs.modal', () => {
        fetch('/get_usuarios/profesor').then(res => res.json()).then(data => {
            cacheProfesores = data;
            pintarFilas(tabla, data);
        });
    });

    buscador.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const filtrados = cacheProfesores.filter(u => u.nombre_completo.toLowerCase().includes(term) || u.correo.toLowerCase().includes(term));
        pintarFilas(tabla, filtrados);
    });
}

function gestionarEstudiantes() {
    const modal = document.getElementById('modalEstudiantes');
    const tabla = document.getElementById('tabla-estudiantes-body');
    const buscador = document.getElementById('buscarEstudianteModal');

    modal.addEventListener('show.bs.modal', () => {
        fetch('/get_usuarios/estudiante').then(res => res.json()).then(data => {
            cacheEstudiantes = data;
            pintarFilas(tabla, data);
        });
    });

    buscador.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const filtrados = cacheEstudiantes.filter(u => u.nombre_completo.toLowerCase().includes(term) || u.correo.toLowerCase().includes(term));
        pintarFilas(tabla, filtrados);
    });
}

// --- 3. GESTIÓN DE EDICIÓN ---

window.abrirModalEdicion = (id, nom, ape, mail, fecha, rol) => {
    document.getElementById('edit_user_id').value = id;
    document.getElementById('edit_nombres').value = nom;
    document.getElementById('edit_apellidos').value = ape;
    document.getElementById('edit_correo').value = mail;
    document.getElementById('edit_fecha_nacimiento').value = fecha;
    document.getElementById('edit_rol').value = rol;
    
    const myModal = new bootstrap.Modal(document.getElementById('modalEditarUsuario'));
    myModal.show();
};

document.getElementById('formEditarUsuario').addEventListener('submit', function(e) {
    e.preventDefault();
    const id = document.getElementById('edit_user_id').value;
    const datos = {
        nombres: document.getElementById('edit_nombres').value,
        apellidos: document.getElementById('edit_apellidos').value,
        correo: document.getElementById('edit_correo').value,
        fecha_nacimiento: document.getElementById('edit_fecha_nacimiento').value,
        id_rol: document.getElementById('edit_rol').value
    };

    fetch(`/actualizar_usuario/${id}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(datos)
    }).then(res => res.json()).then(r => {
        if(r.status === 'success') {
            Swal.fire({
                icon: 'success',
                title: '¡Buen trabajo!',
                text: 'El usuario ha sido actualizado con éxito.',
                timer: 2000,
                showConfirmButton: false,
                background: '#fff',
                color: '#212529'
            }).then(() => location.reload());
        } else {
            Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'Hubo un error: ' + r.message
            });
        }
    });
});

// --- 4. GESTIÓN DE ELIMINACIÓN ---

window.eliminarUsuario = (id, nombre) => {
    Swal.fire({
        title: '¿Estás completamente seguro?',
        text: `Estás a punto de eliminar a "${nombre}". Esta acción es irreversible.`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#191b1d', // Color oscuro para combinar con tu estilo
        cancelButtonColor: '#dc3545',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'No, cancelar',
        reverseButtons: true
    }).then((result) => {
        if (result.isConfirmed) {
            fetch(`/eliminar_usuario/${id}`, {
                method: 'DELETE',
            })
            .then(res => res.json())
            .then(r => {
                if (r.status === 'success') {
                    Swal.fire({
                        icon: 'success',
                        title: 'Eliminado',
                        text: 'El usuario ha sido borrado del sistema.',
                        timer: 1500,
                        showConfirmButton: false
                    }).then(() => {
                        // Si el ID borrado es el mismo que el de la sesión activa
                        if (typeof idUsuarioLogueado !== 'undefined' && id == idUsuarioLogueado) {
                            window.location.href = "/logout"; 
                        } else {
                            location.reload();
                        }
                    });
                } else {
                    Swal.fire('Error', 'No se pudo eliminar: ' + r.message, 'error');
                }
            })
            .catch(err => {
                Swal.fire('Error de conexión', 'No se pudo contactar con el servidor', 'error');
            });
        }
    });
};

// --- 5. CONFIGURACIÓN FINAL ---

// Solución para que el teclado funcione en el modal de edición sobre otro modal
document.addEventListener('focusin', (e) => {
    if (e.target.closest('#modalEditarUsuario')) {
        e.stopImmediatePropagation();
    }
}, true);

// Inicializar todas las gestiones al cargar la página
document.addEventListener('DOMContentLoaded', () => {
    gestionarAdmins();
    gestionarProfesores();
    gestionarEstudiantes();
});