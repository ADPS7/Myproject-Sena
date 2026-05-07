function mostrarvistaInicioAdmin() {
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: block;"
}

function mostrarvistaUsuarioAdmin() {
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: block;"
}

function mostrarvistaModulosAdmin() {
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:block;"
}

function mostrarvistaCursosAdmin() {
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    cursos = document.getElementById("mostrarCursosAdmin").style = "display: block;"
}


