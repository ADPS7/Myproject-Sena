function mostrarvistaInicioAdmin() {
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: block;"
}

function mostrarvistaUsuarioAdmin() {
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: block;"
}

function mostrarvistaModulosAdmin() {
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:block;"
}

function mostrarvistaCursosAdmin() {
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: none;"
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: block;"
}
function mostrarvistaAsistenciaAdmin() {
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: block;"
}


function datosPersonales() {
    const idUsuario = window.USER_ID; 

    fetch(`/verificar_datos_vacios?id_usuario=${idUsuario}`)
        .then(response => response.json())
        .then(data => {
            // Si los datos NO están vacíos (data.vacios === false)
            if (data.vacios === false) {
                
                Swal.fire({
                    title: '¡Información Registrada!',
                    html: `
                        <p class="mb-2">Sus datos ya se encuentran en el sistema.</p>
                        <strong class="text-danger d-block mb-1">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i> Es obligatorio mantenerlos actualizados para continuar.
                        </strong>
                    `,
                    icon: 'info',
                    iconColor: '#198754', // El verde éxito de tu imagen
                    showCancelButton: false,
                    confirmButtonText: 'Actualizar Datos Ahora <i class="bi bi-arrow-right ms-2"></i>',
                    confirmButtonColor: '#198754', // Botón principal verde
                    background: '#ffffff',
                    allowOutsideClick: false, // Evita que la cierren haciendo clic afuera
                    allowEscapeKey: false,    // Evita que la cierren con la tecla Escape
                    customClass: {
                        popup: 'rounded-4 shadow border-0',
                        title: 'fw-bold text-success',
                        confirmButton: 'btn btn-success px-4 py-2 rounded-3 fw-bold'
                    }
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = `/completar-perfil?id_usuario=${window.USER_ID}`;
                    }
                });

            }
        })
        .catch(error => console.error("Error al verificar los datos:", error));
}

// Se ejecuta automáticamente al cargar el menú del profesor
datosPersonales();