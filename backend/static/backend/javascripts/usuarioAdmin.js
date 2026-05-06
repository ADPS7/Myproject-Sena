// VARIABLES GLOBALES PARA MEMORIA LOCAL (Para que el buscador sea instantáneo)
let cacheAdmins = [];
let cacheProfesores = [];
let cacheEstudiantes = [];

// 1. FUNCIÓN PARA ADMINISTRADORES
function cargarAdmins() {
    const modal = document.getElementById('modalAdmins');
    const tabla = document.getElementById('tabla-admins-body');
    const buscador = document.getElementById('buscarAdminModal');

    modal.addEventListener('show.bs.modal', function() {
        tabla.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">Cargando...</td></tr>';
        
        fetch('/get_usuarios/admin')
            .then(res => res.json())
            .then(data => {
                cacheAdmins = data;
                renderizarTablaGenerica(tabla, data);
            });
    });

    buscador.addEventListener('input', (e) => {
        const texto = e.target.value.toLowerCase();
        const filtrados = cacheAdmins.filter(u => 
            (u.nombres + " " + u.apellidos).toLowerCase().includes(texto) || 
            u.correo.toLowerCase().includes(texto)
        );
        renderizarTablaGenerica(tabla, filtrados);
    });
}

// 2. FUNCIÓN PARA PROFESORES
function cargarProfesores() {
    const modal = document.getElementById('modalProfesores');
    const tabla = document.getElementById('tabla-profesores-body');
    const buscador = document.getElementById('buscarProfesorModal');

    modal.addEventListener('show.bs.modal', function() {
        tabla.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">Cargando...</td></tr>';
        
        fetch('/get_usuarios/profesor')
            .then(res => res.json())
            .then(data => {
                cacheProfesores = data;
                renderizarTablaGenerica(tabla, data);
            });
    });

    buscador.addEventListener('input', (e) => {
        const texto = e.target.value.toLowerCase();
        const filtrados = cacheProfesores.filter(u => 
            (u.nombres + " " + u.apellidos).toLowerCase().includes(texto) || 
            u.correo.toLowerCase().includes(texto)
        );
        renderizarTablaGenerica(tabla, filtrados);
    });
}

// 3. FUNCIÓN PARA ESTUDIANTES
function cargarEstudiantes() {
    const modal = document.getElementById('modalEstudiantes');
    const tabla = document.getElementById('tabla-estudiantes-body');
    const buscador = document.getElementById('buscarEstudianteModal');

    modal.addEventListener('show.bs.modal', function() {
        tabla.innerHTML = '<tr><td colspan="3" class="text-center py-3 text-muted">Cargando...</td></tr>';
        
        fetch('/get_usuarios/estudiante')
            .then(res => res.json())
            .then(data => {
                cacheEstudiantes = data;
                renderizarTablaGenerica(tabla, data);
            });
    });

    buscador.addEventListener('input', (e) => {
        const texto = e.target.value.toLowerCase();
        const filtrados = cacheEstudiantes.filter(u => 
            (u.nombres + " " + u.apellidos).toLowerCase().includes(texto) || 
            u.correo.toLowerCase().includes(texto)
        );
        renderizarTablaGenerica(tabla, filtrados);
    });
}

// FUNCIÓN AUXILIAR: Esta dibuja las filas (La usamos en las 3 funciones para no repetir HTML)
function renderizarTablaGenerica(tbody, lista) {
    tbody.innerHTML = '';
    if (lista.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" class="text-center py-3">No hay registros</td></tr>';
        return;
    }

    lista.forEach(user => {
        tbody.innerHTML += `
            <tr>
                <td class="ps-4 fw-medium text-dark">${user.nombres} ${user.apellidos}</td>
                <td class="text-secondary small">${user.correo}</td>
                <td class="text-end pe-4">
                    <div class="btn-group shadow-sm rounded-3">
                        <button onclick="abrirModalEdicion('${user.id_usuario}', '${user.nombres}', '${user.apellidos}', '${user.correo}', '${user.fecha_nacimiento}')" 
                                class="btn btn-sm btn-white text-primary border border-light-subtle">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-white text-danger border border-light-subtle">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    });
}

// INICIAR TODO AL CARGAR LA PÁGINA
document.addEventListener('DOMContentLoaded', () => {
    cargarAdmins();
    cargarProfesores();
    cargarEstudiantes();
});