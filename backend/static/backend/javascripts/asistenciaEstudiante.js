function formatearFechaAsistencia(fecha) {
    if (fecha === null || fecha === undefined || fecha === '') {
        return 'Sin fecha registrada';
    }

    const texto = String(fecha).trim();
    if (!texto) {
        return 'Sin fecha registrada';
    }

    // Formato típico de MySQL: YYYY-MM-DD
    const coincidencia = texto.match(/(\d{4})[-/](\d{1,2})[-/](\d{1,2})/);
    if (coincidencia) {
        const [, anio, mes, dia] = coincidencia;
        return `${String(dia).padStart(2, '0')}/${String(mes).padStart(2, '0')}/${anio}`;
    }

    // Soporte para objetos Date o cadenas como 'Tue Jun 09 2026 ...'
    const fechaDate = fecha instanceof Date ? fecha : new Date(texto);
    if (!Number.isNaN(fechaDate.getTime())) {
        return new Intl.DateTimeFormat('es-ES', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            timeZone: 'UTC'
        }).format(fechaDate);
    }

    // Fallback seguro: quitar cualquier hora y dejar solo la parte de fecha si existe.
    const fechaLimpia = texto.includes('T') ? texto.split('T')[0] : texto.split(' ')[0];
    return fechaLimpia || 'Sin fecha registrada';
}

// =========================================================================
// 1. FUNCIÓN: DETALLE INDIVIDUAL POR MÓDULO (Estructura de Tabla Estilizada)
// =========================================================================
async function verAsistencia(idModulo, nombreModulo){
    const seccionTabla = document.getElementById("seccionTablaModulo");
    const titulo = document.getElementById("tituloModulo");
    const tabla = document.getElementById("tablaAsistencia");

    if (seccionTabla) seccionTabla.classList.remove('d-none');
    if (titulo) titulo.innerHTML = `Asistencias - ${nombreModulo}`;

    if (tabla) {
        tabla.innerHTML = `
            <tr>
                <td colspan="3" class="text-center py-4 text-muted">
                    <div class="spinner-border spinner-border-sm text-secondary me-2" role="status"></div>
                    Consultando registros del módulo...
                </td>
            </tr>
        `;
    }

    try{
        const response = await fetch(`/asistencia/modulo/${idModulo}`);
        const data = await response.json();

        if(!tabla) return;

        if(data.length === 0){
            tabla.innerHTML = `
                <tr>
                    <td colspan="3" class="text-center text-muted py-4 fs-6">
                        No hay asistencias registradas para este módulo.
                    </td>
                </tr>
            `;
            return;
        }

        tabla.innerHTML = "";

        data.forEach(asistencia => {
            const estadoAsistencia = String(asistencia.asistio).toUpperCase();
            const estadoClase = estadoAsistencia === "SI" ? "estado-asistio" : "estado-falta";
            const textoEstado = estadoAsistencia === "SI" ? "ASISTIÓ" : "INASISTENCIA";
            
            const fechaLimpia = formatearFechaAsistencia(asistencia.fecha);

            tabla.innerHTML += `
                <tr>
                    <td class="fw-bold text-dark py-3 ps-4" style="letter-spacing: 0.2px;">${fechaLimpia}</td>
                    <td>
                        <span class="${estadoClase}">
                            ${textoEstado}
                        </span>
                    </td>
                    <td class="text-muted pe-4 fs-7">
                        ${asistencia.observacion || '-'}
                    </td>
                </tr>
            `;
        });

    }catch(error){
        if (tabla) {
            tabla.innerHTML = `
                <tr>
                    <td colspan="3" class="text-danger text-center py-4 fw-bold">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> Error al cargar las asistencias.
                    </td>
                </tr>
            `;
        }
        console.error("Fallo en la consulta por módulo:", error);
    }
}

// =========================================================================
// 2. FUNCIÓN: VISTA GENERAL EN ACORDEÓN (Separado, Espaciado y Responsive)
// =========================================================================
async function cargarAsistenciasEstudiante() {
    const contenedor = document.getElementById('accordionAsistencia');
    const placeholder = document.getElementById('asistenciaCargandoPlaceholder');

    if (!contenedor) {
        console.error('No se encontró el contenedor de asistencias.');
        return;
    }

    if (placeholder) {
        placeholder.style.display = 'block';
    }

    contenedor.innerHTML = '';

    try {
        const response = await fetch(`/asistencias/${window.USER_ID}`);
        if (!response.ok) {
            throw new Error('Error al obtener las asistencias.');
        }

        const data = await response.json();
        const asistencias = Array.isArray(data.asistencias) ? data.asistencias : [];
        const resumen = document.getElementById('resumenAsistenciaEstudiante');

        if (resumen) {
            const total = asistencias.length;
            const presentes = asistencias.filter(r => String(r.asistio).toUpperCase() === 'SI').length;
            const faltas = total - presentes;
            const porcentaje = total ? Math.round((presentes / total) * 100) : 0;

            resumen.innerHTML = `
                <div class="col-12 col-md-6 col-xl-6">
                    <article class="card-stat h-100">
                        <div class="card-stat-inner">
                            <div class="icon-box bg-primary bg-opacity-10 text-primary"><i class="bi bi-journal-text"></i></div>
                            <div class="card-stat-copy">
                                <small class="text-uppercase text-primary fw-bold">Clases registradas</small>
                                <h2 class="mt-2 mb-1">${total}</h2>
                                <p class="text-muted small mb-0">Total de registros en tu historial.</p>
                            </div>
                        </div>
                    </article>
                </div>
                <div class="col-12 col-md-6 col-xl-6">
                    <article class="card-stat h-100">
                        <div class="card-stat-inner">
                            <div class="icon-box bg-success bg-opacity-10 text-success"><i class="bi bi-check-circle-fill"></i></div>
                            <div class="card-stat-copy">
                                <small class="text-uppercase text-success fw-bold">Asistencias</small>
                                <h2 class="mt-2 mb-1">${presentes}</h2>
                                <p class="text-muted small mb-0">Clases en las que estuviste presente.</p>
                            </div>
                        </div>
                    </article>
                </div>
                <div class="col-12 col-md-6 col-xl-6">
                    <article class="card-stat h-100">
                        <div class="card-stat-inner">
                            <div class="icon-box bg-danger bg-opacity-10 text-danger"><i class="bi bi-x-circle-fill"></i></div>
                            <div class="card-stat-copy">
                                <small class="text-uppercase text-danger fw-bold">Inasistencias</small>
                                <h2 class="mt-2 mb-1">${faltas}</h2>
                                <p class="text-muted small mb-0">Clases que aún debes recuperar.</p>
                            </div>
                        </div>
                    </article>
                </div>
                <div class="col-12 col-md-6 col-xl-6">
                    <article class="card-stat h-100">
                        <div class="card-stat-inner">
                            <div class="icon-box bg-warning bg-opacity-10 text-warning"><i class="bi bi-percent"></i></div>
                            <div class="card-stat-copy">
                                <small class="text-uppercase text-warning fw-bold">Porcentaje</small>
                                <h2 class="mt-2 mb-1">${porcentaje}%</h2>
                                <p class="text-muted small mb-0">Rendimiento general de asistencia.</p>
                            </div>
                        </div>
                    </article>
                </div>
            `;
        }

        if (placeholder) {
            placeholder.style.display = 'none';
        }

        if (!asistencias.length) {
            contenedor.innerHTML = `
                <div class="alert alert-warning shadow-sm border-0 rounded-3 text-center w-100 py-4 fs-6">
                    <i class="bi bi-info-circle-fill me-2 fs-5"></i> No se encontraron registros de asistencia para tu usuario.
                </div>
            `;
            return;
        }

        // Agrupar filas del array SQL por nombre de módulo
        const modulos = asistencias.reduce((acc, item) => {
            const nombre = item.modulo_nombre || 'Sin módulo';
            if (!acc[nombre]) {
                acc[nombre] = [];
            }
            acc[nombre].push(item);
            return acc;
        }, {});

        // Armado del árbol de elementos HTML
        contenedor.innerHTML = Object.entries(modulos).map(([nombre, registros], index) => {
            const total = registros.length;
            const asistenciasSi = registros.filter(r => String(r.asistio).toUpperCase() === 'SI').length;
            const faltas = total - asistenciasSi;
            const porcentaje = total ? Math.round((asistenciasSi / total) * 100) : 0;
            const collapseId = `modulo${index + 1}`;
            
            const itemsHTML = registros.map(registro => {
                const asistio = String(registro.asistio).toUpperCase();
                
                // Mapeo exacto de los badges de colores solicitados (SI -> Verde, NO -> Rojo)
                const estadoClase = asistio === 'SI' ? 'success' : 'fail';
                const icono = asistio === 'SI' ? 'bi-check-lg' : 'bi-x-lg';
                
                const fechaFormateada = formatearFechaAsistencia(registro.fecha);

                // Generación de estructura alineada simétricamente a través de Flexbox
                return `
                    <div class="attendance-item">
                        <div class="attendance-date-wrapper">
                            <i class="bi bi-calendar3"></i>
                            <span class="attendance-date-text">${fechaFormateada}</span>
                        </div>
                        <div class="status-badge ${estadoClase}">
                            <i class="bi ${icono}"></i>
                        </div>
                    </div>
                `;
            }).join('');

            return `
                <div class="accordion-item attendance-card mb-3">
                    <h2 class="accordion-header">
                        <button class="accordion-button collapsed attendance-button" type="button" data-bs-toggle="collapse" data-bs-target="#${collapseId}">
                            <div class="d-flex align-items-center w-100">
                                <div class="attendance-icon me-3">
                                    <i class="bi bi-journal-bookmark-fill fs-5"></i>
                                </div>
                                <div class="text-start flex-grow-1">
                                    <h5 class="mb-1 fw-bold text-dark fs-6 text-uppercase" style="letter-spacing: 0.3px;">${nombre}</h5>
                                    <small class="text-muted d-block fw-normal">${total} clases • ${asistenciasSi} asistencias • ${faltas} inasistencias</small>
                                </div>
                                <div class="d-flex align-items-center gap-2 ms-auto flex-wrap justify-content-end">
                                    <span class="attendance-pill attendance-pill-success">${porcentaje}% asistencia</span>
                                    <span class="attendance-pill">${total} clases</span>
                                </div>
                            </div>
                        </button>
                    </h2>
                    <div id="${collapseId}" class="accordion-collapse collapse" data-bs-parent="#accordionAsistencia">
                        <div class="accordion-body p-0 bg-light">
                            ${itemsHTML}
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    } catch (error) {
        if (placeholder) {
            placeholder.style.display = 'none';
        }
        contenedor.innerHTML = `
            <div class="alert alert-danger shadow-sm text-center w-100 py-4 rounded-3">
                <i class="bi bi-exclamation-octagon-fill me-2 fs-5"></i> Error al cargar las asistencias. Intenta de nuevo.
            </div>
        `;
        console.error("Error en flujo general de renderizado:", error);
    }
}

// Lanzamiento inicial automático del script al terminar la carga del DOM
document.addEventListener("DOMContentLoaded", () => {
    cargarAsistenciasEstudiante();
});