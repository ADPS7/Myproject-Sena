// 1. FUNCIÓN ENCARGADA DE CONSULTAR Y MOSTRAR LOS DATOS EN PANTALLA
function Datos_consultar() {
    const urlParams = new URLSearchParams(window.location.search);
    const idUsuario = urlParams.get('id_usuario');

    if (idUsuario) {
        // Guardamos el ID de forma interna en el formulario
        document.getElementById('id_usuario_prof').value = idUsuario;

        // Petición al backend para obtener los datos estructurados en JSON
        fetch(`/obtener_perfil_completo?id_usuario=${idUsuario}`)
            .then(response => response.json())
            .then(data => {
                if (!data.error) {
                    // Pintar elementos de texto dinámicos
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

                    // Rellenar dinámicamente cada input del formulario
                    document.getElementById('nombres_prof').value = data.nombres || '';
                    document.getElementById('apellidos_prof').value = data.apellidos || '';
                    document.getElementById('correo_prof').value = data.correo || '';
                    document.getElementById('fecha_nacimiento_prof').value = data.fecha_nacimiento || '';
                    document.getElementById('rol_prof').value = data.rol || '';
                    
                    // Rellenar datos adicionales de la tabla DatosUsuarios
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

// 1. FUNCIÓN AYUDANTE: Cambia colores dinámicamente y muestra la alerta
function mostrarToast(titulo, mensaje, tipo) {
    const toastElement = document.getElementById('toastNotificacion');
    const header = document.getElementById('toastHeader');
    const body = document.getElementById('toastMensaje');
    const icono = document.getElementById('toastIcono');
    const btnCerrar = document.getElementById('toastBtnCerrar');

    // Resetear clases previas de color y texto
    header.className = "toast-header border-0 rounded-top-4 py-2";
    body.className = "toast-body rounded-bottom-4 py-3";
    icono.className = "bi me-2 fs-5";
    btnCerrar.className = "btn-close";

    // Asignar textos básicos
    document.getElementById('toastTitulo').textContent = titulo;
    body.textContent = mensaje;

    // Configurar paleta de colores según el tipo de respuesta
    if (tipo === 'exito') {
        header.style.backgroundColor = "#e8f5e9";
        header.style.color = "#1b5e20";
        body.classList.add('bg-success', 'text-white');
        icono.classList.add('bi-check-circle-fill');
        btnCerrar.classList.add('btn-close-white'); // Botón X en blanco para contrastar
    } 
    else if (tipo === 'advertencia') {
        // Estilo de Advertencia (Amarillo / Naranja suave de Bootstrap)
        header.style.backgroundColor = "#fff3cd";
        header.style.color = "#664d03";
        body.classList.add('bg-warning', 'text-dark'); // Texto oscuro para que se lea en el amarillo
        icono.classList.add('bi-exclamation-triangle-fill');
        btnCerrar.className = "btn-close"; // Botón X oscuro estándar
    } 
    else if (tipo === 'error') {
        header.style.backgroundColor = "#f8d7da";
        header.style.color = "#842029";
        body.classList.add('bg-danger', 'text-white');
        icono.classList.add('bi-x-circle-fill');
        btnCerrar.classList.add('btn-close-white');
    }

    // Desplegar el componente usando Bootstrap
    const bootstrapToast = new bootstrap.Toast(toastElement);
    bootstrapToast.show();
}

// 2. FUNCIÓN DE GUARDADO CON COMPORTAMIENTO DINÁMICO
function guardarPerfilProfesor() {
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

    // Si faltan datos -> Alerta de Advertencia (Amarilla)
    for (const campo in inputs) {
        if (!inputs[campo] || inputs[campo] === "") {
            mostrarToast('Advertencia', 'Todos los datos personales y de cuenta son obligatorios.', 'advertencia');
            return; 
        }
    }

    // Petición de guardado hacia Flask
    fetch('/guardar_datos_perfil', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(inputs)
    })
    .then(response => response.json())
    .then(res => {
        if (res.exito) {
            // Si el servidor responde bien -> Alerta de Éxito (Verde como tu captura)
            mostrarToast('Éxito', 'Perfil actualizado exitosamente.', 'exito');
            
            setTimeout(() => {
                window.location.href = '/logout';
            }, 2500);
        } else {
            // Si el servidor rechaza el guardado por alguna regla -> Alerta de Error (Roja)
            mostrarToast('Error al procesar', res.mensaje, 'error');
        }
    })
    .catch(error => {
        console.error("Error:", error);
        mostrarToast('Error de Conexión', 'No se pudo comunicar con el servidor.', 'error');
    });
}
// Inicializar la carga de datos inmediatamente al abrir la interfaz
Datos_consultar();