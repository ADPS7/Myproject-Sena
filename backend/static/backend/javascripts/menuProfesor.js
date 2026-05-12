// backend/javascripts/menuProfesor.js

function ocultarTodasLasVistasProfesor() {
    const vistas = ["mostrarInicioProfesor", "mostrarCursosProfesor"];
    vistas.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.style.display = "none";
    });
}

function mostrarvistaInicioProfesor() {
    ocultarTodasLasVistasProfesor();
    document.getElementById("mostrarInicioProfesor").style.display = "block";
}

function mostrarvistaCursosProfesor() {
    ocultarTodasLasVistasProfesor();
    const cursosVista = document.getElementById("mostrarCursosProfesor");
    if (cursosVista) {
        cursosVista.style.display = "block";
        
        // Cargar automáticamente los cursos
        if (typeof cargarCursosProfesor === "function") {
            setTimeout(cargarCursosProfesor, 100);
        }
    }
}

// Inicializar al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    mostrarvistaInicioProfesor();
});