// perfilAdmin.js - Versión Completa (Toast + Menú Móvil)


// ==================== TOAST DINÁMICO ====================
function crearToastSiNoExiste() {
    if (document.getElementById('toastNotificacion')) return;

    const toastHTML = `
        <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1100;">
            <div id="toastNotificacion" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header">
                    <strong class="me-auto" id="toastTitulo">Notificación</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
                </div>
                <div class="toast-body" id="toastMensaje"></div>
            </div>
        </div>`;

    document.body.insertAdjacentHTML('beforeend', toastHTML);
}

let toastElement = null;

function mostrarToast(mensaje, tipo = "success") {
    crearToastSiNoExiste();

    const toast = document.getElementById('toastNotificacion');
    const titulo = document.getElementById('toastTitulo');
    const body = document.getElementById('toastMensaje');

    if (tipo === "success") {
        titulo.innerHTML = `<i class="bi bi-check-circle-fill text-success me-2"></i>Éxito`;
        toast.style.backgroundColor = '#198754';
        toast.style.color = 'white';
    } else {
        titulo.innerHTML = `<i class="bi bi-x-circle-fill text-danger me-2"></i>Error`;
        toast.style.backgroundColor = '#dc3545';
        toast.style.color = 'white';
    }

    body.textContent = mensaje;

    if (!toastElement) {
        toastElement = new bootstrap.Toast(toast, { delay: 3500 });
    }
    toastElement.show();
}

// ==================== FUNCIONES PRINCIPALES ====================

function abrirPerfilAdmin() {
    const userData = window.usuarioAdmin;
    if (!userData) {
        mostrarToast("No se pudieron cargar los datos del usuario", "error");
        return;
    }

    let fechaFormateada = userData.fecha_nacimiento;
    if (fechaFormateada && fechaFormateada.includes("GMT")) {
        const fecha = new Date(fechaFormateada);
        fechaFormateada = fecha.toISOString().split('T')[0];
    }

    document.getElementById('id_usuario').value = userData.id_usuario;
    document.getElementById('nombres').value = userData.nombres;
    document.getElementById('apellidos').value = userData.apellidos;
    document.getElementById('correo').value = userData.correo;
    document.getElementById('fecha_nacimiento').value = fechaFormateada || "";
    document.getElementById('rol').value = userData.rol;

    document.getElementById('nombreCompletoModal').textContent = `${userData.nombres} ${userData.apellidos}`;
    document.getElementById('rolModal').textContent = userData.rol;

    new bootstrap.Modal(document.getElementById('modalPerfilAdmin')).show();
}

// Función especial para Menú Móvil
function abrirPerfilAdminYcerrarMenu() {
    const offcanvasElement = document.getElementById('mobileMenu');
    const offcanvas = bootstrap.Offcanvas.getInstance(offcanvasElement);
    
    if (offcanvas) {
        offcanvas.hide();
    }

    setTimeout(() => {
        abrirPerfilAdmin();
    }, 350);
}

function guardarPerfil() {
    const id_usuario = document.getElementById('id_usuario').value;
    
    const data = {
        nombres: document.getElementById('nombres').value.trim(),
        apellidos: document.getElementById('apellidos').value.trim(),
        correo: document.getElementById('correo').value.trim(),
        fecha_nacimiento: document.getElementById('fecha_nacimiento').value,
        nueva_clave: document.getElementById('nueva_clave').value.trim()
    };

    if (!data.nombres || !data.apellidos || !data.correo || !data.fecha_nacimiento) {
        mostrarToast("Los campos Nombres, Apellidos, Correo y Fecha son obligatorios.", "error");
        return;
    }

    if (!data.nueva_clave) delete data.nueva_clave;

    fetch(`/actualizar_perfil/${id_usuario}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(result => {
        if (result.success) {
            window.usuarioAdmin.nombres = data.nombres;
            window.usuarioAdmin.apellidos = data.apellidos;
            window.usuarioAdmin.correo = data.correo;
            window.usuarioAdmin.fecha_nacimiento = data.fecha_nacimiento;

            actualizarTodoElPerfil(data.nombres, data.apellidos);

            mostrarToast("Perfil actualizado correctamente");
            bootstrap.Modal.getInstance(document.getElementById('modalPerfilAdmin')).hide();
        } else {
            mostrarToast(result.error || "No se pudo actualizar el perfil", "error");
        }
    })
    .catch(err => {
        console.error(err);
        mostrarToast("Error de conexión con el servidor", "error");
    });
}

function actualizarTodoElPerfil(nuevosNombres, nuevosApellidos) {
    const inicial = nuevosNombres.charAt(0).toUpperCase();

    document.querySelectorAll('.avatar').forEach(avatar => {
        avatar.textContent = inicial;
    });

    document.querySelectorAll('p.fw-bold.small, .fw-bold.small').forEach(el => {
        if (el.textContent && el.textContent.length > 1 && 
            !el.textContent.includes("Cerrar") && 
            !el.textContent.includes("Sesión")) {
            el.textContent = nuevosNombres;
        }
    });
}