// backend/javascripts/menuProfesor.js

function mostrarvistaInicioProfesor() {
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarInicioProfesor").style.display = "block";
}

function mostrarvistaCursosProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "block";
}

function mostrarvistaAsistenciaProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "block";
}

function mostrarvistaPerfilProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "block";
}

function mostrarvistaNotasProfesor() {
    document.getElementById("mostrarInicioProfesor").style.display = "none";
    document.getElementById("mostrarCursosProfesor").style.display = "none";
    document.getElementById("mostrarAsistenciaProfesor").style.display = "none";
    document.getElementById("mostrarPerfilProfesor").style.display = "none";
    document.getElementById("mostrarNotasProfesor").style.display = "block";
}


