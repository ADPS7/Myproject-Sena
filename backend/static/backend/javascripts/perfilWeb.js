document.addEventListener('DOMContentLoaded', () => {
    cargarDatosPerfil();
});

/**
 * 1. OBTENER INFORMACIÓN DE LA API
 */
function cargarDatosPerfil() {
    fetch('/api/admin/perfil-datos')
        .then(response => response.json())
        .then(res => {
            if (res.status === 'success') {
                const user = res.data;

                // Actualizar interfaz lateral
                const inicial = user.nombres ? user.nombres[0].toUpperCase() : 'A';
                document.getElementById('avatarLetra').textContent = inicial;
                document.getElementById('nombreCompletoAdminVista').textContent = `${user.nombres} ${user.apellidos}`;
                document.getElementById('rolAdminVista').textContent = user.nombre_rol ? user.nombre_rol.toUpperCase() : 'ADMINISTRADOR';
                
                // Controlar Badge de Estado
                const badgeEstado = document.getElementById('estadoAdminVista');
                const estadoActual = user.estado || 'Pendiente';
                badgeEstado.textContent = `Estado: ${estadoActual}`;
                badgeEstado.className = "badge rounded-pill px-3 py-2 fs-6";
                
                if (estadoActual === 'Activo') badgeEstado.classList.add('bg-success');
                else if (estadoActual === 'Inactivo') badgeEstado.classList.add('bg-danger');
                else badgeEstado.classList.add('bg-secondary');

                // Rellenar los inputs del formulario
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

                // Bloqueo inteligente del documento si ya existe
                const inputDoc = document.getElementById('numero_documento_admin');
                const selectDoc = document.getElementById('tipo_documento_admin');
                inputDoc.value = user.numero_documento || '';
                selectDoc.value = user.tipo_documento || '';

                if (user.numero_documento) {
                    inputDoc.readOnly = true;
                    inputDoc.classList.add('bg-light');
                    selectDoc.disabled = true;
                    selectDoc.classList.add('bg-light');
                }
            } else {
                crearNotificacionNativa('Error de Carga', res.message, 'error');
            }
        })
        .catch(error => {
            console.error(error);
            crearNotificacionNativa('Error Crítico', 'No se pudo conectar con el servidor.', 'error');
        });
}

/**
 * 2. ENVIAR ACTUALIZACIONES
 *//**
 * 2. ENVIAR ACTUALIZACIONES (CON VALIDACIÓN ESTRICTA ANTIVACÍOS)
 */
/**
 * 2. ENVIAR ACTUALIZACIONES (CON VALIDACIÓN ANTIVACÍOS Y LONGITUD DE CONTRASEÑA)
 */
function guardarPerfilweb() {
    // 1. Capturar todos los elementos del formulario
    const inputs = {
        'Nombres': document.getElementById('nombres_admin'),
        'Apellidos': document.getElementById('apellidos_admin'),
        'Correo Electrónico': document.getElementById('correo_admin'),
        'Fecha de Nacimiento': document.getElementById('fecha_nacimiento_admin'),
        'Sexo': document.getElementById('sexo_admin'),
        'Tipo de Documento': document.getElementById('tipo_documento_admin'),
        'Número de Documento': document.getElementById('numero_documento_admin'),
        'Departamento': document.getElementById('departamento_admin'),
        'Municipio': document.getElementById('municipio_admin'),
        'Dirección': document.getElementById('direccion_admin'),
        'Teléfono Personal': document.getElementById('telefono_admin'),
        'Contacto de Emergencia': document.getElementById('telefono_emergencia_admin'),
        'Estrato Socioeconómico': document.getElementById('estrato_admin'),
        'Entidad de Salud (EPS)': document.getElementById('eps_admin')
    };

    // 2. Recorrer campo por campo buscando valores vacíos
    for (const [nombreCampo, elemento] of Object.entries(inputs)) {
        if (!elemento) continue; 

        const valor = elemento.value.trim(); 

        if (valor === "" || valor === null || valor === undefined) {
            crearNotificacionNativa('Campo Obligatorio', `Por favor, rellene el campo: <strong>${nombreCampo}</strong>`, 'warning');
            elemento.focus();
            elemento.classList.add('is-invalid'); 
            
            elemento.addEventListener('input', function quitarError() {
                elemento.classList.remove('is-invalid');
                elemento.removeEventListener('input', quitarError);
            });

            return; 
        }
    }

    // 3. Capturar valores ya validados
    const nombres = inputs['Nombres'].value.trim();
    const apellidos = inputs['Apellidos'].value.trim();
    const correo = inputs['Correo Electrónico'].value.trim();
    const fecha_nacimiento = inputs['Fecha de Nacimiento'].value;
    const sexo = inputs['Sexo'].value;
    const tipo_documento = inputs['Tipo de Documento'].value;
    const numero_documento = inputs['Número de Documento'].value.trim();
    const departamento = inputs['Departamento'].value.trim();
    const municipio = inputs['Municipio'].value.trim();
    const direccion = inputs['Dirección'].value.trim();
    const telefono = inputs['Teléfono Personal'].value.trim();
    const telefono_emergencia = inputs['Contacto de Emergencia'].value.trim();
    const estrato = inputs['Estrato Socioeconómico'].value;
    const eps = inputs['Entidad de Salud (EPS)'].value.trim();
    
    // Capturar y limpiar la nueva contraseña
    const inputClave = document.getElementById('nueva_clave_admin');
    const nueva_clave = inputClave.value; 

    // 4. NUEVA VALIDACIÓN: Control de longitud de la contraseña
    // Si no está vacía (el usuario escribió algo), validamos que tenga más de 6 caracteres
    if (nueva_clave.length > 0 && nueva_clave.length <= 6) {
        crearNotificacionNativa(
            'Seguridad de Cuenta', 
            'La nueva contraseña debe tener <strong>más de 6 caracteres</strong>.', 
            'warning'
        );
        inputClave.focus();
        inputClave.classList.add('is-invalid');

        inputClave.addEventListener('input', function quitarErrorClave() {
            inputClave.classList.remove('is-invalid');
            inputClave.removeEventListener('input', quitarErrorClave);
        });
        return; // Detiene el flujo
    }

    // 5. Validación lógica extra: Teléfonos idénticos
    if (telefono === telefono_emergencia) {
        crearNotificacionNativa('Validación', 'El teléfono de emergencia no puede ser el mismo que el personal.', 'warning');
        inputs['Contacto de Emergencia'].focus();
        return;
    }

    // 6. Preparar el Payload si todo está perfecto
    const payload = {
        nombres, apellidos, correo, fecha_nacimiento, sexo, tipo_documento,
        numero_documento, departamento, municipio, direccion, telefono,
        telefono_emergencia, estrato, eps, nueva_clave
    };

    // 7. Realizar la petición Fetch de guardado
    fetch('/api/admin/perfil-guardar-web', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(response => response.json())
    .then(res => {
        if (res.status === 'success') {
            crearNotificacionNativa('¡Hecho!', 'Tu perfil ha sido actualizado con éxito.', 'success');
            inputClave.value = ''; // Limpiar el input de contraseña tras guardar con éxito
            cargarDatosPerfil();
        } else {
            crearNotificacionNativa('Ocurrió un problema', res.message, 'error');
        }
    })
    .catch(error => {
        console.error(error);
        crearNotificacionNativa('Error de Red', 'No se pudo procesar la solicitud de guardado.', 'error');
    });
}

/**
 * 3. CONSTRUCTOR DE NOTIFICACIÓN NATIVA (HTML Y CSS PURO SIN DEPENDER DE BOOTSTRAP JS)
 */
function crearNotificacionNativa(titulo, mensaje, tipo = 'success') {
    // 1. Controlar que exista un contenedor maestro en la pantalla para apilar los mensajes
    let contenedorMaestro = document.getElementById('contenedor-notificaciones-nativas');
    if (!contenedorMaestro) {
        contenedorMaestro = document.createElement('div');
        contenedorMaestro.id = 'contenedor-notificaciones-nativas';
        // Posicionamiento absoluto en la esquina inferior derecha
        contenedorMaestro.style.cssText = 'position: fixed; bottom: 20px; right: 20px; z-index: 99999; display: flex; flex-direction: column; gap: 10px; max-width: 350px; width: 100%;';
        document.body.appendChild(contenedorMaestro);
    }

    // 2. Definir colores, fondos e iconos usando CSS nativo según el tipo
    let colorFondo = '#198754'; // Verde éxito
    let colorTexto = '#ffffff';
    let icono = '✓';

    if (tipo === 'error') {
        colorFondo = '#dc3545'; // Rojo peligro
        icono = '✕';
    } else if (tipo === 'warning') {
        colorFondo = '#ffc107'; // Amarillo advertencia
        colorTexto = '#212529';
        icono = '⚠';
    }

    // 3. Crear la estructura de la tarjeta con transiciones y diseño moderno
    const tarjetaAlerta = document.createElement('div');
    tarjetaAlerta.style.cssText = `
        background-color: ${colorFondo};
        color: ${colorTexto};
        padding: 16px;
        border-radius: 12px;
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        display: flex;
        align-items: flex-start;
        gap: 12px;
        font-family: system-ui, -apple-system, sans-serif;
        transition: all 0.4s ease;
        opacity: 0;
        transform: translateY(20px);
    `;

    // Contenido interno (Icono, título, mensaje y botón de cierre)
    tarjetaAlerta.innerHTML = `
        <div style="font-size: 1.25rem; font-weight: bold; line-height: 1;">${icono}</div>
        <div style="flex-grow: 1;">
            <h5 style="margin: 0 0 4px 0; font-size: 0.95rem; font-weight: 700;">${titulo}</h5>
            <p style="margin: 0; font-size: 0.85rem; opacity: 0.9; line-height: 1.4;">${mensaje}</p>
        </div>
        <button style="background: none; border: none; color: ${colorTexto}; cursor: pointer; font-size: 1rem; font-weight: bold; opacity: 0.7; padding: 0 4px;" onclick="this.parentElement.remove()">✕</button>
    `;

    // 4. Inyectar al contenedor maestro
    contenedorMaestro.appendChild(tarjetaAlerta);

    // 5. Animación de entrada suave (Fade-in)
    setTimeout(() => {
        tarjetaAlerta.style.opacity = '1';
        tarjetaAlerta.style.transform = 'translateY(0)';
    }, 50);

    // 6. Temporizador para autodestrucción y salida limpia a los 4 segundos
    setTimeout(() => {
        tarjetaAlerta.style.opacity = '0';
        tarjetaAlerta.style.transform = 'scale(0.9)';
        setTimeout(() => {
            tarjetaAlerta.remove();
            // Si ya no quedan más notificaciones, limpiamos el contenedor maestro de la memoria
            if (contenedorMaestro.childElementCount === 0) {
                contenedorMaestro.remove();
            }
        }, 400); // Espera a que termine la animación de salida antes de borrar el HTML
    }, 4000);
}