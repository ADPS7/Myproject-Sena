function mostrarvistaInicioAdmin() {
    ocultarTodasLasVistas();
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: block;"
}

function mostrarvistaUsuarioAdmin() {
    ocultarTodasLasVistas();
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: block;"
}

function mostrarvistaModulosAdmin() {
    ocultarTodasLasVistas();
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:block;"
}

// ====================== FUNCIÓN AGREGADA PARA CURSOS ======================
function mostrarvistaCursosAdmin() {
    // Ocultar las otras vistas
    if (document.getElementById("mostrarInicioAdmin")) 
        document.getElementById("mostrarInicioAdmin").style.display = "none";
    
    if (document.getElementById("mostrarUsuarioAdmin")) 
        document.getElementById("mostrarUsuarioAdmin").style.display = "none";
    
    if (document.getElementById("mostrarModulosAdmin")) 
        document.getElementById("mostrarModulosAdmin").style.display = "none";
    
    // Mostrar Cursos
    if (document.getElementById("mostrarCursosAdmin")) {
        document.getElementById("mostrarCursosAdmin").style.display = "block";
        
        // Cargar los cursos automáticamente
        if (typeof inicializarCursosAdmin === "function") {
            setTimeout(inicializarCursosAdmin, 150);
        }
    }
}

function ocultarTodasLasVistas() {
    const vistas = [
        "mostrarInicioAdmin",
        "mostrarUsuarioAdmin",
        "mostrarModulosAdmin",
        "mostrarCursosAdmin"
    ];

    vistas.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.style.display = "none";
    });
}
