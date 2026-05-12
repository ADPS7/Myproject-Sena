// ==========================================
// 1. VARIABLES GLOBALES
// ==========================================
let todosLosModulos = [];
let moduloIdParaEliminar = null; // Para gestionar el modal de borrado

// ==========================================
// 2. UTILIDADES (Notificaciones Toast)
// ==========================================
function mostrarToast(mensaje, tipo = "primary") {
    let toastContainer = document.getElementById("toastContainer");
    if (!toastContainer) {
        toastContainer = document.createElement("div");
        toastContainer.id = "toastContainer";
        toastContainer.className = "toast-container position-fixed bottom-0 end-0 p-3";
        document.body.appendChild(toastContainer);
    }
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
    toastEl.addEventListener('hidden.bs.toast', () => toastEl.remove());
}

// ==========================================
// 3. CARGA DE DATOS Y RENDERIZADO
// ==========================================
function llenarSelectCursos() {
    const selectAgregar = document.getElementById('id_curso_modulo');
    const selectEditar = document.getElementById('edit_id_curso_modulo');

    fetch('/cursos')
        .then(res => res.json())
        .then(cursos => {
            let opciones = '<option value="" selected disabled>Seleccione un curso...</option>';
            cursos.forEach(curso => {
                opciones += `<option value="${curso.id_curso}">${curso.nombre}</option>`;
            });

            if (selectAgregar) selectAgregar.innerHTML = opciones;
            if (selectEditar) selectEditar.innerHTML = opciones;
        });
}

function cargarModulos() {
    const tablaBody = document.getElementById('tabla-modulos-body');
    if(!tablaBody) return;

    fetch('/modulos')
        .then(response => response.json())
        .then(modulos => {
            todosLosModulos = modulos; 
            renderizarTabla(modulos);  
        });
}

function renderizarTabla(lista) {
    const tablaBody = document.getElementById('tabla-modulos-body');
    tablaBody.innerHTML = '';

    if (lista.length === 0) {
        tablaBody.innerHTML = '<tr><td colspan="5" class="text-center p-4">No se encontraron resultados</td></tr>';
        return;
    }

    lista.forEach(modulo => {
        const formatear = (f) => {
            try {
                let d = new Date(f);
                return `${String(d.getUTCDate()).padStart(2, '0')}/${String(d.getUTCMonth() + 1).padStart(2, '0')}/${d.getUTCFullYear()}`;
            } catch(e) { return f; }
        };

        const fila = `
            <tr>
                <td class="ps-4 fw-bold">${modulo.nombre}</td>
                <td class="text-secondary">${modulo.nombre_curso}</td>
                <td>${formatear(modulo.fecha_inicio)}</td>
                <td>${formatear(modulo.fecha_fin)}</td>
                <td class="text-end pe-4">
                    <button onclick="prepararEdicion(${modulo.id_modulo})" class="btn btn-sm btn-light border text-primary shadow-sm"><i class="bi bi-pencil"></i></button>
                    <button onclick="confirmarEliminacion(${modulo.id_modulo})" class="btn btn-sm btn-light border text-danger ms-1 shadow-sm"><i class="bi bi-trash"></i></button>
                </td>
            </tr>`;
        tablaBody.innerHTML += fila;
    });
}

// ==========================================
// 4. LÓGICA DE AGREGAR MÓDULO
// ==========================================
document.getElementById('formAgregarModulo').addEventListener('submit', function(e) {
    e.preventDefault();

    const datosModulo = {
        nombre: document.getElementById('nombre_modulo').value,
        fecha_inicio: document.getElementById('fecha_inicio').value,
        fecha_fin: document.getElementById('fecha_fin').value,
        id_curso: document.getElementById('id_curso_modulo').value
    };

    if (new Date(datosModulo.fecha_inicio) > new Date(datosModulo.fecha_fin)) {
        mostrarToast("La fecha de inicio no puede ser mayor a la de fin", "warning");
        return;
    }

    fetch('/modulos/crear', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(datosModulo)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            // 1. Obtener la instancia del modal y ocultarla
            const modalEl = document.getElementById('modalAgregarModulo');
            const modalInstance = bootstrap.Modal.getInstance(modalEl);
            
            if (modalInstance) {
                modalInstance.hide();
            }

            // 2. LIMPIEZA MANUAL DEL BACKDROP (Esto quita la pantalla opaca)
            const backdrop = document.querySelector('.modal-backdrop');
            if (backdrop) {
                backdrop.remove();
            }
            document.body.classList.remove('modal-open');
            document.body.style.overflow = '';
            document.body.style.paddingRight = '';

            // 3. Limpiar formulario y notificar
            document.getElementById('formAgregarModulo').reset();
            mostrarToast("¡Módulo creado!", "success");
            cargarModulos();
        } else {
            mostrarToast(data.error || "Error al crear", "danger");
        }
    })
    .catch(() => mostrarToast("Error de conexión", "danger"));
});

// ==========================================
// 5. LÓGICA DE EDITAR MÓDULO
// ==========================================
function prepararEdicion(id) {
    const modulo = todosLosModulos.find(m => m.id_modulo === id);

    if (modulo) {
        document.getElementById('edit_id_modulo').value = modulo.id_modulo;
        document.getElementById('edit_nombre_modulo').value = modulo.nombre;
        
        const fInicio = new Date(modulo.fecha_inicio).toISOString().split('T')[0];
        const fFin = new Date(modulo.fecha_fin).toISOString().split('T')[0];
        
        document.getElementById('edit_fecha_inicio').value = fInicio;
        document.getElementById('edit_fecha_fin').value = fFin;
        
        const selectCurso = document.getElementById('edit_id_curso_modulo');
        selectCurso.value = modulo.id_curso; 

        const modalEdit = new bootstrap.Modal(document.getElementById('modalEditarModulo'));
        modalEdit.show();
    }
}
document.getElementById('formEditarModulo').addEventListener('submit', function(e) {
    e.preventDefault();

    const id = document.getElementById('edit_id_modulo').value;
    const datos = {
        nombre: document.getElementById('edit_nombre_modulo').value,
        fecha_inicio: document.getElementById('edit_fecha_inicio').value,
        fecha_fin: document.getElementById('edit_fecha_fin').value,
        id_curso: document.getElementById('edit_id_curso_modulo').value
    };

    // Validación de fechas
    if (new Date(datos.fecha_inicio) > new Date(datos.fecha_fin)) {
        mostrarToast("La fecha de inicio no puede ser mayor a la de fin", "warning");
        return;
    }

    fetch(`/modulos/editar/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(datos)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            if (data.success) {
                // 1. Cerrar modal
                const modalEditEl = document.getElementById('modalEditarModulo');
                const modalInstance = bootstrap.Modal.getInstance(modalEditEl);
                if (modalInstance) modalInstance.hide();

                // 2. Limpieza extrema del backdrop y clases de Bootstrap
                setTimeout(() => {
                    const backdrop = document.querySelector('.modal-backdrop');
                    if (backdrop) backdrop.remove();
                    document.body.classList.remove('modal-open');
                    document.body.style.overflow = '';
                    document.body.style.paddingRight = '';
                }, 100); // Un pequeño retraso para que la animación de Bootstrap termine

                // 3. Notificación azul
                mostrarToast("¡Módulo actualizado correctamente!", "primary");
                
                cargarModulos(); 
            }
        } 
    })
    .catch(() => mostrarToast("Error de conexión con el servidor", "danger"));
});
// ==========================================
// 6. LÓGICA DE ELIMINAR MÓDULO
// ==========================================

// ==========================================
// 6. LÓGICA DE ELIMINAR MÓDULO
// ==========================================
function confirmarEliminacion(id) {
    moduloIdParaEliminar = id;
    const modalConfirm = new bootstrap.Modal(document.getElementById('modalConfirmarEliminar'));
    modalConfirm.show();
}

document.getElementById('btnConfirmarEliminarModulo')?.addEventListener('click', function() {
    if (!moduloIdParaEliminar) return;

    fetch(`/modulos/eliminar/${moduloIdParaEliminar}`, { method: 'DELETE' })
        .then(res => res.json())
        .then(data => {
            // 1. Cerrar modal
            const modalEl = document.getElementById('modalConfirmarEliminar');
            const modalInstance = bootstrap.Modal.getInstance(modalEl);
            if(modalInstance) modalInstance.hide();

            // 2. LIMPIEZA MANUAL DE PANTALLA OPACA
            setTimeout(() => {
                const backdrop = document.querySelector('.modal-backdrop');
                if (backdrop) backdrop.remove();
                document.body.classList.remove('modal-open');
                document.body.style.overflow = '';
                document.body.style.paddingRight = '';
            }, 100);

            // 3. Resultados
            if (data.success) {
                mostrarToast("Módulo eliminado correctamente", "danger");
                cargarModulos();
            } else {
                // Aquí te dirá por qué no deja eliminar (tu petición original)
                mostrarToast(data.error || "No se pudo eliminar", "warning");
            }
        })
        .catch(() => mostrarToast("Error de red", "danger"))
        .finally(() => {
            moduloIdParaEliminar = null;
        });
});

// ==========================================
// 7. BUSCADOR E INICIALIZACIÓN
// ==========================================
document.getElementById('inputBusqueda').addEventListener('input', function(e) {
    const termino = e.target.value.toLowerCase();
    const filtrados = todosLosModulos.filter(modulo => {
        return modulo.nombre.toLowerCase().includes(termino) || 
               modulo.nombre_curso.toLowerCase().includes(termino);
    });
    renderizarTabla(filtrados);
});

// EVENTO ÚNICO DE CARGA
document.addEventListener('DOMContentLoaded', () => {
    llenarSelectCursos();
    cargarModulos();
});