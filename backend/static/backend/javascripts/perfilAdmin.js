document.addEventListener('DOMContentLoaded', () => {
    cargarDatosPerfil();
});

function cargarDatosPerfil() {
    // Llamamos a la API de Flask que acabamos de crear
    fetch('/api/admin/perfil-datos')
        .then(response => response.json())
        .then(res => {
            if (res.status === 'success') {
                const user = res.data;

                // 1. Rellenar Panel Lateral Izquierdo (Vista rápida)
                const inicial = user.nombres ? user.nombres[0].toUpperCase() : 'A';
                document.querySelector('.avatar').textContent = inicial;
                document.getElementById('nombreCompletoAdminVista').textContent = `${user.nombres} ${user.apellidos}`;
                document.getElementById('rolAdminVista').textContent = user.nombre_rol.toUpperCase();
                
                // Controlar el Badge del Estado
                const badgeEstado = document.getElementById('estadoAdminVista');
                const estadoActual = user.estado || 'Pendiente';
                badgeEstado.textContent = `Estado: ${estadoActual}`;
                
                // Cambiar colores del badge según estado
                badgeEstado.className = "badge rounded-pill px-3 py-2 fs-6"; // Reset clases
                if (estadoActual === 'Activo') badgeEstado.classList.add('bg-success');
                else if (estadoActual === 'Inactivo') badgeEstado.classList.add('bg-danger');
                else badgeEstado.classList.add('bg-secondary');

                // 2. Rellenar Campos Ocultos e Inputs de Cuenta
                document.getElementById('id_usuario_admin').value = user.id_usuario || '';
                document.getElementById('id_datos_usuario_admin').value = user.id_datos_usuario || '';
                document.getElementById('nombres_admin').value = user.nombres || '';
                document.getElementById('apellidos_admin').value = user.apellidos || '';
                document.getElementById('correo_admin').value = user.correo || '';
                document.getElementById('fecha_nacimiento_admin').value = user.fecha_nacimiento || '';
                document.getElementById('rol_admin').value = user.nombre_rol.toUpperCase();
                
                // Select Sexo
                document.getElementById('sexo_admin').value = user.Sexo || '';

                // 3. Documento de Identidad
                document.getElementById('tipo_documento_admin').value = user.tipo_documento || '';
                document.getElementById('numero_documento_admin').value = user.numero_documento || '';

                // 4. Ubicación y Contacto
                document.getElementById('departamento_admin').value = user.departamento || '';
                document.getElementById('municipio_admin').value = user.municipio || '';
                document.getElementById('direccion_admin').value = user.direccion || '';
                document.getElementById('telefono_admin').value = user.telefono || '';
                document.getElementById('telefono_emergencia_admin').value = user.telefono_emergencia || '';

                // 5. Otros Datos
                document.getElementById('estrato_admin').value = user.Estrato || '';
                document.getElementById('eps_admin').value = user.eps || '';

            } else {
                console.error("Error al obtener datos:", res.message);
                alert("No se pudieron cargar los datos del perfil.");
            }
        })
        .catch(error => {
            console.error("Error en la petición Fetch:", error);
        });
}