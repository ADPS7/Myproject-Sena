// backend/javascripts/menuProfesor.js

function ocultarTodasLasVistasProfesor() {
    const vistas = ["mostrarInicioProfesor", "mostrarCursosProfesor", "mostrarAsistenciaProfesor"];
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

function mostrarvistaAsistenciaProfesor() {
    console.log('Mostrando vista asistencia profesor');
    ocultarTodasLasVistasProfesor();
    const asistenciaVista = document.getElementById("mostrarAsistenciaProfesor");
    if (asistenciaVista) {
        asistenciaVista.style.display = "block";
        console.log('Vista visible, verificando si cargarCursosAsistencia existe:', typeof cargarCursosAsistencia);
        if (typeof cargarCursosAsistencia === "function") {
            console.log('Ejecutando cargarCursosAsistencia()');
            cargarCursosAsistencia();
        } else {
            console.error('cargarCursosAsistencia no es una función');
        }
    } else {
        console.error('Elemento mostrarAsistenciaProfesor no existe');
    }
}

// Inicializar al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    mostrarvistaInicioProfesor();
});