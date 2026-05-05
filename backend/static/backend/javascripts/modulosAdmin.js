function llenarSelectCursos() {
    const select = document.getElementById('id_curso_modulo');

    fetch('/cursos') // Tu ruta de Python que devuelve [id_curso, nombre]
        .then(res => res.json())
        .then(cursos => {
            // Limpiamos y preparamos el select
            select.innerHTML = '<option value="" selected disabled>Seleccione un curso...</option>';

            cursos.forEach(curso => {
                const option = document.createElement('option');
                option.value = curso.id_curso;  // Esto es lo que se guarda en SQL
                option.textContent = curso.nombre; // Esto es lo que ve el usuario
                select.appendChild(option);
            });
        })
        .catch(err => {
            console.error('Error al cargar cursos:', err);
            select.innerHTML = '<option value="" disabled>Error al cargar cursos</option>';
        });
}

// Ejecutar la función al cargar el documento
document.addEventListener('DOMContentLoaded', llenarSelectCursos);

document.getElementById('formAgregarModulo').addEventListener('submit', function(e) {
    e.preventDefault();

    const datosModulo = {
        nombre: document.getElementById('nombre_modulo').value,
        fecha_inicio: document.getElementById('fecha_inicio').value,
        fecha_fin: document.getElementById('fecha_fin').value,
        id_curso: document.getElementById('id_curso_modulo').value
    };

    fetch('/modulos/crear', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(datosModulo)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Alerta de Éxito
            Swal.fire({
                title: '¡Correcto!',
                text: 'El módulo ha sido creado exitosamente',
                icon: 'success',
                confirmButtonColor: '#0d6efd' // Color azul de Bootstrap
            });
            
            // Cerrar modal y limpiar
            const modal = bootstrap.Modal.getInstance(document.getElementById('modalAgregarModulo'));
            modal.hide();
            document.getElementById('formAgregarModulo').reset();
            
        } else {
            // Alerta de Error del servidor
            Swal.fire({
                title: 'Error',
                text: 'No se pudo registrar el módulo',
                icon: 'error',
                confirmButtonColor: '#dc3545'
            });
        }
    })
    .catch(error => {
        console.error('Error:', error);
        // Alerta de Error de conexión
        Swal.fire({
            title: 'Error de Red',
            text: 'Hubo un problema al conectar con el servidor',
            icon: 'warning',
            confirmButtonColor: '#ffc107'
        });
    });
});

function cargarModulos() {
    const tablaBody = document.getElementById('tabla-modulos-body');
    if(!tablaBody) return;

    fetch('/modulos')
        .then(response => response.json())
        .then(modulos => {
            tablaBody.innerHTML = ''; 

            if (!modulos || modulos.length === 0) {
                tablaBody.innerHTML = '<tr><td colspan="5" class="text-center p-4">No hay módulos registrados</td></tr>';
                return;
            }

            modulos.forEach(modulo => {
                const partes = modulo.fecha_inicio.split('-');
                alert(partes)
                alert(partes[2])
                

                // Insertamos los datos tal cual vienen de la base de datos
                const fila = `
                    <tr>
                        <td class="ps-4 fw-bold">${modulo.nombre}</td>
                        <td>${modulo.nombre_curso}</td>
                        <td>${modulo.fecha_inicio}</td>
                        
                        <td>${modulo.fecha_fin}</td>
                        <td class="text-end pe-4">
                            <button class="btn btn-sm btn-light border text-primary">
                                <i class="bi bi-pencil"></i>
                            </button>
                            <button class="btn btn-sm btn-light border text-danger ms-1">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>
                `;
                tablaBody.innerHTML += fila;
            });
        })
        .catch(error => {
            console.error('Error al cargar módulos:', error);
            tablaBody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Error al conectar con el servidor</td></tr>';
        });
}

// Ejecutar al cargar la página
document.addEventListener('DOMContentLoaded', cargarModulos);