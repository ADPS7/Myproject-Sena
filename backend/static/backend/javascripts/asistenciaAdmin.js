function cargarCursos() {
    fetch('/cursos')
        .then(response => response.json())
        .then(cursos => {
            const contenedor = document.getElementById('contenedor-cursos');
            contenedor.innerHTML = ''; // Limpiar contenedor

            cursos.forEach(curso => {
                contenedor.innerHTML += `
                    <div class="col-12 col-md-6 col-xl-4">
                        <div class="card-stat bg-white p-4 rounded-4 border-0 shadow-sm border-hover h-100">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <i class="bi bi-journal-bookmark-fill text-primary fs-3"></i>
                                    <div class="mt-3">
                                        <h5 class="fw-bold mb-1">${curso.nombre}</h5>
                                        <small class="text-muted">ID: #${curso.id_curso}</small>
                                    </div>
                                </div>
                                <div class="dropdown">
                                    <button class="btn btn-light btn-sm rounded-circle" data-bs-toggle="dropdown">
                                        <i class="bi bi-three-dots-vertical"></i>
                                    </button>
                                    <ul class="dropdown-menu border-0 shadow-sm">
                                        <li><a class="dropdown-item" href="#" onclick="editarCurso(${curso.id_curso})">Editar</a></li>
                                        <li><a class="dropdown-item text-danger" href="#" onclick="confirmarBorrarCurso(${curso.id_curso})">Eliminar</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="mt-4 pt-3 border-top">
                                <button class="btn btn-outline-primary btn-sm w-100 rounded-pill" onclick="verModulos(${curso.id_curso})">
                                    Gestionar Módulos
                                </button>
                            </div>
                        </div>
                    </div>
                `;
            });
        })
        .catch(error => console.error('Error al cargar cursos:', error));
}

// Llamar a la función al cargar la vista
document.addEventListener('DOMContentLoaded', cargarCursos);