function mostrarvistaInicioCoordinador() {
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    //asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: block;"
}



function mostrarvistaUsuarioCoordinador() {
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"    
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    //asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: block;"
}

function mostrarvistaModulosCoordinador() {
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"
    //asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:block;"
}

function mostrarvistaCursosCoordinador() {
    inicio = document.getElementById("mostrarInicioCoordinador").style = "display: none;"
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioCoordinador").style = "display: none;"
    modulo = document.getElementById("mostrarModulosCoordinador").style = "display:none;"
    //asistencia = document.getElementById("mostrarAsistenciaCoordinador").style = "display: none;"
    cursos = document.getElementById("mostrarCursosCoordinador").style = "display: block;"
}
function mostrarvistaAsistenciaAdmin() {
    //inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    //usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    //modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    //cursos = document.getElementById("mostrarCursosAdmin").style = "display: none;"
    //asistencia = document.getElementById("mostrarAsistenciaAdmin").style = "display: block;"
}


