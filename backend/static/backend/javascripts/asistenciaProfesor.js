let datosCursosAsistencia = [];
let cursoSeleccionado = null;
let modulosSeleccionados = [];
let cursosAsistenciaCargados = false;

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

    contenedor.innerHTML = modulos.map(mod => `
        <div class="col-12 col-md-6">
            <div class="card card-asistencia shadow-sm p-3 border-start border-primary border-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <h6 class="fw-bold mb-0">${mod.nombre}</h6>
                        <small class="text-muted">Ver alumnos y registrar asistencia</small>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-sm btn-primary rounded-pill" onclick="verEstudiantesAsistencia(${mod.id_modulo}, '${mod.nombre.replace(/'/g, "\\'")}')">
                        <i class="bi bi-pencil-square"></i> Tomar asistencia
                    </button>
                    <button class="btn btn-sm btn-outline-secondary rounded-pill" onclick="verHistorialModulo(${mod.id_modulo}, '${mod.nombre.replace(/'/g, "\\'")}'); event.stopPropagation();">
                        <i class="bi bi-clock-history"></i> Ver asistencia
                    </button>
                </div>
            </div>
        </div>
    `).join('');
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
    const fecha = new Date(dateString);
    return isNaN(fecha.getTime()) ? null : fecha;
}

function formatDateForInput(dateString) {
    const fecha = parseDateString(dateString);
    return fecha ? fecha.toISOString().split('T')[0] : '';
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

    const hoy = new Date().toISOString().split('T')[0];
    const moduloSeleccionado = modulosSeleccionados.find(m => m.id_modulo == idModulo) || {};
    const minFecha = formatDateForInput(moduloSeleccionado.fecha_inicio) || hoy;
    const maxFecha = formatDateForInput(moduloSeleccionado.fecha_fin) || hoy;
    let fechaPredeterminada = hoy;
    if (fechaPredeterminada < minFecha) fechaPredeterminada = minFecha;
    if (fechaPredeterminada > maxFecha) fechaPredeterminada = maxFecha;

    contenedor.innerHTML = `
        <div class="col-12 mb-4">
            <div class="card border-0 shadow-sm overflow-hidden rounded-4">
                <div class="card-body p-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-12 col-md-4">
                            <label class="form-label fw-semibold">Fecha</label>
                            <input id="fecha-asistencia" type="date" class="form-control" value="${fechaPredeterminada}" min="${minFecha}" max="${maxFecha}">
                        </div>
                        <div class="col-12 col-md-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="select-all-estudiantes" onchange="toggleSeleccionTodos(this.checked)">
                                <label class="form-check-label" for="select-all-estudiantes">
                                    Marcar todos como presentes
                                </label>
                            </div>
                        </div>
                        <div class="col-12 col-md-4 text-md-end">
                            <button class="btn btn-primary rounded-pill px-4" onclick="guardarAsistencia(${idModulo})">
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
                            </tr>
                        </thead>
                        <tbody>
                            ${estudiantes.length > 0 ? estudiantes.map(est => `
                                <tr>
                                    <td class="ps-4">
                                        <select class="form-select form-select-sm asistencia-status" data-id="${est.id_usuario}" aria-label="Estado de asistencia">
                                            <option value="SI">Presente</option>
                                            <option value="NO">Ausente</option>
                                        </select>
                                    </td>
                                    <td class="fw-semibold">${est.nombres} ${est.apellidos}</td>
                                    <td>${est.correo}</td>
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
        const fechaDate = parseDateString(fecha);
        const minFechaDate = parseDateString(moduloSeleccionado.fecha_inicio);
        const maxFechaDate = parseDateString(moduloSeleccionado.fecha_fin);

        if (!fechaDate || !minFechaDate || !maxFechaDate) {
            mostrarToast('Atención', 'No se pudo validar correctamente la fecha seleccionada.', 'warning');
            return;
        }

        if (fechaDate < minFechaDate || fechaDate > maxFechaDate) {
            mostrarToast('Atención', `La fecha debe estar entre ${formatDateForInput(moduloSeleccionado.fecha_inicio)} y ${formatDateForInput(moduloSeleccionado.fecha_fin)}.`, 'warning');
            return;
        }
    }

    try {
        const yaRegistrada = await consultarAsistenciaRegistrada(idModulo, fecha);
        if (yaRegistrada) {
            mostrarToast('Aviso', 'No puedes registrar la asistencia de nuevo para esta fecha, ya fue tomada.', 'warning');
            return;
        }

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
        const maxBadges = 20; // mostrar hasta 20 registros en la fila
        const ultimos = est.asistencias.slice(0, maxBadges);
        const restantes = Math.max(0, est.asistencias.length - ultimos.length);
        const alerta = est.inasistencias > 3;
        // construir badges (limpiando hora si existe y mostrando DD/MM)
        const badgesHtml = (ultimos.length > 0 ? ultimos.map(a => {
            let fechaStr = a.fecha ? String(a.fecha).slice(0,10) : '';
            const parts = fechaStr.split('-');
            // Mostrar día/mes/año (DD/MM/YYYY) sin hora ni día de la semana
            const dayMonth = (parts.length >= 3) ? `${parts[2]}/${parts[1]}/${parts[0]}` : (fechaStr || '—');
            const asistText = (a.asistio || '').toString().toUpperCase() || 'NO';
            const badgeClass = asistText === 'SI' ? 'bg-success text-white' : 'bg-danger text-white';
            return `\n                                <span class="badge-date ${badgeClass}" title="${dayMonth}">${dayMonth}</span>\n                            `;
        }).join('') : '<small class="text-muted">Sin registros</small>') + (restantes > 0 ? ` <span class="badge bg-secondary">+${restantes}</span>` : '');

        return `
            <tr class="${alerta ? 'table-danger' : ''}">
                <td class="ps-4">
                    <div class="fw-bold">${est.nombre}</div>
                </td>
                <td class="text-center">
                    <span class="fw-bold ${est.inasistencias > 0 ? 'text-danger' : 'text-muted'}">${est.inasistencias}</span>
                </td>
                <td class="text-center">
                    ${alerta ? '<span class="badge bg-danger">Alerta de Deserción</span>' : '<span class="badge bg-success">Al día</span>'}
                </td>
                <td class="ps-4">
                    <div class="d-flex gap-1">
                        ${ultimos.length > 0 ? ultimos.map(a => {
                            const fechaStr = a.fecha ? String(a.fecha) : '';
                            const parts = fechaStr.split('-');
                            const dayMonth = (parts.length >= 3) ? `${parts[2]}/${parts[1]}` : (fechaStr || '—');
                            const asistText = (a.asistio || '').toString().toUpperCase() || 'NO';
                            const badgeClass = asistText === 'SI' ? 'bg-success text-white' : 'bg-danger text-white';
                            return `
                                <span class="badge-date ${badgeClass}" title="${fechaStr}">${dayMonth}</span>
                            `;
                        }).join('') : '<small class="text-muted">Sin registros</small>'}
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
                            <th class="text-center">Estado</th>
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
