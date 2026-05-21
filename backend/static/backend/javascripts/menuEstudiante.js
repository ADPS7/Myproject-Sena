// =========================================================================
// FUNCIÓN PRINCIPAL: Verifica el estado del perfil campo por campo
// =========================================================================
function datosPersonales() {
    const idUsuario = window.USER_ID;

    // Validación de seguridad para prevenir llamadas con datos corruptos o vacíos
    if (!idUsuario || idUsuario === "undefined" || idUsuario === "None") {
        console.error("Fallo de sesión: No se detectó un ID de usuario válido en el entorno local.");
        return;
    }

    // Petición asíncrona hacia la ruta estructurada de verificación en Flask
    fetch(`/verificar_datos_vacios?id_usuario=${idUsuario}`)
        .then(response => response.json())
        .then(data => {
            // Si el backend determina que 'vacios' es verdadero (al menos un campo está en NULL o en blanco)
            if (data.vacios === true) {
                
                // Despliegue de la ventana emergente restrictiva de SweetAlert2
                Swal.fire({
                    title: '¡Perfil Incompleto!',
                    html: `
                        <p class="mb-2 text-secondary" style="font-size: 0.95rem;">
                            Detectamos que tiene campos pendientes por diligenciar en su perfil institucional.
                        </p>
                        <strong class="d-block mb-1" style="color: #664d03; font-size: 0.9rem;">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> Es obligatorio completar todos sus datos para continuar en la plataforma.
                        </strong>
                    `,
                    icon: 'warning',
                    iconColor: '#ffc107',                   // Color amarillo reactivo para el icono de alerta
                    showCancelButton: false,               // Desactivado: El estudiante no puede omitir el proceso
                    confirmButtonText: 'Actualizar Datos Ahora <i class="bi bi-arrow-right ms-2"></i>',
                    confirmButtonColor: '#198754',          // Color verde éxito unificado con tu interfaz
                    background: '#ffffff',
                    allowOutsideClick: false,              // Bloqueado: No se cierra haciendo clic en el fondo gris
                    allowEscapeKey: false,                 // Bloqueado: Desactiva el cierre con el teclado físico
                    customClass: {
                        popup: 'rounded-4 shadow border-0 p-4',
                        title: 'fw-bold text-dark fs-4',
                        confirmButton: 'btn btn-success px-4 py-2 rounded-3 fw-bold fs-6'
                    }
                }).then((result) => {
                    // Este evento se dispara estrictamente cuando el estudiante presiona el botón verde de confirmación
                    if (result.isConfirmed) {
                        // Redirección dinámica cargando el ID del scope global
                        window.location.href = `/completar-perfil?id_usuario=${idUsuario}`;
                    }
                });

            }
        })
        .catch(error => console.error("Error crítico en el proceso de escaneo de campos:", error));
}

// Inicialización automática del análisis tan pronto se renderiza el módulo en el cliente
datosPersonales();