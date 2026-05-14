// backend/javascripts/menuProfesor.js

function mostrarvistaInicioProfesor() {
    cursos = document.getElementById("mostrarCursosProfesor").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaProfesor").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilProfesor").style = "display: none;"
    inicio = document.getElementById("mostrarInicioProfesor").style = "display: block;"
}

function mostrarvistaCursosProfesor() {
    inicio = document.getElementById("mostrarInicioProfesor").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaProfesor").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilProfesor").style = "display: none;"
    cursos = document.getElementById("mostrarCursosProfesor").style = "display: block;"
}

function mostrarvistaAsistenciaProfesor() {
    inicio = document.getElementById("mostrarInicioProfesor").style = "display: none;"
    cursos = document.getElementById("mostrarCursosProfesor").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilProfesor").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaProfesor").style = "display: block;"
}

function mostrarvistaPerfilProfesor() {
    inicio = document.getElementById("mostrarInicioProfesor").style = "display: none;"
    cursos = document.getElementById("mostrarCursosProfesor").style = "display: none;"
    asistencia = document.getElementById("mostrarAsistenciaProfesor").style = "display: none;"
    perfil = document.getElementById("mostrarPerfilProfesor").style = "display: block;"
}
