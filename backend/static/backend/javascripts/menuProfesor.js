// backend/javascripts/menuProfesor.js

function mostrarvistaInicioProfesor() {
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarHistorialNotas").style.display = "none";
    document.getElementById("mostrarInicioProfesor").style.display = "block";
}

function mostrarvistaCursosProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarHistorialNotas").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "block";
}

function mostrarvistaAsistenciaProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarHistorialNotas").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "block";
}

function mostrarvistaPerfilProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarHistorialNotas").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "block";
}

function mostrarvistaNotasProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarHistorialNotas").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "block";
}


// =========================================================================
// FUNCIÓN PRINCIPAL: Escanea campos del profesor y bloquea si hay vacíos
// =========================================================================
function datosPersonales() {
    const idUsuario = window.USER_ID; 

    // Consultamos al backend la verificación campo por campo
    fetch(`/verificar_datos_vacios?id_usuario=${idUsuario}`)
        .then(response => response.json())
        .then(data => {
            // Si el backend responde que 'vacios' es true (falta algún dato obligatorio)
            if (data.vacios === true) {
                
                // Ejecución segura esperando que la librería externa esté lista en el DOM
                const desplegarAlerta = () => {
                    Swal.fire({
                        title: '¡Perfil Incompleto!',
                        html: `
                            <p class="mb-2 text-secondary" style="font-size: 0.95rem;">
                                Detectamos que tiene campos pendientes por diligenciar en su perfil docente.
                            </p>
                            <strong class="d-block mb-1" style="color: #664d03; font-size: 0.9rem;">
                                <i class="bi bi-exclamation-triangle-fill me-1"></i> Es estrictamente obligatorio completar todos sus datos para continuar en la plataforma.
                            </strong>
                        `,
                        icon: 'warning',
                        iconColor: '#ffc107',                  // Amarillo de advertencia corporativo
                        showCancelButton: false,               // Deshabilitado: Obligatorio rellenar
                        confirmButtonText: 'Actualizar Datos Ahora <i class="bi bi-arrow-right ms-2"></i>',
                        confirmButtonColor: '#198754',          // Verde éxito unificado
                        background: '#ffffff',
                        allowOutsideClick: false,              // Bloquea clics accidentales fuera del modal
                        allowEscapeKey: false,                 // Bloquea cierre mediante teclado (Esc)
                        customClass: {
                            popup: 'rounded-4 shadow border-0 p-4',
                            title: 'fw-bold text-dark fs-4',
                            confirmButton: 'btn btn-success px-4 py-2 rounded-3 fw-bold fs-6'
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            // En lugar de redirigir de página, disparamos tu función nativa
                            // para que abra el contenedor de edición ahí mismo sin romper el flujo
                            if (typeof mostrarvistaPerfilProfesor === 'function') {
                                window.location.href = `/completar-perfil?id_usuario=${idUsuario}`;
                            }
                        }
                    });
                };

                // Si la librería tardó milisegundos en cargar, esperamos un breve instante
                if (typeof Swal !== 'undefined') {
                    desplegarAlerta();
                } else {
                    setTimeout(desplegarAlerta, 300);
                }
            }
        })
        .catch(error => console.error("Error al ejecutar la verificación del perfil docente:", error));
}

// Ejecución automática inmediata al cargar el entorno del profesor
datosPersonales();