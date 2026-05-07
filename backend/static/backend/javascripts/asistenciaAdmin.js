// Variable global para el buscador de cursos
let listaCursos = []; 

/**
 * CARGA INICIAL: Obtiene todos los cursos
 */
function cargarAsistenciasCursos() {
    // Restaurar el encabezado original si venimos de la vista de módulos
    document.getElementById('view-title').innerText = "Asistencias";
    document.getElementById('view-subtitle').innerText = "Panel de visualización de cursos activos.";
    document.getElementById('search-wrapper').style.display = "block";

    fetch('/cursos')
        .then(response => response.json())
        .then(cursos => {
            listaCursos = cursos; 
            renderizarCursos(listaCursos);
        })
        .catch(error => console.error('Error al cargar cursos:', error));
}

/**
 * RENDERIZA LAS CARDS DE CURSOS
 */
function renderizarCursos(cursosAMostrar) {
    const contenedor = document.getElementById('contenedor-asistencias-cursos');
    if (!contenedor) return;
    contenedor.innerHTML = ''; 

    if (cursosAMostrar.length === 0) {
        contenedor.innerHTML = `<div class="col-12 text-center py-5 text-muted">No se encontraron resultados.</div>`;
        return;
    }

    cursosAMostrar.forEach(curso => {
        contenedor.innerHTML += `
            <div class="col-12 col-md-6 col-lg-4 col-xl-3">
                <div class="card-curso-admin p-4 shadow-sm h-100 d-flex align-items-center" 
                     onclick="verDetalleAsistenciaAdmin(${curso.id_curso}, '${curso.nombre}')">
                    <div class="icon-shape me-3">
                        <i class="bi bi-journal-text fs-4"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-0 text-dark text-capitalize">${curso.nombre.toLowerCase()}</h6>
                        <small class="text-muted" style="font-size: 10px;">CONSULTAR MODULOS</small>
                    </div>
                </div>
            </div>`;
    });
}

/**
 * NAVEGACIÓN: Carga los módulos de un curso específico
 */
window.verDetalleAsistenciaAdmin = function(idCurso, nombreCurso) {
    // 1. Cambiar la interfaz para el modo Módulos
    document.getElementById('view-title').innerText = "Módulos de " + nombreCurso;
    document.getElementById('view-subtitle').innerText = "Selecciona un módulo para gestionar asistencia.";
    document.getElementById('search-wrapper').style.display = "none"; // Ocultamos buscador en módulos

    // 2. Botón de retorno
    const contenedor = document.getElementById('contenedor-asistencias-cursos');
    contenedor.innerHTML = `
        <div class="col-12 mb-2">
            <button class="btn btn-light btn-sm rounded-pill shadow-sm border" onclick="cargarAsistenciasCursos()">
                <i class="bi bi-arrow-left me-1"></i> Volver a Cursos
            </button>
        </div>`;

    // 3. Petición a tu nueva ruta de Flask
    fetch(`/modulos/curso/${idCurso}`)
        .then(response => response.json())
        .then(modulos => {
            if (modulos.length === 0) {
                contenedor.innerHTML += `<div class="col-12 text-center py-5 text-muted">Este curso no tiene módulos registrados.</div>`;
                return;
            }

            modulos.forEach(modulo => {
                const fInicio = new Date(modulo.fecha_inicio).toLocaleDateString();
                const fFin = new Date(modulo.fecha_fin).toLocaleDateString();

                contenedor.innerHTML += `
                    <div class="col-12 col-md-6 col-xl-4">
                        <div class="card-stat bg-white p-4 rounded-4 border-0 shadow-sm border-hover h-100" 
                             style="cursor: pointer;" onclick="verAsistenciaFinal(${modulo.id_modulo})">
                            <div class="d-flex align-items-center mb-3">
                                <div class="icon-shape bg-primary bg-opacity-10 text-primary p-2 rounded-3 me-3">
                                    <i class="bi bi-layers-fill fs-4"></i>
                                </div>
                                <h6 class="fw-bold mb-0">${modulo.nombre}</h6>
                            </div>
                            <div class="row g-0 py-2 border-top border-bottom my-3">
                                <div class="col-6 border-end text-center">
                                    <small class="text-muted d-block small">Desde</small>
                                    <span class="fw-bold" style="font-size: 0.85rem;">${fInicio}</span>
                                </div>
                                <div class="col-6 text-center">
                                    <small class="text-muted d-block small">Hasta</small>
                                    <span class="fw-bold" style="font-size: 0.85rem;">${fFin}</span>
                                </div>
                            </div>
                            <div class="text-center">
                                <span class="text-primary small fw-bold">Revisar Asistencia <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>`;
            });
        });
};

/**
 * BUSCADOR DE CURSOS
 */
window.filtrarCursos = function() {
    const termino = document.getElementById('inputBusqueda').value.toLowerCase().trim();
    const filtrados = listaCursos.filter(c => c.nombre.toLowerCase().includes(termino));
    renderizarCursos(filtrados);
};

// Iniciar al cargar el DOM
document.addEventListener('DOMContentLoaded', cargarAsistenciasCursos);

function verAsistenciaFinal(idModulo) {
    console.log("Accediendo al módulo ID:", idModulo);
}