// perfilProfesor.js
console.log("✅ perfilProfesor.js cargado");

let toastProfesorElement = null;

function crearToastProfesor() {
    if (document.getElementById('toastNotificacion')) return;
    const toastHTML = `
        <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1100;">
            <div id="toastNotificacion" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header">
                    <strong class="me-auto" id="toastTitulo">Sistema</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
                </div>
                <div class="toast-body" id="toastMensaje"></div>
            </div>
        </div>`;
    document.body.insertAdjacentHTML('beforeend', toastHTML);
}

function notificarProfesor(mensaje, tipo = "success") {
    crearToastProfesor();
    const toast = document.getElementById('toastNotificacion');
    const titulo = document.getElementById('toastTitulo');
    const body = document.getElementById('toastMensaje');

    toast.style.backgroundColor = (tipo === "success") ? '#198754' : '#dc3545';
    toast.style.color = 'white';
    titulo.innerHTML = tipo === "success" 
        ? `<i class="bi bi-check-circle-fill me-2"></i> Éxito` 
        : `<i class="bi bi-exclamation-triangle-fill me-2"></i> Error`;
    
    body.textContent = mensaje;

    if (!toastProfesorElement) {
        toastProfesorElement = new bootstrap.Toast(toast, { delay: 3000 });
    }
    toastProfesorElement.show();
}

function abrirPerfilProfesor() {
    const u = window.usuarioProfesor; // Variable global con datos del profesor
    if (!u) {
        notificarProfesor("Error al obtener datos del perfil", "error");
        return;
    }

    // Formatear fecha para el input date
    let fecha = u.fecha_nacimiento;
    if (fecha && (fecha.includes("GMT") || fecha.includes("T"))) {
        fecha = new Date(fecha).toISOString().split('T')[0];
    }

    document.getElementById('id_usuario_prof').value = u.id_usuario;
    document.getElementById('nombres_prof').value = u.nombres;
    document.getElementById('apellidos_prof').value = u.apellidos;
    document.getElementById('correo_prof').value = u.correo;
    document.getElementById('fecha_nacimiento_prof').value = fecha || "";
    document.getElementById('rol_prof').value = u.rol;

    document.getElementById('nombreCompletoProfesorModal').textContent = `${u.nombres} ${u.apellidos}`;
    document.getElementById('rolProfesorModal').textContent = u.rol;

    new bootstrap.Modal(document.getElementById('modalPerfilProfesor')).show();
}

function guardarPerfilProfesor() {
    const id = document.getElementById('id_usuario_prof').value;
    
    const data = {
        nombres: document.getElementById('nombres_prof').value.trim(),
        apellidos: document.getElementById('apellidos_prof').value.trim(),
        correo: document.getElementById('correo_prof').value.trim(),
        fecha_nacimiento: document.getElementById('fecha_nacimiento_prof').value,
        nueva_clave: document.getElementById('nueva_clave_prof').value.trim()
    };

    if (!data.nombres || !data.apellidos || !data.correo) {
        notificarProfesor("Por favor complete los campos obligatorios.", "error");
        return;
    }

    if (!data.nueva_clave) delete data.nueva_clave;

    fetch(`/actualizar_perfil/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(result => {
        if (result.success) {
            // Actualizar objeto global
            Object.assign(window.usuarioProfesor, data);
            
            // Actualizar UI (Avatares y nombres en la interfaz)
            actualizarInterfazProfesor(data.nombres);

            notificarProfesor("Perfil de profesor actualizado");
            bootstrap.Modal.getInstance(document.getElementById('modalPerfilProfesor')).hide();
        } else {
            notificarProfesor(result.error || "Error al actualizar", "error");
        }
    })
    .catch(err => {
        console.error(err);
        notificarProfesor("Error de conexión", "error");
    });
}

function actualizarInterfazProfesor(nombre) {
    const inicial = nombre.charAt(0).toUpperCase();
    document.querySelectorAll('.avatar').forEach(av => av.textContent = inicial);
    
    // Actualiza etiquetas de nombre en el dashboard (excepto botones de cerrar sesión)
    document.querySelectorAll('.nombre-usuario-display').forEach(el => {
        el.textContent = nombre;
    });
}