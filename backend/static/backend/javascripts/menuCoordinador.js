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




