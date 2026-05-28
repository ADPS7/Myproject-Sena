// perfilEstudiante.js

// Cargar datos del perfil del estudiante y poblar el formulario
function cargarPerfilEstudiante() {
    try {
        const idElemento = document.getElementById('id_usuario_est');
        const id = idElemento && idElemento.value ? Number(idElemento.value) : Number(window.USER_ID || 0);

        if (!id) return console.warn('ID de usuario no disponible para cargar perfil.');

        fetch(`/obtener_perfil_completo?id_usuario=${id}`)
            .then(res => res.json())
            .then(usuario => {
                if (usuario.error) return console.error(usuario.error);

                document.getElementById('nombres_est').value = usuario.nombres || '';
                document.getElementById('apellidos_est').value = usuario.apellidos || '';
                document.getElementById('correo_est').value = usuario.correo || '';
                document.getElementById('fecha_nacimiento_est').value = usuario.fecha_nacimiento || '';
                document.getElementById('rol_est').value = usuario.rol || '';

                document.getElementById('sexo_est').value = usuario.Sexo || '';
                document.getElementById('tipo_documento_est').value = usuario.tipo_documento || '';
                document.getElementById('numero_documento_est').value = usuario.numero_documento || '';

                document.getElementById('departamento_est').value = usuario.departamento || '';
                document.getElementById('municipio_est').value = usuario.municipio || '';
                document.getElementById('direccion_est').value = usuario.direccion || '';
                document.getElementById('telefono_est').value = usuario.telefono || '';
                document.getElementById('telefono_emergencia_est').value = usuario.telefono_emergencia || '';
                document.getElementById('estrato_est').value = usuario.Estrato || '';
                document.getElementById('eps_est').value = usuario.eps || '';

                document.getElementById('id_datos_usuario_est').value = usuario.id_datos_usuario || '';

                const nombreVista = document.getElementById('nombreCompletoEstudianteVista');
                if (nombreVista) nombreVista.textContent = `${usuario.nombres || ''} ${usuario.apellidos || ''}`.trim();

                const rolVista = document.getElementById('rolEstudianteVista');
                if (rolVista) rolVista.textContent = usuario.rol || '';

                const estadoVista = document.getElementById('estadoEstudianteVista');
                if (estadoVista) estadoVista.textContent = `Estado: ${usuario.estado || 'Pendiente'}`;

                // Actualizar iniciales de avatar en toda la página
                actualizarAvatarGlobal(usuario.nombres || '');
            })
            .catch(err => console.error('Error cargando perfil estudiante:', err));

    } catch (e) {
        console.error('Excepción en cargarPerfilEstudiante:', e);
    }
}

function actualizarAvatarGlobal(nombres) {
    if (!nombres) return;
    const inicial = nombres.charAt(0).toUpperCase();
    document.querySelectorAll('.avatar').forEach(a => a.textContent = inicial);
}

function mostrarToastEstudiante(titulo, mensaje, esExito = true) {
    const toastEl = document.getElementById('toastNotificacion');
    const tituloEl = document.getElementById('toastTitulo');
    const mensajeEl = document.getElementById('toastMensaje');

    if (!toastEl || !tituloEl || !mensajeEl) return console.warn('Contenedor de toast no encontrado.');

    // Ajustar apariencia
    if (esExito) {
        toastEl.classList.remove('bg-danger');
        toastEl.classList.add('bg-success');
    } else {
        toastEl.classList.remove('bg-success');
        toastEl.classList.add('bg-danger');
    }

    tituloEl.textContent = titulo;
    mensajeEl.textContent = mensaje;

    try {
        const toast = new bootstrap.Toast(toastEl, { delay: 3500 });
        toast.show();
    } catch (e) {
        console.warn('Bootstrap Toast no disponible', e);
    }
}

// Guardar los datos del formulario (usa la ruta /guardar_datos_perfil)
function guardarPerfilEstudiante() {
    const id_usuario = Number(document.getElementById('id_usuario_est').value || window.USER_ID || 0);

    const payload = {
        id_usuario: id_usuario,
        nombres: document.getElementById('nombres_est').value.trim(),
        apellidos: document.getElementById('apellidos_est').value.trim(),
        correo: document.getElementById('correo_est').value.trim(),
        fecha_nacimiento: document.getElementById('fecha_nacimiento_est').value,
        sexo: document.getElementById('sexo_est').value,
        tipo_documento: document.getElementById('tipo_documento_est').value,
        numero_documento: document.getElementById('numero_documento_est').value.trim(),
        departamento: document.getElementById('departamento_est').value.trim(),
        municipio: document.getElementById('municipio_est').value.trim(),
        direccion: document.getElementById('direccion_est').value.trim(),
        telefono: document.getElementById('telefono_est').value.trim(),
        telefono_emergencia: document.getElementById('telefono_emergencia_est').value.trim(),
        estrato: document.getElementById('estrato_est').value,
        eps: document.getElementById('eps_est').value.trim(),
        // Opcional: nueva clave
        nueva_clave: document.getElementById('nueva_clave_est') ? document.getElementById('nueva_clave_est').value.trim() : ''
    };

    // Validación básica de campos obligatorios
    const obligatorios = ['nombres', 'apellidos', 'correo', 'fecha_nacimiento', 'sexo', 'tipo_documento', 'numero_documento', 'departamento', 'municipio', 'direccion', 'telefono', 'telefono_emergencia', 'estrato', 'eps'];
    for (let campo of obligatorios) {
        if (!payload[campo] || String(payload[campo]).trim() === '') {
            mostrarToastEstudiante('Atención', 'Todos los campos son obligatorios.', false);
            return;
        }
    }

    fetch('/guardar_datos_perfil', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(res => res.json())
    .then(resp => {
        if (resp.exito === true) {
            mostrarToastEstudiante('Éxito', resp.mensaje || 'Perfil guardado correctamente.', true);

            // Actualizar vista
            const nombreVista = document.getElementById('nombreCompletoEstudianteVista');
            if (nombreVista) nombreVista.textContent = `${payload.nombres} ${payload.apellidos}`;
            actualizarAvatarGlobal(payload.nombres);
            // limpiar campo de contraseña
            const claveInput = document.getElementById('nueva_clave_est');
            if (claveInput) claveInput.value = '';
        } else {
            // Cuando el servidor devuelve una advertencia (tipo_error)
            if (resp.tipo_error === 'advertencia') {
                mostrarToastEstudiante('Advertencia', resp.mensaje || 'Advertencia en datos del perfil.', false);
            } else {
                mostrarToastEstudiante('Error', resp.mensaje || 'No se pudo guardar el perfil.', false);
            }
        }
    })
    .catch(err => {
        console.error('Error guardando perfil estudiante:', err);
        mostrarToastEstudiante('Error', 'No se pudo conectar con el servidor.', false);
    });
}
