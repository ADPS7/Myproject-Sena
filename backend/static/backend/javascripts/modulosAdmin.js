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
// Variable global para guardar los datos y no tener que llamar a la DB cada vez que escribes
let todosLosModulos = [];

function cargarModulos() {
    const tablaBody = document.getElementById('tabla-modulos-body');
    if(!tablaBody) return;

    fetch('/modulos')
        .then(response => response.json())
        .then(modulos => {
            todosLosModulos = modulos; // Guardamos la copia original
            renderizarTabla(modulos);  // Llamamos a una función que dibuja la tabla
        });
}

// Función que dibuja las filas (la separamos para poder reutilizarla al filtrar)
function renderizarTabla(lista) {
    const tablaBody = document.getElementById('tabla-modulos-body');
    tablaBody.innerHTML = '';

    if (lista.length === 0) {
        tablaBody.innerHTML = '<tr><td colspan="5" class="text-center p-4">No se encontraron resultados</td></tr>';
        return;
    }

    lista.forEach(modulo => {
        // Tu lógica de formateo de fecha que ya definimos
        const formatear = (f) => {
            try {
                let d = new Date(f);
                return `${String(d.getUTCDate()).padStart(2, '0')}/${String(d.getUTCMonth() + 1).padStart(2, '0')}/${d.getUTCFullYear()}`;
            } catch(e) { return f; }
        };

        const fila = `
            <tr>
                <td class="ps-4 fw-bold">${modulo.nombre}</td>
                <td class="text-secondary">${modulo.nombre_curso}</td>
                <td>${formatear(modulo.fecha_inicio)}</td>
                <td>${formatear(modulo.fecha_fin)}</td>
                <td class="text-end pe-4">
                    <button class="btn btn-sm btn-light border text-primary"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-light border text-danger ms-1"><i class="bi bi-trash"></i></button>
                </td>
            </tr>`;
        tablaBody.innerHTML += fila;
    });
}

// LÓGICA DEL BUSCADOR
document.getElementById('inputBusqueda').addEventListener('input', function(e) {
    const termino = e.target.value.toLowerCase(); // Lo que el usuario escribe en minúsculas

    const filtrados = todosLosModulos.filter(modulo => {
        const nombreM = modulo.nombre.toLowerCase();
        const nombreC = modulo.nombre_curso.toLowerCase();
        
        // Retorna verdadero si el término está en el nombre del módulo O en el del curso
        return nombreM.includes(termino) || nombreC.includes(termino);
    });

    renderizarTabla(filtrados); // Redibujamos la tabla con los resultados filtrados
});

// Inicializar
document.addEventListener('DOMContentLoaded', cargarModulos);

//editar