/**
 * 1. FUNCIÓN PARA CARGAR LOS DATOS DESDE EL BACKEND
 */
function cargarDatosPerfil() {
    fetch('/api/admin/perfil-datos')
        .then(response => response.json())
        .then(res => {
            if (res.status === 'success') {
                const user = res.data;

                // --- PANEL LATERAL IZQUIERDO ---
                const inicial = user.nombres ? user.nombres[0].toUpperCase() : 'A';
                document.querySelector('.avatar').textContent = inicial;
                document.getElementById('nombreCompletoAdminVista').textContent = `${user.nombres} ${user.apellidos}`;
                document.getElementById('rolAdminVista').textContent = user.nombre_rol ? user.nombre_rol.toUpperCase() : 'ADMINISTRADOR';
                
                const badgeEstado = document.getElementById('estadoAdminVista');
                const estadoActual = user.estado || 'Pendiente';
                badgeEstado.textContent = `Estado: ${estadoActual}`;
                
                badgeEstado.className = "badge rounded-pill px-3 py-2 fs-6"; 
                if (estadoActual === 'Activo') badgeEstado.classList.add('bg-success');
                else if (estadoActual === 'Inactivo') badgeEstado.classList.add('bg-danger');
                else badgeEstado.classList.add('bg-secondary');

                // --- RELLENAR FORMULARIO PRINCIPAL ---
                document.getElementById('id_usuario_admin').value = user.id_usuario || '';
                document.getElementById('id_datos_usuario_admin').value = user.id_datos_usuario || '';
                document.getElementById('nombres_admin').value = user.nombres || '';
                document.getElementById('apellidos_admin').value = user.apellidos || '';
                document.getElementById('correo_admin').value = user.correo || '';
                document.getElementById('fecha_nacimiento_admin').value = user.fecha_nacimiento || '';
                document.getElementById('rol_admin').value = user.nombre_rol ? user.nombre_rol.toUpperCase() : '';
                document.getElementById('sexo_admin').value = user.Sexo || '';
                document.getElementById('departamento_admin').value = user.departamento || '';
                document.getElementById('municipio_admin').value = user.municipio || '';
                document.getElementById('direccion_admin').value = user.direccion || '';
                document.getElementById('telefono_admin').value = user.telefono || '';
                document.getElementById('telefono_emergencia_admin').value = user.telefono_emergencia || '';
                document.getElementById('estrato_admin').value = user.Estrato || '';
                document.getElementById('eps_admin').value = user.eps || '';

                // --- LÓGICA DE BLOQUEO DE DOCUMENTO ---
                const inputDocumento = document.getElementById('numero_documento_admin');
                const selectTipoDoc = document.getElementById('tipo_documento_admin');

                inputDocumento.value = user.numero_documento || '';
                selectTipoDoc.value = user.tipo_documento || '';

                if (user.numero_documento) {
                    inputDocumento.readOnly = true;
                    inputDocumento.classList.add('bg-light');
                    selectTipoDoc.disabled = true;
                    selectTipoDoc.classList.add('bg-light');
                } else {
                    inputDocumento.readOnly = false;
                    inputDocumento.classList.remove('bg-light');
                    selectTipoDoc.disabled = false;
                    selectTipoDoc.classList.remove('bg-light');
                }
            } else {
                console.error("Error devuelto por la API:", res.message);
                mostrarToast('Error', 'No se pudieron recuperar los datos de tu perfil.', 'error');
            }
        })
        .catch(error => {
            console.error("Error en la petición Fetch de carga:", error);
            mostrarToast('Error crítico', 'No hay conexión con el servidor de datos.', 'error');
        });
}

/**
 * 2. FUNCIÓN PARA ENVIAR LAS ACTUALIZACIONES AL BACKEND (CON NUEVAS VALIDACIONES)
 */
function guardarPerfilweb() {
    // Capturar datos quitando espacios innecesarios
    const nombres = document.getElementById('nombres_admin').value.trim();
    const apellidos = document.getElementById('apellidos_admin').value.trim();
    const correo = document.getElementById('correo_admin').value.trim();
    const fecha_nacimiento = document.getElementById('fecha_nacimiento_admin').value;
    const sexo = document.getElementById('sexo_admin').value;
    const tipo_documento = document.getElementById('tipo_documento_admin').value;
    const numero_documento = document.getElementById('numero_documento_admin').value.trim();
    const departamento = document.getElementById('departamento_admin').value.trim();
    const municipio = document.getElementById('municipio_admin').value.trim();
    const direccion = document.getElementById('direccion_admin').value.trim();
    const telefono = document.getElementById('telefono_admin').value.trim();
    const telefono_emergencia = document.getElementById('telefono_emergencia_admin').value.trim();
    const estrato = document.getElementById('estrato_admin').value;
    const eps = document.getElementById('eps_admin').value.trim();
    const nueva_clave = document.getElementById('nueva_clave_admin').value;

    // --- NUEVA VALIDACIÓN 1: CAMPOS VACÍOS (Excluyendo la nueva clave) ---
    if (!nombres || !apellidos || !correo || !fecha_nacimiento || !sexo || 
        !tipo_documento || !numero_documento || !departamento || !municipio || 
        !direccion || !telefono || !telefono_emergencia || !estrato || !eps) {
        
        mostrarToast('⚠️ Advertencia', 'Todos los datos personales y de cuenta son obligatorios.', 'warning');
        return; // Detiene la ejecución
    }

    // --- NUEVA VALIDACIÓN 2: TELÉFONOS IDÉNTICOS ---
    if (telefono === telefono_emergencia) {
        mostrarToast('⚠️ Advertencia', 'El número de emergencia no puede ser igual al número de teléfono personal.', 'warning');
        return; // Detiene la ejecución
    }

    // Si todo está correcto, armamos el objeto para el backend
    const datosPerfil = {
        nombres, apellidos, correo, fecha_nacimiento, sexo, tipo_documento,
        numero_documento, departamento, municipio, direccion, telefono,
        telefono_emergencia, estrato, eps, nueva_clave
    };

    // Enviar datos hacia el endpoint de Flask
    fetch('/api/admin/perfil-guardar-web', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(datosPerfil)
    })
    .then(response => response.json())
    .then(res => {
        if (res.status === 'success') {
            mostrarToast('¡Cambios guardados!', res.message, 'success');
            
            document.getElementById('nombreCompletoAdminVista').textContent = `${datosPerfil.nombres} ${datosPerfil.apellidos}`;
            if (datosPerfil.nombres.length > 0) {
                document.querySelector('.avatar').textContent = datosPerfil.nombres[0].toUpperCase();
            }
            
            document.getElementById('nueva_clave_admin').value = '';
            cargarDatosPerfil();
        } else {
            mostrarToast('Error al actualizar', res.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error en la petición Fetch de guardado:', error);
        mostrarToast('Error de red', 'No se ha podido procesar la solicitud en el servidor.', 'error');
    });
}

/**
 * 3. FUNCIÓN AUXILIAR PARA CONTROLAR EL TOAST (SOPORTA ÉXITO, ERROR Y ADVERTENCIA)
 * @param {string} tipo - Puede ser 'success' (verde), 'error' (rojo) o 'warning' (amarillo)
 */
function mostrarToast(titulo, mensaje, tipo = 'success') {
    const toastEl = document.getElementById('toastNotificacion');
    const tituloEl = document.getElementById('toastTitulo');
    const mensajeEl = document.getElementById('toastMensaje');
    
    // Limpiar estilos anteriores
    toastEl.classList.remove('bg-success', 'bg-danger', 'bg-warning', 'text-dark', 'text-white');
    
    // Aplicar estilos según el tipo de alerta recibido
    if (tipo === 'success') {
        toastEl.classList.add('bg-success', 'text-white');
    } else if (tipo === 'error') {
        toastEl.classList.add('bg-danger', 'text-white');
    } else if (tipo === 'warning') {
        // Estilo exacto al de tu captura: Fondo amarillo/oro con texto oscuro
        toastEl.style.backgroundColor = '#ffc107'; 
        toastEl.classList.add('text-dark');
        
        // Ajustar el botón de cerrar del toast para que sea oscuro e identificable
        const btnClose = toastEl.querySelector('.btn-close');
        if(btnClose) btnClose.classList.remove('btn-close-white');
    }
    
    // Si no es warning, removemos el estilo inline para que use las clases de Bootstrap
    if (tipo !== 'warning') {
        toastEl.style.backgroundColor = '';
        const btnClose = toastEl.querySelector('.btn-close');
        if(btnClose) btnClose.classList.add('btn-close-white');
    }
    
    tituloEl.textContent = titulo;
    mensajeEl.textContent = mensaje;
    
    const toast = new bootstrap.Toast(toastEl);
    toast.show();
}

cargarDatosPerfil();
