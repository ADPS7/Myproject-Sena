let datosCursos = [];

// ======================================
// CARGAR CURSOS
// ======================================
document.addEventListener('DOMContentLoaded', () => {
    cargarCursosProfesor();
});

async function cargarCursosProfesor() {

    try {

        // ID DEL PROFESOR
        const idProfesor = window.USER_ID;


        const response = await fetch(`/cursos/profesor/${idProfesor}`);
        datosCursos = await response.json();

        renderizarCursos();

    } catch (error) {

        console.error(error);

        document.getElementById('contenedor-principal').innerHTML = `
            <div class="col-12">
                <div class="alert alert-danger shadow-sm">
                    Error al cargar cursos
                </div>
            </div>
        `;
    }
}

// ======================================
// VISTA CURSOS
// ======================================
function renderizarCursos() {

    const contenedor = document.getElementById('contenedor-principal');

    contenedor.innerHTML = `
    
        <div class="col-12 mb-5 text-center">

            <h1 class="fw-bold display-6">
                Mis Cursos
            </h1>

            <p class="text-muted">
                Selecciona un curso para administrar sus módulos
            </p>

        </div>

        ${datosCursos.map(curso => `

            <div class="col-md-4 mb-4">

                <div class="card border-0 shadow-lg curso-card overflow-hidden h-100"
                     onclick="verModulos(${curso.id_curso}, '${curso.nombre}')">

                    <!-- HEADER -->
                    <div class="bg-primary p-4 text-white">

                        <div class="d-flex justify-content-between align-items-center">

                            <div>

                                <small class="text-white-50">
                                    CURSO
                                </small>

                                <h4 class="fw-bold mb-0 mt-2">
                                    ${curso.nombre}
                                </h4>

                            </div>

                            <div class="bg-white bg-opacity-25 rounded-circle p-3">

                                <i class="bi bi-book-half fs-3"></i>

                            </div>

                        </div>

                    </div>

                    <!-- BODY -->
                    <div class="card-body p-4">

                        <div class="d-flex justify-content-between align-items-center">

                            <div>

                                <small class="text-muted d-block">
                                    Gestión académica
                                </small>

                                <span class="fw-semibold">
                                    Ver módulos
                                </span>

                            </div>

                            <i class="bi bi-arrow-right-circle-fill text-primary fs-3"></i>

                        </div>

                    </div>

                </div>

            </div>

        `).join('')}
    `;
}

// ======================================
// VER MODULOS
// ======================================
async function verModulos(idCurso, nombreCurso) {

    try {

        const response = await fetch(`/modulos/curso/${idCurso}`);
        const modulos = await response.json();

        renderizarModulos(idCurso, nombreCurso, modulos);

    } catch (error) {

        console.error(error);

    }
}

// ======================================
// RENDER MODULOS
// ======================================
function renderizarModulos(idCurso, nombreCurso, modulos) {

    const contenedor = document.getElementById('contenedor-principal');

    contenedor.innerHTML = `

        <div class="col-12 mb-5">

            <button class="btn btn-outline-secondary rounded-pill px-4 mb-4"
                    onclick="renderizarCursos()">

                <i class="bi bi-arrow-left"></i>
                Volver

            </button>

            <h2 class="fw-bold">
                ${nombreCurso}
            </h2>

            <p class="text-muted">
                Módulos disponibles
            </p>

        </div>

        ${modulos.map(modulo => {

            const fechaInicio = modulo.fecha_inicio.split('T')[0];
            const fechaFin = modulo.fecha_fin.split('T')[0];

            return `

                <div class="col-md-6 mb-4">

                    <div class="card border-0 shadow modulo-card h-100"
                         onclick="verEstudiantes(${idCurso}, ${modulo.id_modulo}, '${modulo.nombre}')">

                        <div class="card-body p-4">

                            <div class="d-flex justify-content-between align-items-start mb-4">

                                <div>

                                    <small class="text-primary fw-semibold">
                                        MÓDULO
                                    </small>

                                    <h4 class="fw-bold mt-2">
                                        ${modulo.nombre}
                                    </h4>

                                </div>

                                <div class="bg-light rounded-circle p-3">

                                    <i class="bi bi-journal-bookmark-fill text-primary fs-4"></i>

                                </div>

                            </div>

                            <div class="bg-light rounded-4 p-3">

                                <div class="d-flex justify-content-between mb-2">

                                    <small class="text-muted">
                                        Inicio
                                    </small>

                                    <span class="fw-semibold">
                                        ${fechaInicio}
                                    </span>

                                </div>

                                <div class="d-flex justify-content-between">

                                    <small class="text-muted">
                                        Finaliza
                                    </small>

                                    <span class="fw-semibold">
                                        ${fechaFin}
                                    </span>

                                </div>

                            </div>

                            <div class="mt-4 d-flex justify-content-end">

                                <span class="text-primary fw-semibold">
                                    Ver estudiantes →
                                </span>

                            </div>

                        </div>

                    </div>

                </div>

            `;

        }).join('')}
    `;
}

// ======================================
// VER ESTUDIANTES
// ======================================
async function verEstudiantes(idCurso, idModulo, nombreModulo) {

    try {

        const response = await fetch(`/modulo/${idModulo}/students`);
        const estudiantes = await response.json();

        renderizarEstudiantes(idCurso, idModulo, nombreModulo, estudiantes);

    } catch (error) {

        console.error(error);

    }
}

// ======================================
// RENDER ESTUDIANTES
// ======================================
function renderizarEstudiantes(idCurso, idModulo, nombreModulo, estudiantes) {

    const contenedor = document.getElementById('contenedor-principal');

    contenedor.innerHTML = `

        <div class="col-12 mb-4">

            <button class="btn btn-outline-secondary rounded-pill px-4 mb-4"
                    onclick="verModulos(${idCurso}, 'Curso')">

                <i class="bi bi-arrow-left"></i>
                Volver

            </button>

            <h2 class="fw-bold">
                ${nombreModulo}
            </h2>

            <p class="text-muted">
                Estudiantes del módulo
            </p>

        </div>

        <div class="col-12">

            <div class="card border-0 shadow-sm overflow-hidden rounded-4">

                <div class="table-responsive">

                    <table class="table align-middle mb-0">

                        <thead class="table-light">

                            <tr>
                                <th class="ps-4">Nombre</th>
                                <th>Correo</th>
                            </tr>

                        </thead>

                        <tbody>

                            ${estudiantes.length > 0

                                ?

                                estudiantes.map(est => `

                                    <tr>

                                        <td class="ps-4 fw-semibold">
                                            ${est.nombres} ${est.apellidos}
                                        </td>

                                        <td>
                                            ${est.correo}
                                        </td>

                                    </tr>

                                `).join('')

                                :

                                `

                                    <tr>

                                        <td colspan="2" class="text-center py-4 text-muted">

                                            No hay estudiantes registrados

                                        </td>

                                    </tr>

                                `
                            }

                        </tbody>

                    </table>

                </div>

            </div>

        </div>

    `;
}