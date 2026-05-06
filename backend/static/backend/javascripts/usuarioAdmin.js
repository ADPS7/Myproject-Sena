document.addEventListener('DOMContentLoaded', function() {
    // Caché para búsqueda instantánea
    const datosCache = {
        admin: [],
        profesor: [],
        estudiante: []
    };

    const modalesConfig = [
        { id: 'modalAdmins', rol: 'admin', tabla: 'tabla-admins-body', input: 'buscarAdminModal' },
        { id: 'modalProfesores', rol: 'profesor', tabla: 'tabla-profesores-body', input: 'buscarProfesorModal' },
        { id: 'modalEstudiantes', rol: 'estudiante', tabla: 'tabla-estudiantes-body', input: 'buscarEstudianteModal' }
    ];

    modalesConfig.forEach(config => {
        const modalElement = document.getElementById(config.id);
        const inputBusqueda = document.getElementById(config.input);
        
        if (modalElement) {
            // AL ABRIR EL MODAL: Cargar datos desde el servidor
            modalElement.addEventListener('show.bs.modal', function() {
                const tablaBody = document.getElementById(config.tabla);
                
                // Reiniciar buscador y mostrar estado de carga
                if (inputBusqueda) inputBusqueda.value = '';
                tablaBody.innerHTML = '<tr><td colspan="3" class="text-center p-3 text-muted">Cargando datos...</td></tr>';

                fetch(`/get_usuarios/${config.rol}`)
                    .then(response => response.json())
                    .then(data => {
                        datosCache[config.rol] = data; // Guardar en memoria
                        renderizarTabla(config.tabla, data);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        tablaBody.innerHTML = '<tr><td colspan="3" class="text-center text-danger p-3">Error al conectar con el servidor</td></tr>';
                    });
            });

            // AL ESCRIBIR EN EL BUSCADOR: Filtrar localmente
            if (inputBusqueda) {
                inputBusqueda.addEventListener('input', function(e) {
                    const termino = e.target.value.toLowerCase();
                    const listaOriginal = datosCache[config.rol];
                    
                    const filtrados = listaOriginal.filter(user => {
                        const nombre = (user.nombre_completo || "").toLowerCase();
                        const correo = (user.correo || "").toLowerCase();
                        return nombre.includes(termino) || correo.includes(termino);
                    });

                    renderizarTabla(config.tabla, filtrados);
                });
            }
        }
    });

    // Función para dibujar las filas de la tabla
    function renderizarTabla(idTabla, lista) {
        const tbody = document.getElementById(idTabla);
        tbody.innerHTML = '';

        if (lista.length === 0) {
            tbody.innerHTML = '<tr><td colspan="3" class="text-center p-3 text-muted">No se encontraron resultados</td></tr>';
            return;
        }

        lista.forEach(user => {
            const fila = `
                <tr>
                    <td class="ps-4 fw-medium text-dark">${user.nombre_completo}</td>
                    <td class="text-secondary">${user.correo}</td>
                    <td class="text-end pe-4">
                        <div class="btn-group shadow-sm rounded-3">
                            <button class="btn btn-sm btn-white text-primary border" title="Editar"><i class="bi bi-pencil"></i></button>
                            <button class="btn btn-sm btn-white text-danger border" title="Eliminar"><i class="bi bi-trash"></i></button>
                        </div>
                    </td>
                </tr>
            `;
            tbody.innerHTML += fila;
        });
    }
});