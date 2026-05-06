function mostrarvistaInicioAdmin() {
    ocultarTodasLasVistas();
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: block;"
}

function mostrarvistaUsuarioAdmin() {
    ocultarTodasLasVistas();
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: block;"
}

function mostrarvistaModulosAdmin() {
    ocultarTodasLasVistas();
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:block;"
}

// ====================== FUNCIÓN AGREGADA PARA CURSOS ======================
function mostrarvistaCursosAdmin() {
    // Ocultar las otras vistas
    if (document.getElementById("mostrarInicioAdmin")) 
        document.getElementById("mostrarInicioAdmin").style.display = "none";
    
    if (document.getElementById("mostrarUsuarioAdmin")) 
        document.getElementById("mostrarUsuarioAdmin").style.display = "none";
    
    if (document.getElementById("mostrarModulosAdmin")) 
        document.getElementById("mostrarModulosAdmin").style.display = "none";
    
    // Mostrar Cursos
    if (document.getElementById("mostrarCursosAdmin")) {
        document.getElementById("mostrarCursosAdmin").style.display = "block";
        
        // Cargar los cursos automáticamente
        if (typeof inicializarCursosAdmin === "function") {
            setTimeout(inicializarCursosAdmin, 150);
        }
    }
}

// Carga de datos en Modales (tu código original sin tocar)
document.addEventListener('DOMContentLoaded', function() {
    const modales = [
        { id: 'modalAdmins', rol: 'admin', tabla: 'tabla-admins-body' },
        { id: 'modalProfesores', rol: 'profesor', tabla: 'tabla-profesores-body' },
        { id: 'modalEstudiantes', rol: 'estudiante', tabla: 'tabla-estudiantes-body' }
    ];

    modales.forEach(config => {
        const modalElement = document.getElementById(config.id);
        
        if (modalElement) {
            modalElement.addEventListener('show.bs.modal', function() {
                const tablaBody = document.getElementById(config.tabla);
                tablaBody.innerHTML = '<tr><td colspan="3" class="text-center text-muted">Cargando...</td></tr>';

                fetch(`/get_usuarios/${config.rol}`)
                    .then(response => response.json())
                    .then(data => {
                        tablaBody.innerHTML = '';

                        if (data.length === 0) {
                            tablaBody.innerHTML = '<tr><td colspan="3" class="text-center">No hay registros</td></tr>';
                            return;
                        }

                        data.forEach(user => {
                            const fila = `
                                <tr>
                                    <td class="ps-4 fw-medium">${user.nombre_completo}</td>
                                    <td>${user.correo}</td>
                                    <td class="text-end pe-4">
                                        <button class="btn btn-sm btn-light text-primary"><i class="bi bi-pencil"></i></button>
                                        <button class="btn btn-sm btn-light text-danger"><i class="bi bi-trash"></i></button>
                                    </td>
                                </tr>
                            `;
                            tablaBody.innerHTML += fila;
                        });
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        tablaBody.innerHTML = '<tr><td colspan="3" class="text-center text-danger">Error al cargar datos</td></tr>';
                    });
            });
        }
    });
});

function ocultarTodasLasVistas() {
    const vistas = [
        "mostrarInicioAdmin",
        "mostrarUsuarioAdmin",
        "mostrarModulosAdmin",
        "mostrarCursosAdmin"
    ];

    vistas.forEach(id => {
        const el = document.getElementById(id);
        if (el) el.style.display = "none";
    });
}
