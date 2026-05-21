function datosPersonales() {
    const idUsuario = window.USER_ID;

    if (!idUsuario || idUsuario === "undefined" || idUsuario === "None") {
        console.error("No se detectó un ID de usuario válido.");
        return;
    }

    fetch(`/verificar_datos_vacios?id_usuario=${idUsuario}`)
        .then(response => response.json())
        .then(data => {
            // Si el backend detectó que la fila no existe o que hay al menos UN campo vacío
            if (data.vacios === true) {
                
                // Disparamos el Toast personalizado en color Amarillo (Advertencia)
                mostrarToast(
                    'Advertencia', 
                    data.mensaje || 'Tiene campos obligatorios pendientes por diligenciar en su perfil.', 
                    'advertencia'
                );

                // Espera de 3 segundos para que lea la advertencia antes de redirigir
                setTimeout(() => {
                    window.location.href = `/completar-perfil?id_usuario=${idUsuario}`;
                }, 3000);
            }
        })
        .catch(error => console.error("Error al verificar los datos uno a uno:", error));
}

// FUNCIÓN AYUDANTE: Genera la alerta Toast dinámica con los estilos de Bootstrap 5
function mostrarToast(titulo, mensaje, tipo) {
    const toastElement = document.getElementById('toastNotificacion');
    const header = document.getElementById('toastHeader');
    const body = document.getElementById('toastMensaje');
    const icono = document.getElementById('toastIcono');
    const btnCerrar = document.getElementById('toastBtnCerrar');

    if (!toastElement) return; // Seguridad por si no se encuentra el elemento en el HTML

    header.className = "toast-header border-0 rounded-top-4 py-2";
    body.className = "toast-body rounded-bottom-4 py-3";
    icono.className = "bi me-2 fs-5";
    btnCerrar.className = "btn-close";

    document.getElementById('toastTitulo').textContent = titulo;
    body.textContent = mensaje;

    if (tipo === 'exito') {
        header.style.backgroundColor = "#e8f5e9";
        header.style.color = "#1b5e20";
        body.classList.add('bg-success', 'text-white');
        icono.classList.add('bi-check-circle-fill');
        btnCerrar.classList.add('btn-close-white');
    } 
    else if (tipo === 'advertencia') {
        header.style.backgroundColor = "#fff3cd";
        header.style.color = "#664d03";
        body.classList.add('bg-warning', 'text-dark');
        icono.classList.add('bi-exclamation-triangle-fill');
        btnCerrar.className = "btn-close";
    } 
    else if (tipo === 'error') {
        header.style.backgroundColor = "#f8d7da";
        header.style.color = "#842029";
        body.classList.add('bg-danger', 'text-white');
        icono.classList.add('bi-x-circle-fill');
        btnCerrar.classList.add('btn-close-white');
    }

    const bootstrapToast = new bootstrap.Toast(toastElement);
    bootstrapToast.show();
}

// Ejecución automática al cargar el módulo del estudiante
datosPersonales();