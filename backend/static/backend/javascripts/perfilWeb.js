document.addEventListener('DOMContentLoaded', () => {
    cargarDatosColombiaDesdeAPI().then(() => {
        cargarDatosPerfil();
    });
});

let departamentosMap = {};

// ==================== CARGAR DEPARTAMENTOS + EPS ====================
async function cargarDatosColombiaDesdeAPI() {
    try {
        const depRes = await fetch('https://api-colombia.com/api/v1/Department');
        const departamentos = await depRes.json();

        const depSelect = document.getElementById('departamento_admin');
        depSelect.innerHTML = '<option value="" disabled selected>Seleccione Departamento...</option>';

        departamentos.sort((a, b) => a.name.localeCompare(b.name)).forEach(dep => {
            departamentosMap[dep.name.toUpperCase()] = dep.id;
            const opt = document.createElement('option');
            opt.value = dep.name;
            opt.textContent = dep.name;
            depSelect.appendChild(opt);
        });

        // EPS
        const epsList = [
            "EPS SURA", "Salud Total", "Compensar", "Sanitas", "Famisanar", "Nueva EPS",
            "Coomeva", "Medimás", "Aliansalud", "SOS", "Mutual Ser", "Capital Salud",
            "Ecoopsos", "Ferrocor", "Savia Salud", "Coosalud", "Emssanar", "Ambuq"
        ];
        
        const epsSelect = document.getElementById('eps_admin');
        epsSelect.innerHTML = '<option value="" disabled selected>Seleccione EPS...</option>';
        epsList.forEach(eps => {
            const opt = document.createElement('option');
            opt.value = eps;
            opt.textContent = eps;
            epsSelect.appendChild(opt);
        });

    } catch (error) {
        console.error("Error API:", error);
        crearNotificacionNativa('Error', 'No se pudieron cargar los departamentos.', 'error');
    }
}

// ==================== CARGAR MUNICIPIOS ====================
async function cargarMunicipios() {
    const depNombre = document.getElementById('departamento_admin').value;
    const munSelect = document.getElementById('municipio_admin');
    munSelect.innerHTML = '<option value="" disabled selected>Seleccione Municipio...</option>';

    if (!depNombre) return;

    try {
        const idDep = departamentosMap[depNombre.toUpperCase()];
        if (!idDep) return;

        const res = await fetch(`https://api-colombia.com/api/v1/Department/${idDep}/cities`);
        const municipios = await res.json();

        municipios.sort((a, b) => a.name.localeCompare(b.name)).forEach(mun => {
            const opt = document.createElement('option');
            opt.value = mun.name;
            opt.textContent = mun.name;
            munSelect.appendChild(opt);
        });
    } catch (error) {
        console.error(error);
    }
}

// ==================== CARGAR DATOS DEL PERFIL ====================
function cargarDatosPerfil() {
    if (!window.usuarioAdmin || !window.usuarioAdmin.id_usuario) {
        crearNotificacionNativa('Error Crítico', 'No se detectó la sesión del usuario.', 'error');
        return;
    }

    fetch(`/api/perfil-datos?id_usuario=${window.usuarioAdmin.id_usuario}`)
        .then(response => response.json())
        .then(res => {
            if (res.status !== 'success') return;

            const user = res.data;

            // === ROL (Corregido y reforzado) ===
            const rolTexto = user.nombre_rol || user.rol || 'USUARIO';
            document.getElementById('rolAdminVista').textContent = rolTexto.toUpperCase();
            document.getElementById('rol_admin').value = rolTexto.toUpperCase();

            // Cabecera y avatar
            document.getElementById('avatarLetra').textContent = user.nombres ? user.nombres[0].toUpperCase() : 'A';
            document.getElementById('nombreCompletoAdminVista').textContent = `${user.nombres || ''} ${user.apellidos || ''}`;

            // Estado
            const badge = document.getElementById('estadoAdminVista');
            badge.textContent = `Estado: ${user.estado || 'Pendiente'}`;
            badge.className = `badge rounded-pill px-3 py-2 fs-6 ${user.estado === 'Activo' ? 'bg-success' : user.estado === 'Inactivo' ? 'bg-danger' : 'bg-secondary'}`;

            // Rellenar demás campos
            document.getElementById('id_usuario_admin').value = user.id_usuario || '';
            document.getElementById('nombres_admin').value = user.nombres || '';
            document.getElementById('apellidos_admin').value = user.apellidos || '';
            document.getElementById('correo_admin').value = user.correo || '';
            document.getElementById('fecha_nacimiento_admin').value = user.fecha_nacimiento || '';
            document.getElementById('sexo_admin').value = user.Sexo || '';
            document.getElementById('numero_documento_admin').value = user.numero_documento || '';
            document.getElementById('tipo_documento_admin').value = user.tipo_documento || '';
            document.getElementById('direccion_admin').value = user.direccion || '';
            document.getElementById('telefono_admin').value = user.telefono || '';
            document.getElementById('telefono_emergencia_admin').value = user.telefono_emergencia || '';
            document.getElementById('estrato_admin').value = user.Estrato || '';

            // Departamento, Municipio y EPS
            if (user.departamento) {
                const depSelect = document.getElementById('departamento_admin');
                for (let opt of depSelect.options) {
                    if (opt.value.toUpperCase() === user.departamento.toUpperCase()) {
                        depSelect.value = opt.value;
                        break;
                    }
                }

                setTimeout(() => {
                    cargarMunicipios().then(() => {
                        if (user.municipio) {
                            const munSelect = document.getElementById('municipio_admin');
                            for (let opt of munSelect.options) {
                                if (opt.value.toUpperCase() === user.municipio.toUpperCase()) {
                                    munSelect.value = opt.value;
                                    break;
                                }
                            }
                        }
                    });
                }, 400);
            }

            if (user.eps) {
                const epsSelect = document.getElementById('eps_admin');
                for (let opt of epsSelect.options) {
                    if (opt.value.toUpperCase() === user.eps.toUpperCase()) {
                        epsSelect.value = opt.value;
                        break;
                    }
                }
            }

            agregarValidaciones();
        })
        .catch(err => {
            console.error(err);
            crearNotificacionNativa('Error', 'No se pudo cargar el perfil.', 'error');
        });
}

// ==================== VALIDACIONES ====================
function agregarValidaciones() {
    ['nombres_admin', 'apellidos_admin'].forEach(id => {
        const input = document.getElementById(id);
        input.addEventListener('input', () => {
            input.value = input.value.replace(/[^a-zA-ZáéíóúñÁÉÍÓÚÑ\s]/g, '');
        });
    });

    ['telefono_admin', 'telefono_emergencia_admin'].forEach(id => {
        const input = document.getElementById(id);
        input.addEventListener('input', () => {
            input.value = input.value.replace(/[^0-9]/g, '');
            if (input.value.length > 0 && !input.value.startsWith('3')) {
                input.value = '3' + input.value.slice(1);
            }
            if (input.value.length > 10) input.value = input.value.slice(0, 10);
        });
    });
}

// ==================== GUARDAR ====================
function guardarPerfilweb() {
    const get = id => document.getElementById(id).value.trim();

    if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(get('nombres_admin'))) return crearNotificacionNativa('Error', 'Nombres solo letras', 'warning');
    if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(get('apellidos_admin'))) return crearNotificacionNativa('Error', 'Apellidos solo letras', 'warning');

    const edad = new Date().getFullYear() - new Date(get('fecha_nacimiento_admin')).getFullYear();
    if (edad < 16) return crearNotificacionNativa('Error', 'Mínimo 16 años', 'warning');

    const tel = get('telefono_admin');
    const telEmer = get('telefono_emergencia_admin');
    if (!/^3\d{9}$/.test(tel) || !/^3\d{9}$/.test(telEmer)) return crearNotificacionNativa('Error', 'Teléfonos inválidos', 'warning');
    if (tel === telEmer) return crearNotificacionNativa('Error', 'Teléfonos no pueden ser iguales', 'warning');

    const nuevaClave = document.getElementById('nueva_clave_admin').value;
    if (nuevaClave.length > 0 && nuevaClave.length < 7) return crearNotificacionNativa('Error', 'Contraseña mínimo 7 caracteres', 'warning');

    const payload = {
        id_usuario: window.usuarioAdmin.id_usuario,
        rol_usuario: window.usuarioAdmin.rol,
        nombres: get('nombres_admin'),
        apellidos: get('apellidos_admin'),
        correo: get('correo_admin'),
        fecha_nacimiento: get('fecha_nacimiento_admin'),
        sexo: get('sexo_admin'),
        tipo_documento: get('tipo_documento_admin'),
        numero_documento: get('numero_documento_admin'),
        departamento: get('departamento_admin'),
        municipio: get('municipio_admin'),
        direccion: get('direccion_admin'),
        telefono: tel,
        telefono_emergencia: telEmer,
        estrato: get('estrato_admin'),
        eps: get('eps_admin'),
        nueva_clave: nuevaClave
    };

    fetch('/api/perfil-guardar-web', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(r => r.json())
    .then(res => {
        if (res.status === 'success') {
            crearNotificacionNativa('¡Éxito!', 'Perfil actualizado correctamente.', 'success');
            document.getElementById('nueva_clave_admin').value = '';
            cargarDatosPerfil();
        } else {
            crearNotificacionNativa('Error', res.message || 'No se pudo guardar', 'error');
        }
    })
    .catch(() => crearNotificacionNativa('Error', 'Error de conexión', 'error'));
}

// ==================== NOTIFICACIONES ====================
function crearNotificacionNativa(titulo, mensaje, tipo = 'success') {
    let cont = document.getElementById('contenedor-notificaciones-nativas');
    if (!cont) {
        cont = document.createElement('div');
        cont.id = 'contenedor-notificaciones-nativas';
        cont.style.cssText = 'position:fixed;bottom:20px;right:20px;z-index:99999;display:flex;flex-direction:column;gap:10px;max-width:350px;';
        document.body.appendChild(cont);
    }

    let bg = '#198754', color = '#fff', icon = '✓';
    if (tipo === 'error') { bg = '#dc3545'; icon = '✕'; }
    if (tipo === 'warning') { bg = '#ffc107'; color = '#212529'; icon = '⚠'; }

    const div = document.createElement('div');
    div.style.cssText = `background:${bg};color:${color};padding:16px;border-radius:12px;box-shadow:0 10px 15px -3px rgba(0,0,0,0.1);display:flex;gap:12px;`;
    div.innerHTML = `
        <div style="font-size:1.3rem;font-weight:bold;">${icon}</div>
        <div style="flex:1"><h5 style="margin:0 0 4px">${titulo}</h5><p style="margin:0;font-size:0.85rem">${mensaje}</p></div>
        <button style="background:none;border:none;color:${color};cursor:pointer" onclick="this.parentElement.remove()">✕</button>
    `;
    cont.appendChild(div);
    setTimeout(() => div.remove(), 4500);
}