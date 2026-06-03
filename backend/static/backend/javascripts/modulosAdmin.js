// ==========================================
// 1. VARIABLES GLOBALES
// ==========================================
let todosLosModulos = [];
let moduloIdParaEliminar = null; 

let modalAgregar = null;
let modalEditar = null;
let modalEliminar = null;

// ==========================================
// 2. UTILIDADES & LIMPIEZA DE MODALES
// ==========================================
function limpiarModalesALaFuerza() {
    // Remover clases del body
    document.body.classList.remove('modal-open');
    document.body.style.overflow = '';
    document.body.style.paddingRight = '';

    // Remover todos los backdrops
    document.querySelectorAll('.modal-backdrop').forEach(backdrop => {
        backdrop.style.opacity = '0';
        setTimeout(() => backdrop.remove(), 300);
    });

    // Remover posibles modales huérfanos
    document.querySelectorAll('.modal').forEach(modal => {
        modal.classList.remove('show');
        modal.style.display = 'none';
    });
}

// ==========================================
// 3. CARGA DE DATOS Y RENDERIZADO
// ==========================================
// Cambia tu función actual por esta versión mejorada
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
            
            // Actualizamos ambos selects
            if (selectAgregar) selectAgregar.innerHTML = opciones;
            if (selectEditar) selectEditar.innerHTML = opciones;
        })
        .catch(err => console.error("Error al cargar cursos:", err));
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
    if (!tablaBody) return;
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

        // NOTA: Eliminamos onclick="" y usamos clases de control con data-id
        const fila = `
            <tr>
                <td class="ps-4 fw-bold">${modulo.nombre}</td>
                <td class="text-secondary">${modulo.nombre_curso}</td>
                <td>${formatear(modulo.fecha_inicio)}</td>
                <td>${formatear(modulo.fecha_fin)}</td>
                <td class="text-end pe-4">
                    <button data-id="${modulo.id_modulo}" class="btn-editar-modulo btn btn-sm btn-light border text-primary shadow-sm"><i class="bi bi-pencil"></i></button>
                    <button data-id="${modulo.id_modulo}" class="btn-eliminar-modulo btn btn-sm btn-light border text-danger ms-1 shadow-sm"><i class="bi bi-trash"></i></button>
                </td>
            </tr>`;
        tablaBody.innerHTML += fila;
    });
}

// ==========================================
// 4. LÓGICA DE AGREGAR MÓDULO
// ==========================================
document.getElementById('formAgregarModulo')?.addEventListener('submit', function(e) {
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
            if (modalAgregar) modalAgregar.hide();
            limpiarModalesALaFuerza();
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
    const modulo = todosLosModulos.find(m => m.id_modulo === parseInt(id));

    if (modulo) {
        document.getElementById('edit_id_modulo').value = modulo.id_modulo;
        document.getElementById('edit_nombre_modulo').value = modulo.nombre;
        
        const fInicio = new Date(modulo.fecha_inicio).toISOString().split('T')[0];
        const fFin = new Date(modulo.fecha_fin).toISOString().split('T')[0];
        
        document.getElementById('edit_fecha_inicio').value = fInicio;
        document.getElementById('edit_fecha_fin').value = fFin;
        
        document.getElementById('edit_id_curso_modulo').value = modulo.id_curso; 

        if (!modalEditar) modalEditar = new bootstrap.Modal(document.getElementById('modalEditarModulo'));
        if (modalEditar) modalEditar.show();
    }
}

document.getElementById('formEditarModulo')?.addEventListener('submit', function(e) {
    e.preventDefault();

    const id = document.getElementById('edit_id_modulo').value;
    const datos = {
        nombre: document.getElementById('edit_nombre_modulo').value,
        fecha_inicio: document.getElementById('edit_fecha_inicio').value,
        fecha_fin: document.getElementById('edit_fecha_fin').value,
        id_curso: document.getElementById('edit_id_curso_modulo').value
    };

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
            if (modalEditar) modalEditar.hide();
            limpiarModalesALaFuerza();
            mostrarToast("¡Módulo actualizado correctamente!", "primary");
            cargarModulos(); 
        } else {
            mostrarToast(data.error || "Error al actualizar", "danger");
        }
    })
    .catch(() => mostrarToast("Error de conexión con el servidor", "danger"));
});

// ==========================================
// 6. LÓGICA DE ELIMINAR MÓDULO (VERSIÓN MEJORADA)
// ==========================================
document.getElementById('btnConfirmarEliminarModulo')?.addEventListener('click', function() {
    if (!moduloIdParaEliminar) return;

    const btn = this;
    const textoOriginal = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = `<span class="spinner-border spinner-border-sm me-2"></span>Eliminando...`;

    fetch(`/modulos/eliminar/${moduloIdParaEliminar}`, { 
        method: 'DELETE' 
    })
    .then(res => res.json())
    .then(data => {
        if (modalEliminar) modalEliminar.hide();
        
        // Limpiar backdrop de forma agresiva
        setTimeout(limpiarModalesALaFuerza, 300);

        if (data.success) {
            mostrarToast("Módulo eliminado correctamente", "success");
            cargarModulos();
        } else {
            let mensaje = data.error || "No se pudo eliminar el módulo";

            if (typeof mensaje === 'string') {
                const mLow = mensaje.toLowerCase();
                if (mensaje.indexOf('1451') !== -1 || mLow.includes('cannot delete or update a parent row') || mLow.includes('foreign key')) {
                    mensaje = "Este módulo no se puede eliminar porque tiene valores asignados";
                }
            }

            mostrarToast(mensaje, "warning");
        }
    })
    .catch(err => {
        console.error(err);
        mostrarToast("Error de conexión al eliminar", "danger");
    })
    .finally(() => {
        // Restaurar botón
        btn.disabled = false;
        btn.innerHTML = textoOriginal;
        moduloIdParaEliminar = null;
        
        // Segunda limpieza por seguridad
        setTimeout(limpiarModalesALaFuerza, 600);
    });
});

// ==========================================
// 7. BUSCADOR E INICIALIZACIÓN
// ==========================================
document.getElementById('inputBusqueda')?.addEventListener('input', function(e) {
    const termino = e.target.value.toLowerCase();
    const filtrados = todosLosModulos.filter(modulo => {
        return modulo.nombre.toLowerCase().includes(termino) || 
               modulo.nombre_curso.toLowerCase().includes(termino);
    });
    renderizarTabla(filtrados);
});

// EVENTO DE CARGA Y DELEGACIÓN DE EVENTOS
document.addEventListener('DOMContentLoaded', () => {
    // Inicializar instancias iniciales si los elementos existen
    const elAgregar = document.getElementById('modalAgregarModulo').addEventListener('show.bs.modal', function () {
        llenarSelectCursos();
    });
    const elEditar = document.getElementById('modalEditarModulo').addEventListener('show.bs.modal', function () {
        llenarSelectCursos();
    });
    const elEliminar = document.getElementById('modalConfirmarEliminarModulo');

    if (elAgregar) modalAgregar = new bootstrap.Modal(elAgregar);
    if (elEditar) modalEditar = new bootstrap.Modal(elEditar);
    if (elEliminar) modalEliminar = new bootstrap.Modal(elEliminar);

    // ESCUCHADOR INTELIGENTE: Detecta clics en los botones dinámicos de la tabla
    document.getElementById('tabla-modulos-body')?.addEventListener('click', function(e) {
        // Buscar si el clic fue en el botón de eliminar o dentro de su ícono
        const botonEliminar = e.target.closest('.btn-eliminar-modulo');
        const botonEditar = e.target.closest('.btn-editar-modulo');

        if (botonEliminar) {
            moduloIdParaEliminar = botonEliminar.getAttribute('data-id');
            if (!modalEliminar) modalEliminar = new bootstrap.Modal(document.getElementById('modalConfirmarEliminarModulo'));
            if (modalEliminar) modalEliminar.show();
        }

        if (botonEditar) {
            const id = botonEditar.getAttribute('data-id');
            prepararEdicion(id);
        }
    });

    llenarSelectCursos();
    cargarModulos();
});

// ==========================================
// 8. RESTRICCIONES DE ENTRADA (SOLO LETRAS)
// ==========================================
function configurarRestriccionSoloLetras() {
    const campos = document.querySelectorAll('.solo-letras');
    // Regex: permite letras (incluyendo tildes y ñ) y espacios
    const regex = /[^a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]/g;

    campos.forEach(campo => {
        campo.addEventListener('input', function() {
            // Reemplaza cualquier carácter que no sea letra o espacio por vacío
            if (this.value.match(regex)) {
                this.value = this.value.replace(regex, '');
            }
        });
    });
}

// ==========================================
// 9. VALIDACIÓN ADICIONAL ANTES DE ENVIAR
// ==========================================
function esNombreValido(nombre) {
    // Verifica que solo contenga letras y espacios después de trim
    const regex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/;
    return regex.test(nombre.trim());
}
function configurarFechaMinima() {
    const hoy = new Date().toISOString().split('T')[0];
    
    const inputsFecha = [
        document.getElementById('fecha_inicio'),
        document.getElementById('fecha_fin'),
        document.getElementById('edit_fecha_inicio'),
        document.getElementById('edit_fecha_fin')
    ];

    inputsFecha.forEach(input => {
        if (input) {
            input.setAttribute('min', hoy);
        }
    });
}

// ==========================================
// ACTUALIZACIÓN EN EL EVENTO DOMContentLoaded
// ==========================================
document.addEventListener('DOMContentLoaded', () => {

    configurarRestriccionSoloLetras(); 
    configurarFechaMinima()
});