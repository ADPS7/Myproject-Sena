function mostrarvistaInicioCoordinador() {
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaCoordinador").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilCoordinador").style = "display: none;"
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: block;"
}

function mostrarvistaUsuarioCoordinador() {
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaCoordinador").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilCoordinador").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: block;"
}

function mostrarvistaModulosCoordinador() {
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaCoordinador").style = "display: none;"
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilCoordinador").style = "display: none;"
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:block;"
}

function mostrarvistaCursosCoordinador() {
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    asistencia = document.getElementById("mostrarAsistenciaCoordinador").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilCoordinador").style = "display: none;"
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: block;"
}

function mostrarvistaAsistenciaCoordinador() {
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilCoordinador").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaCoordinador").style = "display: block;"
}


function abrirPerfilCoordinador() {
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaCoordinador").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilCoordinador").style = "display: block;"
    
}


// =========================================================================
// FUNCIÓN PRINCIPAL: Verifica el estado del perfil campo por campo
// =========================================================================
function datosPersonales() {
    const idUsuario = window.USER_ID || (window.usuarioAdmin ? window.usuarioAdmin.id_usuario : null);

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
                    showCancelButton: false,               // Desactivado: El coordinador no puede omitir el proceso
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
                    // Este evento se dispara estrictamente cuando el usuario presiona el botón verde de confirmación
                    if (result.isConfirmed) {
                        window.location.href = `/completar-perfil?id_usuario=${idUsuario}`;
                    }
                });

            }
        })
}

// Inicialización automática del análisis tan pronto se renderiza el módulo en el cliente
datosPersonales();