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
            .then(responseJson => { 
                console.log(responseJson);
                
                // Si la respuesta fue exitosa, extraemos el objeto interno 'data'
                if (responseJson.status === "success" && responseJson.data) {
                    const data = responseJson.data; 

                    // Pintar elementos de texto dinámicos en la tarjeta lateral
                    document.getElementById('nombreCompletoProfesorVista').textContent = `${data.nombres || ''} ${data.apellidos || ''}`;
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
                    
                    // --- PRESELECCIÓN DE GEOLOCALIZACIÓN SI YA TIENE DATOS ---
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
                    
                    // --- PRESELECCIÓN DE EPS SI YA TIENE DATOS ---
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
        btnCerrar.classList.add('btn-close-white'); 
    } 
    else if (tipo === 'advertencia') {
        header.style.backgroundColor = "#fff3cd";
        header.style.color = "#664d03";
        body.classList.add('bg-warning', 'text-dark'); 
        icono.classList.add('bi-exclamation-triangle-fill');
        btnCerrar.className = "btn-close"; 
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
    const inputTelefono = document.getElementById('telefono_prof');
    const inputEmergencia = document.getElementById('telefono_emergencia_prof');

    // Limpiamos estilos de errores anteriores en los teléfonos antes de validar de nuevo
    inputTelefono.classList.remove('is-invalid');
    inputEmergencia.classList.remove('is-invalid');

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
        departamento: document.getElementById('departamento_prof').value,
        municipio: document.getElementById('municipio_prof').value,
        direccion: document.getElementById('direccion_prof').value.trim(),
        telefono: inputTelefono.value.trim(),
        telefono_emergencia: inputEmergencia.value.trim(),
        estrato: document.getElementById('estrato_prof').value,
        eps: document.getElementById('eps_prof').value
    };

    // REGLA 1: Validación de campos vacíos obligatorios -> Toast Amarillo
    for (const campo in inputs) {
        if (!inputs[campo] || inputs[campo] === "") {
            mostrarToast('Advertencia', 'Todos los datos personales y de cuenta son obligatorios.', 'advertencia');
            return; 
        }
    }

    // --- VALIDACIÓN ESTRUCTURAL DE TELÉFONOS (COLOMBIA) ---
    let hayErrorTelefono = false;

    // Validar teléfono personal (10 dígitos y que empiece por 3)
    if (inputs.telefono.length !== 10 || !inputs.telefono.startsWith('3')) {
        inputTelefono.classList.add('is-invalid');
        hayErrorTelefono = true;
    }

    // Validar teléfono de emergencia (10 dígitos y que empiece por 3)
    if (inputs.telefono_emergencia.length !== 10 || !inputs.telefono_emergencia.startsWith('3')) {
        inputEmergencia.classList.add('is-invalid');
        hayErrorTelefono = true;
    }

    // Si alguno falló la regla, detenemos el flujo y mostramos advertencia informativa
    if (hayErrorTelefono) {
        mostrarToast('Advertencia', 'Por favor corrige los números de teléfono resaltados en rojo.', 'advertencia');
        return;
    }

    // REGLA 2: Bloqueo de números telefónicos idénticos -> Toast Amarillo
    if (inputs.telefono === inputs.telefono_emergencia) {
        mostrarToast('Advertencia', 'El número de teléfono personal no puede ser idéntico al de emergencia.', 'advertencia');
        return; 
    }

    // Petición asíncrona hacia el Backend en Flask
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
            mostrarToast('Éxito', 'Perfil actualizado exitosamente. Cerrando sesión...', 'exito');
            setTimeout(() => {
                window.location.href = '/logout';
            }, 2500);
        } else {
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

// =========================================================================
// 4. LOGICA DE CARGA DINÁMICA DE DEPARTAMENTOS, MUNICIPIOS Y EPS
// =========================================================================
let datosColombiaGlobal = {};

const listadoEpsColombia = [
    "EPS SURA",
    "EPS SANITAS",
    "SALUD TOTAL EPS",
    "NUEVA EPS",
    "COMPENSAR EPS",
    "COOSALUD EPS",
    "MUTUAL SER EPS",
    "FAMISANAR EPS",
    "ALIANSALUD EPS",
    "SAVIA SALUD EPS",
    "EMSSANAR EPS",
    "CAPRESOCA EPS",
    "ASMET SALUD EPS",
    "ANAS WAYUU EPSI",
    "MALLAMAS EPSI",
    "PIJAOS SALUD EPSI",
    "SALUD MIA EPS"
];

function inicializarComponentesGeograficosYEps() {
    const selectDepto = document.getElementById('departamento_prof');
    const selectEps = document.getElementById('eps_prof');
    
    if (!selectDepto || !selectEps) return;

    // 1. CARGAR EL SELECT DE EPS
    listadoEpsColombia.sort().forEach(eps => {
        const option = document.createElement('option');
        option.value = eps;
        option.textContent = eps;
        selectEps.appendChild(option);
    });

    // 2. CARGAR DEPARTAMENTOS Y MUNICIPIOS DESDE LA API
    fetch('https://datos.gov.co/resource/82di-kkh9.json?$select=dpto,nom_mpio&$limit=5000')
        .then(response => response.json())
        .then(data => {
            if (!Array.isArray(data) || data.length === 0) throw new Error("Estructura vacía");
            
            data.forEach(item => {
                const depto = item.dpto;
                const muni = item.nom_mpio;

                if (depto && muni) {
                    if (!datosColombiaGlobal[depto]) {
                        datosColombiaGlobal[depto] = [];
                    }
                    if (!datosColombiaGlobal[depto].includes(muni)) {
                        datosColombiaGlobal[depto].push(muni);
                    }
                }
            });
            renderizarDepartamentos(selectDepto);
        })
        .catch(error => {
            console.warn("Fallo de API externa. Cargando listado geográfico local de contingencia...", error);
            datosColombiaGlobal = {
                "AMAZONAS": ["Leticia", "Puerto Nariño"],
                "ANTIOQUIA": ["Medellín", "Bello", "Envigado", "Itagüí", "Rionegro", "Apartadó", "Caucasia", "Turbo"],
                "ARAUCA": ["Arauca", "Arauquita", "Saravena", "Tame"],
                "ATLANTICO": ["Barranquilla", "Soledad", "Malambo", "Sabanalarga", "Baranoa", "Puerto Colombia"],
                "BOLIVAR": ["Cartagena de Indias", "Magangué", "Turbaco", "El Carmen de Bolívar", "Mompós"],
                "BOYACA": ["Tunja", "Duitama", "Sogamoso", "Chiquinquirá", "Puerto Boyáca", "Paipa"],
                "CALDAS": ["Manizales", "La Dorada", "Riosucio", "Chinchiná", "Villamaría"],
                "CAQUETA": ["Florencia", "San Vicente del Caguán", "Puerto Rico", "Belén de los Andaquíes"],
                "CASANARE": ["Yopal", "Aguazul", "Villanueva", "Paz de Ariporo"],
                "CAUCA": ["Popayán", "Santander de Quilichao", "Puerto Tejada", "Patía", "Silvia"],
                "CESAR": ["Valledupar", "Aguachica", "Agustín Codazzi", "Bosconia", "El Copey"],
                "CHOCO": ["Quibdó", "Istmina", "Condoto", "Acandí", "Bahía Solano"],
                "CORDOBA": ["Montería", "Cereté", "Lorica", "Sahagún", "Montelíbano", "Planeta Rica"],
                "CUNDINAMARCA": ["Bogotá D.C.", "Soacha", "Facatativá", "Chía", "Zipaquirá", "Girardot", "Fusagasugá"],
                "GUAINIA": ["Inírida"],
                "GUAVIARE": ["San José del Guaviare", "Calamar", "El Retorno"],
                "HUILA": ["Neiva", "Pitalito", "Garzón", "La Plata", "Campoalegre"],
                "LA GUAJIRA": ["Riohacha", "Maicao", "Uribia", "San Juan del Cesar", "Fonseca"],
                "MAGDALENA": ["Santa Marta", "Ciénaga", "Fundación", "El Banco", "Plato"],
                "META": ["Villavicencio", "Acacías", "Granada", "Puerto López", "San Martín"],
                "NARIÑO": ["Pasto", "Tumaco", "Ipiales", "Túquerres", "La Unión"],
                "NORTE DE SANTANDER": ["Cúcuta", "Ocaña", "Pamplona", "Villa del Rosario", "Los Patios", "Tibú"],
                "PUTUMAYO": ["Mocoa", "Puerto Asís", "Orito", "Sibundoy", "Valle del Guamuez"],
                "QUINDIO": ["Armenia", "Calarcá", "Dosquebradas", "Montenegro", "Quimbaya"],
                "RISARALDA": ["Pereira", "Dosquebradas", "Santa Rosa de Cabal", "La Virginia"],
                "SAN ANDRES Y PROVIDENCIA": ["San Andrés", "Providencia"],
                "SANTANDER": ["Bucaramanga", "Floridablanca", "Girón", "Piedecuesta", "Barrancabermeja", "San Gil"],
                "SUCRE": ["Sincelejo", "Corozal", "San Marcos", "Tolú", "Sampués"],
                "TOLIMA": ["Ibagué", "Espinal", "Melgar", "Mariquita", "Honda", "Líbano"],
                "VALLE DEL CAUCA": ["Cali", "Buenaventura", "Palmira", "Tuluá", "Yumbo", "Cartago", "Buga", "Jamundí"],
                "VAUPES": ["Mitú"],
                "VICHADA": ["Puerto Carreño", "Santa Rosalía"]
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
    
    // Ejecutamos la consulta inicial de datos de usuario guardados
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

// Inicializar todos los componentes dinámicos de geolocalización y EPS
inicializarComponentesGeograficosYEps();