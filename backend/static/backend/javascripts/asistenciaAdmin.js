// Variable global para almacenar los datos una sola vez
let datosAsistencia = [];

document.addEventListener('DOMContentLoaded', () => {
    fetchAsistencias();
});

/**
 * Obtiene los datos del endpoint /admin/asistencias
 */
async function fetchAsistencias() {
    try {
        const response = await fetch('/admin/asistencias');
        const res = await response.json();
        
        if (res.success) {
            datosAsistencia = res.cursos;
            renderizarCursos();
        } else {
            throw new Error(res.error || "Error desconocido");
        }
    } catch (error) {
        console.error("Error al cargar datos:", error);
        document.getElementById('contenedor-principal').innerHTML = `
            <div class="col-12 alert alert-danger">
                Error al conectar con la base de datos: ${error.message}
            </div>`;
    }
}

/**
 * VISTA 1: Muestra los Cursos
 */
function renderizarCursos() {
    const contenedor = document.getElementById('contenedor-principal');
    const navContainer = document.getElementById('back-button-container');
    
    document.getElementById('view-title').innerText = "Cursos Activos";
    document.getElementById('view-subtitle').innerText = "Selecciona un curso para ver sus módulos.";
    navContainer.innerHTML = ''; // Sin botón de volver en la raíz

    contenedor.innerHTML = datosAsistencia.map(curso => `
        <div class="col-12 col-md-6 col-lg-4">
            <div class="card card-asistencia shadow-sm p-4 h-100 cursor-pointer" onclick="renderizarModulos(${curso.id_curso})">
                <div class="d-flex align-items-center">
                    <div class="bg-primary bg-opacity-10 text-primary p-3 rounded-circle me-3">
                        <i class="bi bi-book-half fs-3"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-0">${curso.nombre}</h5>
                        <small class="text-muted">${curso.modulos.length} Módulos registrados</small>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

/**
 * VISTA 2: Muestra los Módulos del curso
 */
function renderizarModulos(idCurso) {
    const curso = datosAsistencia.find(c => c.id_curso === idCurso);
    const contenedor = document.getElementById('contenedor-principal');
    const navContainer = document.getElementById('back-button-container');

    document.getElementById('view-title').innerText = curso.nombre;
    document.getElementById('view-subtitle').innerText = "Módulos de este curso.";
    
    navContainer.innerHTML = `
        <button class="btn btn-outline-secondary rounded-pill btn-sm" onclick="renderizarCursos()">
            <i class="bi bi-arrow-left"></i> Volver a Cursos
        </button>`;

    contenedor.innerHTML = curso.modulos.map(mod => `
        <div class="col-12 col-md-6">
            <div class="card card-asistencia shadow-sm p-3 border-start border-primary border-4" 
                 onclick="renderizarReporteFinal(${idCurso}, ${mod.id_modulo})" style="cursor:pointer">
                <div class="d-flex justify-content-between align-items-center">
                    <h6 class="fw-bold mb-0">${mod.nombre}</h6>
                    <span class="badge bg-light text-dark border">${mod.estudiantes.length} Alumnos</span>
                </div>
            </div>
        </div>
    `).join('');
}

/**
 * VISTA 3: Reporte de Asistencia (Tabla)
 */
function renderizarReporteFinal(idCurso, idModulo) {
    const curso = datosAsistencia.find(c => c.id_curso === idCurso);
    const modulo = curso.modulos.find(m => m.id_modulo === idModulo);
    const contenedor = document.getElementById('contenedor-principal');
    const navContainer = document.getElementById('back-button-container');

    document.getElementById('view-title').innerText = "Reporte: " + modulo.nombre;
    document.getElementById('view-subtitle').innerText = "Seguimiento detallado de inasistencias.";

    navContainer.innerHTML = `
        <button class="btn btn-outline-secondary rounded-pill btn-sm" onclick="renderizarModulos(${idCurso})">
            <i class="bi bi-arrow-left"></i> Volver a Módulos
        </button>`;

    contenedor.innerHTML = `
        <div class="col-12">
            <div class="card border-0 shadow-sm overflow-hidden" style="border-radius: 15px;">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="bg-light">
                            <tr>
                                <th class="ps-4">Estudiante</th>
                                <th class="text-center">Total Faltas</th>
                                <th class="text-center">Estado</th>
                                <th class="ps-4">Últimos Registros</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${modulo.estudiantes.map(est => `
                                <tr class="${est.alerta ? 'table-danger' : ''}">
                                    <td class="ps-4">
                                        <div class="fw-bold">${est.nombre}</div>
                                    </td>
                                    <td class="text-center">
                                        <span class="fw-bold ${est.inasistencias > 0 ? 'text-danger' : 'text-muted'}">
                                            ${est.inasistencias}
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        ${est.alerta ? 
                                            '<span class="badge bg-danger">Alerta de Deserción</span>' : 
                                            '<span class="badge bg-success">Al día</span>'}
                                    </td>
                                    <td class="ps-4">
                                        <div class="d-flex gap-1">
                                            ${est.asistencias.length > 0 ? 
                                                est.asistencias.slice(-5).map(a => `
                                                    <span class="badge-date ${a.asistio === 'SI' ? 'bg-success text-white' : 'bg-danger text-white'}" 
                                                          title="${a.fecha}">
                                                        ${a.fecha.split('-')[2]}/${a.fecha.split('-')[1]}
                                                    </span>
                                                `).join('') : 
                                                '<small class="text-muted">Sin registros</small>'
                                            }
                                        </div>
                                    </td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>`;
}