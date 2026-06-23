let datosCursosAsistencia = [];
let cursoSeleccionado = null;
let modulosSeleccionados = [];
let cursosAsistenciaCargados = false;

function parseDateYMD(dateString) {
    if (!dateString) return null;
    const text = String(dateString).split('T')[0];
    const parts = text.split('-').map(Number);
    if (parts.length !== 3 || parts.some(isNaN)) return null;
    return new Date(parts[0], parts[1] - 1, parts[2]);
}

function isModuloVencido(modulo) {
    if (!modulo || !modulo.fecha_fin) return false;
    const fechaFin = parseDateYMD(modulo.fecha_fin);
    if (!fechaFin) return false;
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    return fechaFin < hoy;
}

console.log('[asistenciaProfesor.js] Script cargado, window.USER_ID =', window.USER_ID);

document.addEventListener('DOMContentLoaded', () => {
    const vista = document.getElementById('mostrarAsistenciaProfesor');
    if (vista) {
        console.log('[asistenciaProfesor.js] Vista de asistencia disponible en el DOM, precargando cursos');
        cargarCursosAsistencia();
    }
});

async function cargarCursosAsistencia() {
    if (cursosAsistenciaCargados) {
        console.log('[asistenciaProfesor.js] Cursos de asistencia ya cargados, omitiendo nueva petición');
        renderizarCursosAsistencia();
        return;
    }

    try {
        // Esperar hasta que USER_ID esté disponible
        let idProfesor = window.USER_ID;
        let intentos = 0;
        
        while (!idProfesor && intentos < 5) {
            await new Promise(resolve => setTimeout(resolve, 100));
            idProfesor = window.USER_ID;
            intentos++;
        }
        
        if (!idProfesor) {
            throw new Error('No se pudo obtener el ID del usuario');
        }

        console.log('Cargando cursos del profesor:', idProfesor);
        const response = await fetch(`/cursos/profesor/${idProfesor}`);
        const cursos = await response.json();

        if (!Array.isArray(cursos)) {
            throw new Error('Respuesta inesperada del servidor');
        }

        datosCursosAsistencia = cursos;
        cursosAsistenciaCargados = true;
        console.log('Cursos cargados:', cursos);
        renderizarCursosAsistencia();
    } catch (error) {
        console.error('Error al cargar cursos de asistencia:', error);
        const contenedor = document.getElementById('contenedor-asistencia');
        if (contenedor) {
            contenedor.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-danger shadow-sm">
                        Error: ${error.message}. Intenta recargar la página.
                    </div>
                </div>
            `;
        }
    }
}


function renderizarCursosAsistencia() {
    const contenedor = document.getElementById('contenedor-asistencia');
    const navContainer = document.getElementById('back-button-asistencia');

    if (!contenedor) {
        console.error('[renderizarCursosAsistencia] Contenedor no encontrado');
        return;
    }

    document.getElementById('view-title').innerText = 'Mis Cursos';
    document.getElementById('view-subtitle').innerText = 'Selecciona un curso para ver sus módulos y tomar asistencia.';
    if (navContainer) navContainer.innerHTML = '';

    if (!datosCursosAsistencia.length) {
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    No tienes cursos asignados para tomar asistencia.
                </div>
            </div>`;
        return;
    }

    contenedor.innerHTML = datosCursosAsistencia.map(curso => `
        <div class="col-12 col-md-6 col-lg-4">
            <div class="card card-asistencia shadow-sm p-4 h-100 cursor-pointer" onclick="verModulosAsistencia(${curso.id_curso}, '${curso.nombre.replace(/'/g, "\\'")}')">
                <div class="d-flex align-items-center">
                    <div class="bg-primary bg-opacity-10 text-primary p-3 rounded-circle me-3">
                        <i class="bi bi-book-half fs-3"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-0">${curso.nombre}</h5>
                        <small class="text-muted">Ver módulos y estudiantes</small>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

async function verModulosAsistencia(idCurso, nombreCurso) {
    try {
        const response = await fetch(`/modulos/curso/${idCurso}`);
        const modulos = await response.json();

        cursoSeleccionado = { id_curso: idCurso, nombre: nombreCurso };
        modulosSeleccionados = modulos;
        renderizarModulosAsistencia(nombreCurso, modulos);
    } catch (error) {
        console.error('Error al cargar módulos:', error);
        const contenedor = document.getElementById('contenedor-asistencia');
        if (contenedor) {
            contenedor.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-danger shadow-sm">
                        No se pudieron cargar los módulos. Intenta de nuevo.
                    </div>
                </div>
            `;
        }
    }
}

function renderizarModulosAsistencia(nombreCurso, modulos) {
    const contenedor = document.getElementById('contenedor-asistencia');
    const navContainer = document.getElementById('back-button-asistencia');

    document.getElementById('view-title').innerText = nombreCurso;
    document.getElementById('view-subtitle').innerText = 'Selecciona un módulo para tomar asistencia.';
    if (navContainer) {
        navContainer.innerHTML = `
            <button class="btn btn-outline-secondary rounded-pill btn-sm" onclick="renderizarCursosAsistencia()">
                <i class="bi bi-arrow-left"></i> Volver a Cursos
            </button>`;
    }

    if (!modulos.length) {
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    Este curso no tiene módulos registrados.
                </div>
            </div>`;
        return;
    }

    contenedor.innerHTML = modulos.map(mod => {
        const expirado = isModuloVencido(mod);
        const botonAsistencia = expirado
            ? `<button class="btn btn-sm btn-secondary rounded-pill" disabled><i class="bi bi-slash-circle"></i> Módulo vencido</button>`
            : `<button class="btn btn-sm btn-primary rounded-pill" onclick="verEstudiantesAsistencia(${mod.id_modulo}, '${mod.nombre.replace(/'/g, "\\'")}')">
                    <i class="bi bi-pencil-square"></i> Tomar asistencia
               </button>`;
        const badge = expirado
            ? `<span class="badge bg-danger bg-opacity-10 text-danger">Vencido</span>`
            : `<span class="badge bg-success bg-opacity-10 text-success">Activo</span>`;

        return `
        <div class="col-12 col-md-6">
            <div class="card card-asistencia shadow-sm p-3 border-start border-primary border-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <h6 class="fw-bold mb-0">${mod.nombre}</h6>
                        <small class="text-muted">Ver alumnos y registrar asistencia</small>
                    </div>
                    ${badge}
                </div>
                <div class="d-flex gap-2">
                    ${botonAsistencia}
                    <button class="btn btn-sm btn-outline-secondary rounded-pill" onclick="verHistorialModulo(${mod.id_modulo}, '${mod.nombre.replace(/'/g, "\\'")}'); event.stopPropagation();">
                        <i class="bi bi-clock-history"></i> Ver asistencia
                    </button>
                </div>
            </div>
        </div>
    `;
    }).join('');
}

async function verEstudiantesAsistencia(idModulo, nombreModulo) {
    try {
        const response = await fetch(`/modulo/${idModulo}/students`);
        const estudiantes = await response.json();
        renderizarAsistenciaEstudiantes(idModulo, nombreModulo, estudiantes);
    } catch (error) {
        console.error('Error al cargar estudiantes:', error);
        const contenedor = document.getElementById('contenedor-asistencia');
        if (contenedor) {
            contenedor.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-danger shadow-sm">
                        No se pudieron cargar los estudiantes. Intenta de nuevo.
                    </div>
                </div>
            `;
        }
    }
}

function parseDateString(dateString) {
    if (!dateString) return null;

    const texto = String(dateString).split('T')[0];
    const [year, month, day] = texto.split('-').map(Number);

    if (!year || !month || !day) {
        const fecha = new Date(dateString);
        return isNaN(fecha.getTime()) ? null : fecha;
    }

    return new Date(year, month - 1, day);
}

function formatDateLocal(date) {
    if (!date || isNaN(date.getTime())) return '';

    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    return `${year}-${month}-${day}`;
}

function formatDateForInput(dateString) {
    const fecha = parseDateString(dateString);
    return fecha ? formatDateLocal(fecha) : '';
}

function getTodayLocalString() {
    return formatDateLocal(new Date());
}

async function verHistorialModulo(idModulo, nombreModulo) {
    const contenedor = document.getElementById('contenedor-asistencia');
    const navContainer = document.getElementById('back-button-asistencia');
    document.getElementById('view-title').innerText = nombreModulo;
    document.getElementById('view-subtitle').innerText = 'Historial de asistencia del módulo';
    if (navContainer) {
        navContainer.innerHTML = `
            <button class="btn btn-outline-secondary rounded-pill btn-sm" onclick="renderizarModulosAsistencia('${cursoSeleccionado ? cursoSeleccionado.nombre.replace(/'/g, "\\'") : ''}', modulosSeleccionados)">
                <i class="bi bi-arrow-left"></i> Volver a Módulos
            </button>`;
    }

    contenedor.innerHTML = `
        <div class="col-12">
            <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Cargando...</span>
                </div>
                <p class="mt-2 text-muted">Cargando historial de asistencias...</p>
            </div>
        </div>
    `;

    try {
        const response = await fetch(`/modulo/${idModulo}/asistencias`);
        const res = await response.json();
        if (!res.success) {
            throw new Error(res.error || 'No se pudo cargar el historial de asistencia.');
        }
        contenedor.innerHTML = `<div class="col-12" id="historial-asistencia"></div>`;
        renderizarHistorialAsistencia(res.historial);
    } catch (error) {
        console.error('Error al cargar historial de asistencia:', error);
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-danger shadow-sm">
                    No se pudo cargar el historial de asistencia. Intenta de nuevo.
                </div>
            </div>
        `;
    }
}

function renderizarAsistenciaEstudiantes(idModulo, nombreModulo, estudiantes) {
    const contenedor = document.getElementById('contenedor-asistencia');
    const navContainer = document.getElementById('back-button-asistencia');

    document.getElementById('view-title').innerText = nombreModulo;
    document.getElementById('view-subtitle').innerText = 'Marca presente o ausente para cada estudiante.';
    if (navContainer) {
        navContainer.innerHTML = `
            <div class="d-flex flex-column flex-md-row gap-2 justify-content-md-end">
                <button class="btn btn-outline-secondary rounded-pill btn-sm" onclick="renderizarModulosAsistencia('${cursoSeleccionado ? cursoSeleccionado.nombre.replace(/'/g, "\\'") : ''}', modulosSeleccionados)">
                    <i class="bi bi-arrow-left"></i> Volver a Módulos
                </button>
                <button class="btn btn-outline-primary rounded-pill btn-sm" onclick="verHistorialModulo(${idModulo}, '${nombreModulo.replace(/'/g, "\\'")}');">
                    <i class="bi bi-clock-history"></i> Ver asistencia
                </button>
            </div>`;
    }

    const hoy = getTodayLocalString();
    const moduloSeleccionado = modulosSeleccionados.find(m => m.id_modulo == idModulo) || {};
    const expirado = isModuloVencido(moduloSeleccionado);
    const minFecha = formatDateForInput(moduloSeleccionado.fecha_inicio) || hoy;
    const fechaFin = parseDateString(moduloSeleccionado.fecha_fin);
    const fechaHoy = parseDateString(hoy);
    const maxFechaDate = fechaFin && fechaHoy && fechaFin < fechaHoy ? fechaFin : fechaHoy;
    const maxFecha = formatDateLocal(maxFechaDate) || hoy;

    if (minFecha > maxFecha) {
        contenedor.innerHTML = `
            <div class="col-12">
                <div class="alert alert-warning shadow-sm">
                    No hay una fecha válida para registrar asistencia en este módulo en el rango actual.
                </div>
            </div>
        `;
        return;
    }

    let fechaPredeterminada = hoy;
    if (fechaPredeterminada < minFecha) fechaPredeterminada = minFecha;
    if (fechaPredeterminada > maxFecha) fechaPredeterminada = maxFecha;
    const disabledInputs = expirado ? 'disabled' : '';
    const avisoExpirado = expirado ? `
        <div class="col-12 mb-4">
            <div class="alert alert-warning shadow-sm">
                Este módulo ya venció. No es posible registrar nuevas asistencias.
            </div>
        </div>` : '';

    contenedor.innerHTML = `
        ${avisoExpirado}
        <div class="col-12 mb-4">
            <div class="card border-0 shadow-sm overflow-hidden rounded-4">
                <div class="card-body p-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold">Fecha</label>
                            <input id="fecha-asistencia" type="date" class="form-control" value="${fechaPredeterminada}" min="${minFecha}" max="${maxFecha}" ${disabledInputs}>
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="select-all-estudiantes" onchange="toggleSeleccionTodos(this.checked)" ${disabledInputs}>
                                <label class="form-check-label" for="select-all-estudiantes">
                                    Marcar todos como presentes
                                </label>
                            </div>
                        </div>
                        <div class="col-12 col-md-4 text-md-end">
                            <button class="btn btn-primary rounded-pill px-4" onclick="guardarAsistencia(${idModulo})" ${disabledInputs}>
                                <i class="bi bi-check2-circle"></i> Registrar asistencia
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12">
            <div class="card border-0 shadow-sm overflow-hidden rounded-4">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="bg-light">
                            <tr>
                                <th class="ps-4">Estado</th>
                                <th>Nombre</th>
                                <th>Correo</th>
                                <th class="text-end">Acción</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${estudiantes.length > 0 ? estudiantes.map(est => `
                                <tr>
                                    <td class="ps-4">
                                        <select class="form-select form-select-sm asistencia-status" data-id="${est.id_usuario}" aria-label="Estado de asistencia" ${disabledInputs}>
                                            <option value="SI">Presente</option>
                                            <option value="NO">Ausente</option>
                                        </select>
                                    </td>
                                    <td class="fw-semibold">${est.nombres} ${est.apellidos}</td>
                                    <td>${est.correo}</td>
                                    <td class="text-end">
                                        <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="registrarAsistenciaIndividual(${idModulo}, ${est.id_usuario}, '${est.nombres.replace(/'/g, "\\'")} ${est.apellidos.replace(/'/g, "\\'")}', this)" ${disabledInputs}>
                                            <i class="bi bi-person-check"></i> Registrar
                                        </button>
                                    </td>
                                </tr>
                            `).join('') : `
                                <tr>
                                    <td colspan="3" class="text-center py-4 text-muted">
                                        No hay estudiantes registrados en este módulo.
                                    </td>
                                </tr>
                            `}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    `;

    // Aplicar colores de estado y listeners a los selects de asistencia
    document.querySelectorAll('.asistencia-status').forEach(select => {
        const tr = select.closest('tr');
        if (!tr) return;
        tr.classList.toggle('asistio-si', select.value === 'SI');
        tr.classList.toggle('asistio-no', select.value !== 'SI');
        select.addEventListener('change', () => {
            tr.classList.toggle('asistio-si', select.value === 'SI');
            tr.classList.toggle('asistio-no', select.value !== 'SI');
        });
    });
}

function toggleSeleccionTodos(checked) {
    document.querySelectorAll('.asistencia-status').forEach(select => {
        select.value = checked ? 'SI' : 'NO';
    });
}

async function registrarAsistenciaIndividual(idModulo, idUsuario, nombreUsuario, boton) {
    const fechaInput = document.getElementById('fecha-asistencia');
    if (!fechaInput || !fechaInput.value) {
        mostrarToast('Atención', 'Selecciona primero una fecha para registrar la asistencia.', 'warning');
        return;
    }

    const fecha = fechaInput.value;

    const selectEstudiante = document.querySelector(`.asistencia-status[data-id="${idUsuario}"]`);
    const asistio = selectEstudiante ? selectEstudiante.value : 'SI';

    const moduloSeleccionado = modulosSeleccionados.find(m => m.id_modulo == idModulo);

    if (moduloSeleccionado) {
        if (isModuloVencido(moduloSeleccionado)) {
            mostrarToast('Atención', 'Este módulo ya venció, no se puede registrar asistencia.', 'warning');
            return;
        }

        const fechaDate = parseDateString(fecha);
        const minFechaDate = parseDateString(moduloSeleccionado.fecha_inicio);
        const maxFechaDate = parseDateString(moduloSeleccionado.fecha_fin);
        const hoyDate = new Date();
        hoyDate.setHours(23, 59, 59, 999);

        if (!fechaDate || !minFechaDate || !maxFechaDate) {
            mostrarToast('Atención', 'No se pudo validar la fecha seleccionada.', 'warning');
            return;
        }

        if (fechaDate < minFechaDate || fechaDate > maxFechaDate) {
            mostrarToast('Atención', 'La fecha debe estar dentro del rango del módulo.', 'warning');
            return;
        }

        if (fechaDate > hoyDate) {
            mostrarToast('Atención', 'Solo puedes registrar asistencia del día actual o de fechas pasadas.', 'warning');
            return;
        }
    }

    if (boton) {
        boton.disabled = true;
        boton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Registrando...';
    }

    try {
        const response = await fetch('/asistencia/registrar', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                id_modulo: idModulo,
                asistencias: [{ 
                    id_usuario: Number(idUsuario), 
                    asistio: asistio   
                }],
                fecha: fecha
            })
        });

        const res = await response.json();

        if (res.success) {
            mostrarToast('Éxito', `Asistencia registrada para ${nombreUsuario} como ${asistio === 'SI' ? 'Presente' : 'Ausente'}.`, 'success');
            verEstudiantesAsistencia(idModulo, moduloSeleccionado?.nombre || 'Módulo');
        } else {
            mostrarToast('Error', res.error || 'No se pudo registrar la asistencia.', 'danger');
        }
    } catch (error) {
        console.error(error);
        mostrarToast('Error', 'No se pudo registrar la asistencia individual.', 'danger');
    } finally {
        if (boton) {
            boton.disabled = false;
            boton.innerHTML = '<i class="bi bi-person-check"></i> Registrar';
        }
    }
}

async function guardarAsistencia(idModulo) {
    const fechaInput = document.getElementById('fecha-asistencia');
    if (!fechaInput) return;

    const fecha = fechaInput.value;
    if (!fecha) {
        mostrarToast('Atención', 'Selecciona una fecha para registrar la asistencia.', 'warning');
        return;
    }

    const asistenciaEstudiantes = Array.from(document.querySelectorAll('.asistencia-status')).map(select => ({
        id_usuario: Number(select.dataset.id),
        asistio: select.value === 'SI' ? 'SI' : 'NO'
    }));

    if (!asistenciaEstudiantes.length) {
        mostrarToast('Atención', 'No hay estudiantes disponibles para registrar asistencia.', 'warning');
        return;
    }

    const moduloSeleccionado = modulosSeleccionados.find(m => m.id_modulo == idModulo);
    if (moduloSeleccionado) {
        if (isModuloVencido(moduloSeleccionado)) {
            mostrarToast('Atención', 'Este módulo ya venció, no se puede registrar asistencia.', 'warning');
            return;
        }

        const fechaDate = parseDateString(fecha);
        const minFechaDate = parseDateString(moduloSeleccionado.fecha_inicio);
        const maxFechaDate = parseDateString(moduloSeleccionado.fecha_fin);
        const hoyDate = new Date();
        hoyDate.setHours(23, 59, 59, 999);

        if (!fechaDate || !minFechaDate || !maxFechaDate) {
            mostrarToast('Atención', 'No se pudo validar correctamente la fecha seleccionada.', 'warning');
            return;
        }

        if (fechaDate < minFechaDate || fechaDate > maxFechaDate) {
            mostrarToast('Atención', `La fecha debe estar entre ${formatDateForInput(moduloSeleccionado.fecha_inicio)} y ${formatDateForInput(moduloSeleccionado.fecha_fin)}.`, 'warning');
            return;
        }

        if (fechaDate > hoyDate) {
            mostrarToast('Atención', 'Solo puedes registrar asistencia del día actual o de fechas pasadas.', 'warning');
            return;
        }
    }

    try {
        const response = await fetch('/asistencia/registrar', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                id_modulo: idModulo,
                asistencias: asistenciaEstudiantes,
                fecha: fecha
            })
        });

        const res = await response.json();
        if (res.success) {
            mostrarToast('Éxito', 'Asistencia registrada correctamente.', 'success');
            renderizarCursosAsistencia();
        } else {
            mostrarToast('Error', res.error || 'Error al guardar la asistencia.', 'danger');
        }
    } catch (error) {
        console.error('Error al guardar asistencia:', error);
        mostrarToast('Error', 'No se pudo guardar la asistencia. Revisa la consola para más detalles.', 'danger');
    }
}

async function consultarAsistenciaRegistrada(idModulo, fecha) {
    try {
        const response = await fetch(`/modulo/${idModulo}/asistencia?fecha=${encodeURIComponent(fecha)}`);
        const res = await response.json();
        return res.success && res.registrada;
    } catch (error) {
        console.error('Error verificando asistencia existente:', error);
        return false;
    }
}

async function cargarHistorialAsistencia(idModulo) {
    try {
        const response = await fetch(`/modulo/${idModulo}/asistencias`);
        const res = await response.json();
        if (!res.success) {
            throw new Error(res.error || 'No se pudo cargar el historial de asistencia.');
        }
        renderizarHistorialAsistencia(res.historial);
    } catch (error) {
        console.error('Error cargando historial de asistencia:', error);
        const historialContainer = document.getElementById('historial-asistencia');
        if (historialContainer) {
            historialContainer.innerHTML = `
                <div class="alert alert-warning shadow-sm">
                    No se pudo cargar el historial de asistencia. Intenta nuevamente.
                </div>
            `;
        }
    }
}

function renderizarHistorialAsistencia(historial) {
    const historialContainer = document.getElementById('historial-asistencia');
    if (!historialContainer) return;

    if (!historial || historial.length === 0) {
        historialContainer.innerHTML = `
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <div class="text-muted">Aún no hay historial de asistencia para este módulo.</div>
            </div>
        `;
        return;
    }

    // Helper para obtener campos con varios posibles nombres
    function getField(obj, keys) {
        for (const k of keys) {
            if (obj[k] !== undefined && obj[k] !== null) return obj[k];
        }
        return null;
    }

    // Agrupar por estudiante y calcular métricas similares a la vista admin
    const alumnos = {};
    historial.forEach(item => {
        const nombre = getField(item, ['estudiante', 'nombre']) || (`Usuario ${getField(item, ['id_usuario']) || ''}`);
        const fechaVal = getField(item, ['fecha', 'date', 'fecha_registro']);
        const asistioVal = getField(item, ['asistio', 'asistió', 'asistencia']) || 'NO';

        if (!alumnos[nombre]) alumnos[nombre] = { id_usuario: getField(item, ['id_usuario']), nombre: nombre, asistencias: [], inasistencias: 0 };
        alumnos[nombre].asistencias.push({ fecha: fechaVal ? String(fechaVal) : null, asistio: String(asistioVal) });
        if ((asistioVal + '').toUpperCase() !== 'SI') alumnos[nombre].inasistencias += 1;
    });

    const rows = Object.values(alumnos).map(est => {
        // ordenar registros por fecha desc (más recientes primero)
        est.asistencias.sort((a,b) => (b.fecha || '').localeCompare(a.fecha || ''));
        const visibles = est.asistencias;
        const alerta = est.inasistencias > 3;
        const presentes = est.asistencias.filter(a => (a.asistio || '').toString().toUpperCase() === 'SI').length;
        const rowKey = (est.id_usuario ?? est.nombre).toString().replace(/[^a-zA-Z0-9_-]/g, '_');

        const renderBadges = (lista) => (lista.length > 0 ? lista.map(a => {
            const fechaStr = a.fecha ? String(a.fecha).slice(0, 10) : '';
            const parts = fechaStr.split('-');
            const dayMonth = (parts.length >= 3) ? `${parts[2]}/${parts[1]}` : (fechaStr || '—');
            const asistText = (a.asistio || '').toString().toUpperCase() || 'NO';
            const badgeClass = asistText === 'SI' ? 'bg-success text-white' : 'bg-danger text-white';
            return `<span class="badge-date ${badgeClass}" title="${fechaStr || dayMonth}">${dayMonth}</span>`;
        }).join('') : '<small class="text-muted">Sin registros</small>');

        return `
            <tr class="${alerta ? 'table-danger' : ''}">
                <td class="ps-4">
                    <div class="fw-bold">${est.nombre}</div>
                </td>
                <td class="text-center">
                    <span class="fw-bold ${est.inasistencias > 0 ? 'text-danger' : 'text-muted'}">${est.inasistencias}</span>
                </td>
                <td class="text-center">
                    <span class="fw-bold ${presentes > 0 ? 'text-success' : 'text-muted'}">${presentes} </span>
                </td>
                <td class="ps-4">
                    <div class="historial-stack">
                        <div class="historial-scroll">
                            <div class="historial-badges">${renderBadges(visibles)}</div>
                        </div>
                    </div>
                </td>
            </tr>
        `;
    }).join('');

    historialContainer.innerHTML = `
        <div class="card border-0 shadow-sm rounded-4 p-4">
            <h5 class="fw-semibold mb-3">Historial de asistencias</h5>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th class="ps-4">Estudiante</th>
                            <th class="text-center">Total Faltas</th>
                            <th class="text-center">Total Asistencias</th>
                            <th class="ps-4">Últimos Registros</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${rows}
                    </tbody>
                </table>
            </div>
        </div>
    `;
}

function mostrarToast(titulo, mensaje, tipo = 'primary') {
    let toastContainer = document.getElementById('toastContainer');
    if (!toastContainer) {
        toastContainer = document.createElement('div');
        toastContainer.id = 'toastContainer';
        toastContainer.className = 'toast-container position-fixed bottom-0 end-0 p-3';
        document.body.appendChild(toastContainer);
    }

    const toastEl = document.createElement('div');
    toastEl.className = `toast align-items-center text-bg-${tipo} border-0 mb-2 shadow`;
    toastEl.setAttribute('role', 'alert');
    toastEl.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">
                <strong>${titulo}</strong><br>
                <span>${mensaje}</span>
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    `;

    toastContainer.appendChild(toastEl);
    const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
    toast.show();
    toastEl.addEventListener('hidden.bs.toast', () => toastEl.remove());
}

// Observador para detectar cuando la vista de asistencia se vuelve visible
(function observarVistaAsistencia() {
    const vista = document.getElementById('mostrarAsistenciaProfesor');
    if (!vista) {
        console.warn('[asistenciaProfesor.js] No se encontró el contenedor mostrarAsistenciaProfesor');
        return;
    }

    const observer = new MutationObserver(() => {
        const estilo = window.getComputedStyle(vista);
        if (estilo.display !== 'none') {
            console.log('[asistenciaProfesor.js] Vista de asistencia visible, cargando cursos...');
            observer.disconnect();
            if (typeof cargarCursosAsistencia === 'function') {
                cargarCursosAsistencia();
            }
        }
    });

    observer.observe(vista, { attributes: true, attributeFilter: ['style', 'class'] });
})();
