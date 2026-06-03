// =========================================================================
// 1. FUNCIÓN ENCARGADA DE CONSULTAR Y MOSTRAR LOS DATOS EN PANTALLA
// =========================================================================
function Datos_consultar() {
    const urlParams = new URLSearchParams(window.location.search);
    const idUsuario = urlParams.get('id_usuario');

    if (idUsuario) {
        document.getElementById('id_usuario_prof').value = idUsuario;

        fetch(`/obtener_perfil_completo?id_usuario=${idUsuario}`)
            .then(response => response.json())
            .then(responseJson => { 
                console.log(responseJson);
                
                if (responseJson.status === "success" && responseJson.data) {
                    const data = responseJson.data; 

                    document.getElementById('nombreCompletoProfesorVista').textContent = `${data.nombres || ''} ${data.apellidos || ''}`;
                    document.getElementById('rolProfesorVista').textContent = data.rol || 'Docente';
                    
                    if (data.nombres) {
                        document.getElementById('avatarProfesor').textContent = data.nombres[0].toUpperCase();
                    }

                    const badgeEstado = document.getElementById('estadoProfesorBadge');
                    if (data.estado) {
                        badgeEstado.textContent = `Estado: ${data.estado}`;
                        badgeEstado.className = "badge rounded-pill px-3 py-2 fs-6 ";
                        if (data.estado === 'Activo') badgeEstado.classList.add('bg-success');
                        else if (data.estado === 'Pendiente') badgeEstado.classList.add('bg-warning', 'text-dark');
                        else badgeEstado.classList.add('bg-danger');
                    }

                    document.getElementById('nombres_prof').value = data.nombres || '';
                    document.getElementById('apellidos_prof').value = data.apellidos || '';
                    document.getElementById('correo_prof').value = data.correo || '';
                    document.getElementById('fecha_nacimiento_prof').value = data.fecha_nacimiento || '';
                    document.getElementById('rol_prof').value = data.rol || '';
                    
                    document.getElementById('id_datos_usuario_prof').value = data.id_datos_usuario || '';
                    document.getElementById('sexo_prof').value = data.Sexo || '';
                    document.getElementById('tipo_documento_prof').value = data.tipo_documento || '';
                    document.getElementById('numero_documento_prof').value = data.numero_documento || '';
                    
                    if(data.departamento) {
                        const selectDepto = document.getElementById('departamento_prof');
                        selectDepto.value = data.departamento;
                        actualizarMunicipios(data.departamento);
                        if(data.municipio) {
                            document.getElementById('municipio_prof').value = data.municipio;
                        }
                    }
                    
                    document.getElementById('direccion_prof').value = data.direccion || '';
                    document.getElementById('telefono_prof').value = data.telefono || '';
                    document.getElementById('telefono_emergencia_prof').value = data.telefono_emergencia || '';
                    document.getElementById('estrato_prof').value = data.Estrato || '';
                    
                    if(data.eps) {
                        document.getElementById('eps_prof').value = data.eps;
                    }
                } else {
                    console.error("El servidor no devolvió un estado de éxito o los datos están vacíos.");
                }
            })
            .catch(error => console.error("Error al renderizar los datos del perfil:", error));
    }
}

// =========================================================================
// 2. FUNCIÓN AYUDANTE: Alertas Toast (Éxitos, Errores y Advertencias)
// =========================================================================
function mostrarToast(titulo, mensaje, tipo) {
    const toastElement = document.getElementById('toastNotificacion');
    const header = document.getElementById('toastHeader');
    const body = document.getElementById('toastMensaje');
    const icono = document.getElementById('toastIcono');
    const btnCerrar = document.getElementById('toastBtnCerrar');

    header.className = "toast-header border-0 rounded-top-4 py-2";
    body.className = "toast-body rounded-bottom-4 py-3";
    icono.className = "bi me-2 fs-5";
    btnCerrar.className = "btn-close";

    document.getElementById('toastTitulo').textContent = titulo;
    body.textContent = mensaje;

    if (tipo === 'exito') {
        header.style.backgroundColor = "#e8f5e9";
        header.style.color = "#1b5e20";
        body.className = "toast-body rounded-bottom-4 py-3 bg-success text-white";
        icono.className = "bi bi-check-circle-fill me-2 fs-5";
        btnCerrar.className = "btn-close btn-close-white"; 
    } 
    else if (tipo === 'advertencia') {
        header.style.backgroundColor = "#fff3cd";
        header.style.color = "#664d03";
        body.className = "toast-body rounded-bottom-4 py-3 bg-warning text-dark"; 
        icono.className = "bi bi-exclamation-triangle-fill me-2 fs-5";
        btnCerrar.className = "btn-close"; 
    } 
    else if (tipo === 'error') {
        header.style.backgroundColor = "#f8d7da";
        header.style.color = "#842029";
        body.className = "toast-body rounded-bottom-4 py-3 bg-danger text-white";
        icono.className = "bi bi-x-circle-fill me-2 fs-5";
        btnCerrar.className = "btn-close btn-close-white";
    }

    const bootstrapToast = new bootstrap.Toast(toastElement);
    bootstrapToast.show();
}

// =========================================================================
// 3. FUNCIÓN PRINCIPAL: Guardar y Validar Datos (Obligatoriedad Máxima)
// =========================================================================
function guardarPerfilProfesor() {
    let elementosConError = [];

    const camposMapeados = {
        nombres: document.getElementById('nombres_prof'),
        apellidos: document.getElementById('apellidos_prof'),
        correo: document.getElementById('correo_prof'),
        fecha_nacimiento: document.getElementById('fecha_nacimiento_prof'),
        sexo: document.getElementById('sexo_prof'),
        tipo_documento: document.getElementById('tipo_documento_prof'),
        numero_documento: document.getElementById('numero_documento_prof'),
        departamento: document.getElementById('departamento_prof'),
        municipio: document.getElementById('municipio_prof'),
        direccion: document.getElementById('direccion_prof'),
        telefono: document.getElementById('telefono_prof'),
        telefono_emergencia: document.getElementById('telefono_emergencia_prof'),
        estrato: document.getElementById('estrato_prof'),
        eps: document.getElementById('eps_prof')
    };

    // Limpiar clases de error previas
    for (const llave in camposMapeados) {
        camposMapeados[llave].classList.remove('is-invalid');
    }

    // REGLA 1: Todos los campos son estrictamente requeridos
    for (const llave in camposMapeados) {
        if (!camposMapeados[llave].value || camposMapeados[llave].value.trim() === "") {
            camposMapeados[llave].classList.add('is-invalid');
            elementosConError.push(camposMapeados[llave]);
        }
    }

    if (elementosConError.length > 0) {
        elementosConError[0].focus();
        mostrarToast('Datos Incompletos', 'Todos los campos en pantalla son obligatorios para poder continuar.', 'advertencia');
        return;
    }

    // REGLA 2: VALIDACIÓN DE EDAD MÍNIMA (16 AÑOS)
    const fechaIngresada = new Date(camposMapeados.fecha_nacimiento.value);
    const fechaActual = new Date();

    if (isNaN(fechaIngresada.getTime()) || fechaIngresada > fechaActual) {
        camposMapeados.fecha_nacimiento.classList.add('is-invalid');
        elementosConError.push(camposMapeados.fecha_nacimiento);
        mostrarToast('Fecha Inválida', 'Ingresa una fecha de nacimiento real.', 'advertencia');
    } else {
        let edad = fechaActual.getFullYear() - fechaIngresada.getFullYear();
        const mesDiferencia = fechaActual.getMonth() - fechaIngresada.getMonth();
        const diaDiferencia = fechaActual.getDate() - fechaIngresada.getDate();

        if (mesDiferencia < 0 || (mesDiferencia === 0 && diaDiferencia < 0)) {
            edad--;
        }

        if (edad < 16) {
            camposMapeados.fecha_nacimiento.classList.add('is-invalid');
            elementosConError.push(camposMapeados.fecha_nacimiento);
            mostrarToast('Restricción de Edad', 'Debes ser mayor de 16 años para registrarte en el sistema.', 'advertencia');
        }
    }

    if (elementosConError.length > 0) {
        elementosConError[0].focus();
        return;
    }

    // REGLA 3: Formato de correo electrónico
    const regexCorreoEstricto = /^[a-zA-Z0-9._%+-]+@[a-zA-Z.-]+\.[a-zA-Z]{2,6}$/;
    if (!regexCorreoEstricto.test(camposMapeados.correo.value.trim())) {
        camposMapeados.correo.classList.add('is-invalid');
        elementosConError.push(camposMapeados.correo);
    }

    // REGLA 4: Formato estricto de Teléfonos Colombianos
    const valTel = camposMapeados.telefono.value.trim();
    if (valTel.length !== 10 || !valTel.startsWith('3')) {
        camposMapeados.telefono.classList.add('is-invalid');
        elementosConError.push(camposMapeados.telefono);
    }

    const valEmerg = camposMapeados.telefono_emergencia.value.trim();
    if (valEmerg.length !== 10 || !valEmerg.startsWith('3')) {
        camposMapeados.telefono_emergencia.classList.add('is-invalid');
        elementosConError.push(camposMapeados.telefono_emergencia);
    }

    // REGLA 5: Teléfonos no idénticos
    if (valTel === valEmerg) {
        camposMapeados.telefono.classList.add('is-invalid');
        camposMapeados.telefono_emergencia.classList.add('is-invalid');
        elementosConError.push(camposMapeados.telefono);
        mostrarToast('Conflicto de Datos', 'El teléfono de emergencia no puede ser igual al personal.', 'advertencia');
    }

    if (elementosConError.length > 0) {
        elementosConError[0].focus();
        return;
    }

    // Si todo pasa con éxito, estructuramos para Flask
    const inputs = {
        id_usuario: document.getElementById('id_usuario_prof').value,
        nombres: camposMapeados.nombres.value.trim(),
        apellidos: camposMapeados.apellidos.value.trim(),
        correo: camposMapeados.correo.value.trim(),
        fecha_nacimiento: camposMapeados.fecha_nacimiento.value,
        sexo: camposMapeados.sexo.value,
        tipo_documento: camposMapeados.tipo_documento.value,
        numero_documento: camposMapeados.numero_documento.value.trim(),
        departamento: camposMapeados.departamento.value,
        municipio: camposMapeados.municipio.value,
        direccion: camposMapeados.direccion.value.trim(),
        telefono: valTel,
        telefono_emergencia: valEmerg,
        estrato: camposMapeados.estrato.value,
        eps: camposMapeados.eps.value
    };

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
            mostrarToast('Éxito', 'Perfil actualizado de forma segura. Reiniciando sesión...', 'exito');
            setTimeout(() => {
                window.location.href = '/logout';
            }, 2500);
        } else {
            if (res.mensaje && res.mensaje.includes("número de documento")) {
                camposMapeados.numero_documento.classList.add('is-invalid');
                camposMapeados.numero_documento.focus();
                mostrarToast('Error de duplicidad', 'Este número de documento ya está asignado a otra cuenta.', 'error');
            } else {
                mostrarToast('Error del Servidor', res.mensaje, 'error');
            }
        }
    })
    .catch(error => {
        console.error("Fallo Fetch:", error);
        mostrarToast('Error de Red', 'No hay conexión con el servidor.', 'error');
    });
}

// =========================================================================
// 4. LOGICA DE CARGA DINÁMICA DE DEPARTAMENTOS, MUNICIPIOS Y EPS
// =========================================================================
let datosColombiaGlobal = {};

const listadoEpsColombia = [
    "EPS SURA", "EPS SANITAS", "SALUD TOTAL EPS", "NUEVA EPS", "COMPENSAR EPS",
    "COOSALUD EPS", "MUTUAL SER EPS", "FAMISANAR EPS", "ALIANSALUD EPS",
    "SAVIA SALUD EPS", "EMSSANAR EPS", "CAPRESOCA EPS", "ASMET SALUD EPS",
    "ANAS WAYUU EPSI", "MALLAMAS EPSI", "PIJAOS SALUD EPSI", "SALUD MIA EPS"
];

function inicializarComponentesGeograficosYEps() {
    const selectDepto = document.getElementById('departamento_prof');
    const selectEps = document.getElementById('eps_prof');
    
    if (!selectDepto || !selectEps) return;

    listadoEpsColombia.sort().forEach(eps => {
        const option = document.createElement('option');
        option.value = eps;
        option.textContent = eps;
        selectEps.appendChild(option);
    });

    fetch('https://datos.gov.co/resource/82di-kkh9.json?$select=dpto,nom_mpio&$limit=5000')
        .then(response => response.json())
        .then(data => {
            if (!Array.isArray(data) || data.length === 0) throw new Error("Estructura vacía");
            
            data.forEach(item => {
                const depto = item.dpto;
                const muni = item.nom_mpio;
                if (depto && muni) {
                    if (!datosColombiaGlobal[depto]) datosColombiaGlobal[depto] = [];
                    if (!datosColombiaGlobal[depto].includes(muni)) datosColombiaGlobal[depto].push(muni);
                }
            });
            renderizarDepartamentos(selectDepto);
        })
        .catch(error => {
            console.warn("API externa no disponible, usando base local...", error);
            datosColombiaGlobal = {
                "AMAZONAS": ["Leticia", "Puerto Nariño"],
                "ANTIOQUIA": ["Medellín", "Bello", "Envigado", "Itagüí", "Rionegro", "Apartadó"],
                "ATLANTICO": ["Barranquilla", "Soledad", "Malambo", "Sabanalarga", "Puerto Colombia"],
                "BOLIVAR": ["Cartagena de Indias", "Magangué", "Turbaco", "El Carmen de Bolívar"],
                "BOYACA": ["Tunja", "Duitama", "Sogamoso", "Chiquinquirá"],
                "CALDAS": ["Manizales", "La Dorada", "Riosucio", "Chinchiná"],
                "CUNDINAMARCA": ["Bogotá D.C.", "Soacha", "Facatativá", "Chía", "Zipaquirá"],
                "HUILA": ["Neiva", "Pitalito", "Garzón"],
                "MAGDALENA": ["Santa Marta", "Ciénaga", "Fundación"],
                "NORTE DE SANTANDER": ["Cúcuta", "Ocaña", "Pamplona", "Villa del Rosario"],
                "SANTANDER": ["Bucaramanga", "Floridablanca", "Girón", "Piedecuesta", "Barrancabermeja"],
                "VALLE DEL CAUCA": ["Cali", "Buenaventura", "Palmira", "Tuluá", "Yumbo", "Buga"]
            };
            renderizarDepartamentos(selectDepto);
        });

    selectDepto.addEventListener('change', function() {
        actualizarMunicipios(this.value);
    });
}

function renderizarDepartamentos(selectElement) {
    const departamentosOrdenados = Object.keys(datosColombiaGlobal).sort();
    departamentosOrdenados.forEach(depto => {
        const option = document.createElement('option');
        option.value = depto;
        option.textContent = depto;
        selectElement.appendChild(option);
    });
    Datos_consultar();
}

function actualizarMunicipios(deptoSeleccionado) {
    const selectMuni = document.getElementById('municipio_prof');
    if (!selectMuni) return;
    selectMuni.innerHTML = '<option value="" disabled selected>Seleccione Municipio...</option>';
    if (datosColombiaGlobal[deptoSeleccionado]) {
        const municipiosOrdenados = datosColombiaGlobal[deptoSeleccionado].sort();
        municipiosOrdenados.forEach(muni => {
            const option = document.createElement('option');
            option.value = muni;
            option.textContent = muni;
            selectMuni.appendChild(option);
        });
    }
}

// =========================================================================
// 5. RESTRICCIONES EN TIEMPO REAL: BLOQUEO DE TECLAS INCORRECTAS
// =========================================================================
function aplicarRestriccionesDeEntrada() {
    const inputNombre = document.getElementById('nombres_prof');
    const inputApellido = document.getElementById('apellidos_prof');
    const inputTel = document.getElementById('telefono_prof');
    const inputEmerg = document.getElementById('telefono_emergencia_prof');
    const inputDoc = document.getElementById('numero_documento_prof');

    // FILTRO 1: Solo letras, la Ñ, tildes y espacios
    const filtrarSoloLetrasYEspacios = function() {
        this.value = this.value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]/g, '');
    };

    // FILTRO 2: Solo caracteres numéricos
    const filtrarSoloNumeros = function() {
        this.value = this.value.replace(/[^0-9]/g, '');
    };

    if (inputNombre) inputNombre.addEventListener('input', filtrarSoloLetrasYEspacios);
    if (inputApellido) inputApellido.addEventListener('input', filtrarSoloLetrasYEspacios);
    if (inputTel) inputTel.addEventListener('input', filtrarSoloNumeros);
    if (inputEmerg) inputEmerg.addEventListener('input', filtrarSoloNumeros);
    if (inputDoc) inputDoc.addEventListener('input', filtrarSoloNumeros);
}

// =========================================================================
// 6. BLINDAJE TOTAL DE LA INTERFAZ: ANTI-ESCAPES (SISTEMA DE BLOQUEO CORREGIDO)
// =========================================================================
function blindarPantallaObligatoria() {
    // Agregamos un estado inicial a la pila de navegación
    window.history.pushState(null, "", window.location.href);
    
    // Captura profunda: Cada vez que el usuario pulse "Atrás",
    // el navegador lo regresará instantáneamente a la URL actual de forma infinita
    window.addEventListener('popstate', function () {
        window.history.pushState(null, "", window.location.href);
    });

    // Alerta interceptora si intentan recargar la página o cerrar la pestaña del navegador
    window.addEventListener('beforeunload', function (e) {
        e.preventDefault();
        e.returnValue = 'Atención: Tienes datos obligatorios pendientes por guardar.';
    });

    // Desaparecer barras de navegación superiores, laterales o botones de retorno
    const navbar = document.querySelector('.navbar, .navbar-custom');
    const sidebar = document.querySelector('.sidebar') || document.getElementById('sidebar');
    const botonesVolver = document.querySelectorAll('.btn-volver, .btn-regresar, [href="/dashboard"]');

    if (navbar) navbar.style.display = 'none';
    if (sidebar) sidebar.style.display = 'none';
    botonesVolver.forEach(btn => btn.style.display = 'none');
}

// Inicialización de componentes e inyección del blindaje al cargar el script
inicializarComponentesGeograficosYEps();
    aplicarRestriccionesDeEntrada();
blindarPantallaObligatoria();