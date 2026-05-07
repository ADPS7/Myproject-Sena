// 1. Declarar la variable fuera para que sea accesible por todas las funciones
let listaCursos = []; 

function cargarAsistenciasCursos() {
    fetch('/cursos')
        .then(response => {
            if (!response.ok) throw new Error("Error en la red");
            return response.json();
        })
        .then(cursos => {
            // 2. Guardar los datos originales aquí
            listaCursos = cursos; 
            renderizarCursos(listaCursos);
        })
        .catch(error => {
            console.error('Error al obtener cursos:', error);
            document.getElementById('contenedor-asistencias-cursos').innerHTML = 
                '<p class="text-center text-danger">Error al conectar con el servidor</p>';
        });
}

function renderizarCursos(cursosAMostrar) {
    const contenedor = document.getElementById('contenedor-asistencias-cursos');
    if (!contenedor) return;
    
    contenedor.innerHTML = ''; 

    if (cursosAMostrar.length === 0) {
        contenedor.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="bi bi-search text-muted fs-1"></i>
                <p class="text-muted mt-2">No se encontraron cursos con ese nombre</p>
            </div>`;
        return;
    }

    cursosAMostrar.forEach(curso => {
        // Aseguramos que nombre no sea null
        const nombreCurso = curso.nombre ? curso.nombre : "Sin nombre";
        
        contenedor.innerHTML += `
            <div class="col-12 col-md-6 col-lg-4 col-xl-3 curso-item">
                <div class="card-curso-admin p-4 shadow-sm h-100 d-flex align-items-center" 
                     onclick="verDetalleAsistenciaAdmin(${curso.id_curso})">
                    <div class="icon-shape me-3">
                        <i class="bi bi-journal-text fs-4"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-0 text-dark text-capitalize">${nombreCurso.toLowerCase()}</h6>
                        <small class="text-muted" style="font-size: 10px;">CONSULTAR ASISTENCIA</small>
                    </div>
                </div>
            </div>
        `;
    });
}

// 3. La función de filtrado mejorada
function filtrarCursos() {
    const input = document.getElementById('inputBusqueda');
    if (!input) return;

    const termino = input.value.toLowerCase().trim();
    
    // Filtramos sobre la variable global 'listaCursos'
    const filtrados = listaCursos.filter(curso => {
        const nombre = curso.nombre ? curso.nombre.toLowerCase() : "";
        return nombre.includes(termino);
    });

    renderizarCursos(filtrados);
}

// Iniciar carga
document.addEventListener('DOMContentLoaded', cargarAsistenciasCursos);