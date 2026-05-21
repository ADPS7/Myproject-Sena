// =========================================================================
// 1. FUNCIÓN ENCARGADA DE CONSULTAR Y MOSTRAR LOS DATOS EN PANTALLA
// =========================================================================
function Datos_consultar() {
    const urlParams = new URLSearchParams(window.location.search);
    const idUsuario = urlParams.get('id_usuario');

    if (idUsuario) {
        // Guardamos el ID de forma interna en el input hidden del formulario
        document.getElementById('id_usuario_prof').value = idUsuario;

        // Petición al backend para obtener los datos estructurados en JSON
        fetch(`/obtener_perfil_completo?id_usuario=${idUsuario}`)
            .then(response => response.json())
            .then(data => {
                if (!data.error) {
                    // Pintar elementos de texto dinámicos en la tarjeta lateral
                    document.getElementById('nombreCompletoProfesorVista').textContent = `${data.nombres} ${data.apellidos}`;
                    document.getElementById('rolProfesorVista').textContent = data.rol || 'Docente';
                    
                    if (data.nombres) {
                        document.getElementById('avatarProfesor').textContent = data.nombres[0].toUpperCase();
                    }

                    // Administrar el badge visual de estados
                    const badgeEstado = document.getElementById('estadoProfesorBadge');
                    if (data.estado) {
                        badgeEstado.textContent = `Estado: ${data.estado}`;
                        badgeEstado.className = "badge rounded-pill px-3 py-2 fs-6 ";
                        if (data.estado === 'Activo') badgeEstado.classList.add('bg-success');
                        else if (data.estado === 'Pendiente') badgeEstado.classList.add('bg-warning', 'text-dark');
                        else badgeEstado.classList.add('bg-danger');
                    }

                    // Rellenar dinámicamente cada input del formulario (Tabla Usuarios)
                    document.getElementById('nombres_prof').value = data.nombres || '';
                    document.getElementById('apellidos_prof').value = data.apellidos || '';
                    document.getElementById('correo_prof').value = data.correo || '';
                    document.getElementById('fecha_nacimiento_prof').value = data.fecha_nacimiento || '';
                    document.getElementById('rol_prof').value = data.rol || '';
                    
                    // Rellenar datos adicionales (Tabla DatosUsuarios)
                    document.getElementById('id_datos_usuario_prof').value = data.id_datos_usuario || '';
                    document.getElementById('sexo_prof').value = data.Sexo || '';
                    document.getElementById('tipo_documento_prof').value = data.tipo_documento || '';
                    document.getElementById('numero_documento_prof').value = data.numero_documento || '';
                    document.getElementById('departamento_prof').value = data.departamento || '';
                    document.getElementById('municipio_prof').value = data.municipio || '';
                    document.getElementById('direccion_prof').value = data.direccion || '';
                    document.getElementById('telefono_prof').value = data.telefono || '';
                    document.getElementById('telefono_emergencia_prof').value = data.telefono_emergencia || '';
                    document.getElementById('estrato_prof').value = data.Estrato || '';
                    document.getElementById('eps_prof').value = data.eps || '';
                }
            })
            .catch(error => console.error("Error al renderizar los datos del perfil:", error));
    }
}

// =========================================================================
// 2. FUNCIÓN AYUDANTE: Cambia colores dinámicamente y muestra la alerta Toast
// =========================================================================
function mostrarToast(titulo, mensaje, tipo) {
    const toastElement = document.getElementById('toastNotificacion');
    const header = document.getElementById('toastHeader');
    const body = document.getElementById('toastMensaje');
    const icono = document.getElementById('toastIcono');
    const btnCerrar = document.getElementById('toastBtnCerrar');

    // Resetear clases previas de color, iconos y fuentes
    header.className = "toast-header border-0 rounded-top-4 py-2";
    body.className = "toast-body rounded-bottom-4 py-3";
    icono.className = "bi me-2 fs-5";
    btnCerrar.className = "btn-close";

    // Asignar textos básicos
    document.getElementById('toastTitulo').textContent = titulo;
    body.textContent = mensaje;

    // Configurar paleta de colores reactiva según el tipo de respuesta
    if (tipo === 'exito') {
        header.style.backgroundColor = "#e8f5e9";
        header.style.color = "#1b5e20";
        body.classList.add('bg-success', 'text-white');
        icono.classList.add('bi-check-circle-fill');
        btnCerrar.classList.add('btn-close-white'); // X blanca para fondo oscuro
    } 
    else if (tipo === 'advertencia') {
        header.style.backgroundColor = "#fff3cd";
        header.style.color = "#664d03";
        body.classList.add('bg-warning', 'text-dark'); // Texto oscuro sobre fondo amarillo
        icono.classList.add('bi-exclamation-triangle-fill');
        btnCerrar.className = "btn-close"; // X oscura estándar
    } 
    else if (tipo === 'error') {
        header.style.backgroundColor = "#f8d7da";
        header.style.color = "#842029";
        body.classList.add('bg-danger', 'text-white');
        icono.classList.add('bi-x-circle-fill');
        btnCerrar.classList.add('btn-close-white');
    }

    // Inicializar y desplegar el Toast usando el objeto nativo de Bootstrap 5
    const bootstrapToast = new bootstrap.Toast(toastElement);
    bootstrapToast.show();
}

// =========================================================================
// 3. FUNCIÓN PRINCIPAL: Valida campos en cliente y envía la información
// =========================================================================
function guardarPerfilProfesor() {
    // Mapeo exhaustivo y captura limpia de todos los campos del DOM
    const inputs = {
        id_usuario: document.getElementById('id_usuario_prof').value,
        nombres: document.getElementById('nombres_prof').value.trim(),
        apellidos: document.getElementById('apellidos_prof').value.trim(),
        correo: document.getElementById('correo_prof').value.trim(),
        fecha_nacimiento: document.getElementById('fecha_nacimiento_prof').value,
        sexo: document.getElementById('sexo_prof').value,
        tipo_documento: document.getElementById('tipo_documento_prof').value,
        numero_documento: document.getElementById('numero_documento_prof').value.trim(),
        departamento: document.getElementById('departamento_prof').value.trim(),
        municipio: document.getElementById('municipio_prof').value.trim(),
        direccion: document.getElementById('direccion_prof').value.trim(),
        telefono: document.getElementById('telefono_prof').value.trim(),
        telefono_emergencia: document.getElementById('telefono_emergencia_prof').value.trim(),
        estrato: document.getElementById('estrato_prof').value,
        eps: document.getElementById('eps_prof').value.trim()
    };

    // REGLA 1: Validación de campos vacíos obligatorios -> Toast Amarillo
    for (const campo in inputs) {
        if (!inputs[campo] || inputs[campo] === "") {
            mostrarToast('Advertencia', 'Todos los datos personales y de cuenta son obligatorios.', 'advertencia');
            return; // Detiene la ejecución completa
        }
    }

    // REGLA 2: Bloqueo de números telefónicos idénticos -> Toast Amarillo
    if (inputs.telefono === inputs.telefono_emergencia) {
        mostrarToast('Advertencia', 'El número de teléfono personal no puede ser idéntico al de emergencia.', 'advertencia');
        return; // Evita el envío al backend
    }

    // Ejecución de la petición asíncrona hacia el Backend en Flask
    fetch('/guardar_datos_perfil', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(inputs)
    })
    .then(response => response.json())
    .then(res => {
        if (res.exito) {
            // REGLA 3: Si todo es correcto en base de datos -> Toast Verde y Cierre de Sesión Seguro
            mostrarToast('Éxito', 'Perfil actualizado exitosamente. Cerrando sesión...', 'exito');
            
            // Retardo para que el usuario aprecie la barra de éxito antes de desloguearlo
            setTimeout(() => {
                window.location.href = '/logout';
            }, 2500);
        } else {
            // REGLA 4: Si el servidor detectó documento repetido u otro fallo
            // Mapea el string 'advertencia' para cambiar a color amarillo dinámicamente
            const tipoAlerta = res.tipo_error === 'advertencia' ? 'advertencia' : 'error';
            const tituloAlerta = res.tipo_error === 'advertencia' ? 'Advertencia' : 'Error al procesar';
            
            mostrarToast(tituloAlerta, res.mensaje, tipoAlerta);
        }
    })
    .catch(error => {
        console.error("Fallo crítico en la petición Fetch:", error);
        mostrarToast('Error de Conexión', 'No se pudo establecer comunicación estable con el servidor.', 'error');
    });
}

// Ejecución automática inmediata al cargar el entorno de la página
Datos_consultar();