document.addEventListener('DOMContentLoaded', function() {
    // Caché para búsqueda instantánea
    const datosCache = {
        admin: [],
        profesor: [],
        estudiante: []
    };

    const modalesConfig = [
        { id: 'modalAdmins', rol: 'admin', tabla: 'tabla-admins-body', input: 'buscarAdminModal' },
        { id: 'modalProfesores', rol: 'profesor', tabla: 'tabla-profesores-body', input: 'buscarProfesorModal' },
        { id: 'modalEstudiantes', rol: 'estudiante', tabla: 'tabla-estudiantes-body', input: 'buscarEstudianteModal' }
    ];

    modalesConfig.forEach(config => {
        const modalElement = document.getElementById(config.id);
        const inputBusqueda = document.getElementById(config.input);
        
        if (modalElement) {
            // AL ABRIR EL MODAL: Cargar datos desde el servidor
            modalElement.addEventListener('show.bs.modal', function() {
                const tablaBody = document.getElementById(config.tabla);
                
                // Reiniciar buscador y mostrar estado de carga
                if (inputBusqueda) inputBusqueda.value = '';
                tablaBody.innerHTML = '<tr><td colspan="3" class="text-center p-3 text-muted">Cargando datos...</td></tr>';

                fetch(`/get_usuarios/${config.rol}`)
                    .then(response => response.json())
                    .then(data => {
                        datosCache[config.rol] = data; // Guardar en memoria
                        renderizarTabla(config.tabla, data);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        tablaBody.innerHTML = '<tr><td colspan="3" class="text-center text-danger p-3">Error al conectar con el servidor</td></tr>';
                    });
            });

            // AL ESCRIBIR EN EL BUSCADOR: Filtrar localmente
            if (inputBusqueda) {
                inputBusqueda.addEventListener('input', function(e) {
                    const termino = e.target.value.toLowerCase();
                    const listaOriginal = datosCache[config.rol];
                    
                    const filtrados = listaOriginal.filter(user => {
                        const nombre = (user.nombre_completo || "").toLowerCase();
                        const correo = (user.correo || "").toLowerCase();
                        return nombre.includes(termino) || correo.includes(termino);
                    });

                    renderizarTabla(config.tabla, filtrados);
                });
            }
        }
    });

    // --- Reemplaza o actualiza estas partes en tu usuarioAdmin.js ---

// 1. Modificar la función renderizarTabla para que los botones funcionen
function renderizarTabla(idTabla, lista) {
    const tbody = document.getElementById(idTabla);
    tbody.innerHTML = '';

    if (lista.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="text-center p-3 text-muted">No hay resultados</td></tr>';
        return;
    }

    lista.forEach(user => {
        // Obtenemos el rol del ID de la tabla (ej: 'tabla-admins-body' -> extrae 'admin')
        const rolActual = idTabla.split('-')[1].replace('es', '').replace('s', ''); 

        const fila = `
            <tr>
                <td class="ps-4 fw-medium text-dark">${user.nombre_completo}</td>
                <td class="text-secondary">${user.correo}</td>
                <td class="text-end pe-4">
                    <div class="btn-group shadow-sm rounded-3">
                        <button class="btn btn-sm btn-white text-primary border" 
                                onclick="abrirModalEdicion('${user.id_usuario || user.id}', '${user.nombre_completo}', '${user.correo}', '${rolActual}')">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-white text-danger border"><i class="bi bi-trash"></i></button>
                    </div>
                </td>
            </tr>
        `;
        tbody.innerHTML += fila;
    });
}

// 2. Función para llenar el modal con los datos del usuario
window.abrirModalEdicion = function(id, nombre, correo, rol) {
    document.getElementById('edit_user_id').value = id;
    document.getElementById('edit_nombre').value = nombre;
    document.getElementById('edit_correo').value = correo;
    document.getElementById('edit_user_rol').value = rol;
    
    const modal = new bootstrap.Modal(document.getElementById('modalEditarUsuario'));
    modal.show();
};

// 3. Evento para enviar los cambios a Python
document.getElementById('formEditarUsuario').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const id = document.getElementById('edit_user_id').value;
    const rol = document.getElementById('edit_user_rol').value;
    const datos = {
        nombre: document.getElementById('edit_nombre').value,
        correo: document.getElementById('edit_correo').value
    };

    fetch(`/actualizar_usuario/${id}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(datos)
    })
    .then(response => response.json())
    .then(res => {
        if (res.status === 'success') {
            // Cerrar modal
            bootstrap.Modal.getInstance(document.getElementById('modalEditarUsuario')).hide();
            
            // Mensaje de éxito (puedes usar SweetAlert2 aquí)
            alert("Usuario actualizado correctamente");
            
            // Recargar la tabla correspondiente para ver los cambios
            // Buscamos el modal que estaba abierto para refrescarlo
            const modalAbierto = document.querySelector('.modal.show');
            if(modalAbierto) {
                const event = new Event('show.bs.modal');
                modalAbierto.dispatchEvent(event);
            }
        } else {
            alert("Error: " + res.message);
        }
    })
    .catch(error => console.error('Error:', error));
});
});


