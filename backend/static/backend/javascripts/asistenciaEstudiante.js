// =========================================================================
// 1. FUNCIÓN: CONSULTA DE ASISTENCIAS INDIVIDUALES POR MÓDULO (Estructura de Tabla)
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
                    Consultando registros de módulo...
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
                    <td colspan="3" class="text-center text-muted py-4">
                        No hay asistencias registradas para este módulo.
                    </td>
                </tr>
            `;
            return;
        }

        tabla.innerHTML = "";

        data.forEach(asistencia => {
            // Mapeo estricto del campo ENUM('SI','NO') de tu base de datos SQL
            const estadoAsistencia = String(asistencia.asistio).toUpperCase();
            
            const estadoClase = estadoAsistencia === "SI" ? "estado-asistio" : "estado-falta";
            const textoEstado = estadoAsistencia === "SI" ? "ASISTIÓ" : "INASISTENCIA";
            const fechaLimpia = asistencia.fecha ? asistencia.fecha.split('T')[0] : 'Fecha no disponible';

            tabla.innerHTML += `
                <tr>
                    <td class="fw-medium text-secondary py-3">${fechaLimpia}</td>
                    <td>
                        <span class="${estadoClase}">
                            ${textoEstado}
                        </span>
                    </td>
                    <td class="text-muted fs-7">
                        ${asistencia.observacion || '-'}
                    </td>
                </tr>
            `;
        });

    }catch(error){
        if (tabla) {
            tabla.innerHTML = `
                <tr>
                    <td colspan="3" class="text-danger text-center py-4">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> Error al cargar las asistencias.
                    </td>
                </tr>
            `;
        }
        console.error("Fallo en la consulta por módulo:", error);
    }
}

// =========================================================================
// 2. FUNCIÓN: VISTA GENERAL POR MÓDULO DEL ESTUDIANTE (Estructura de Acordeón)
// ===========================================
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
            throw new Error('Error al obtener las asistencias');
        }

        const data = await response.json();
        const asistencias = Array.isArray(data.asistencias) ? data.asistencias : [];

        if (placeholder) {
            placeholder.style.display = 'none';
        }

        if (!asistencias.length) {
            contenedor.innerHTML = `
                <div class="alert alert-warning shadow-sm text-center w-100">
                    No se encontraron registros de asistencia para tu usuario.
                </div>
            `;
            return;
        }

        const modulos = asistencias.reduce((acc, item) => {
            const nombre = item.modulo_nombre || 'Sin módulo';
            if (!acc[nombre]) {
                acc[nombre] = [];
            }
            acc[nombre].push(item);
            return acc;
        }, {});

        contenedor.innerHTML = Object.entries(modulos).map(([nombre, registros], index) => {
            const total = registros.length;
            const asistenciasSi = registros.filter(r => String(r.asistio).toUpperCase() === 'SI').length;
            const porcentaje = total ? Math.round((asistenciasSi / total) * 100) : 0;
            const collapseId = `modulo${index + 1}`;
            
            const itemsHTML = registros.map(registro => {
                const asistio = String(registro.asistio).toUpperCase();
                const estadoClase = asistio === 'SI' ? 'success' : 'fail';
                const icono = asistio === 'SI' ? 'bi-check-circle-fill' : 'bi-x-circle-fill';
                
                // === CONTROL Y FORMATEO SEGURO DE FECHAS ===
                let fechaFormateada = 'Fecha no disponible';
                if (registro.fecha) {
                    try {
                        // Si viene como formato de base de datos o estampa GMT, creamos un objeto Date
                        const d = new Date(registro.fecha);
                        // Validamos si la conversión fue exitosa para evitar el 'Invalid Date'
                        if (!isNaN(d.getTime())) {
                            const año = d.getFullYear();
                            // El mes inicia en 0, por eso sumamos 1 y rellenamos con cero a la izquierda si es necesario
                            const mes = String(d.getMonth() + 1).padStart(2, '0');
                            const dia = String(d.getDate()).padStart(2, '0');
                            fechaFormateada = `${año}-${mes}-${dia}`;
                        } else {
                            // Si falla la conversión del objeto Date, intentamos limpiar el String directo por espacios o la letra T
                            fechaFormateada = registro.fecha.includes('T') 
                                ? registro.fecha.split('T')[0] 
                                : registro.fecha.split(' 00:')[0];
                        }
                    } catch (e) {
                        fechaFormateada = 'Fecha no disponible';
                    }
                }

                return `
                    <div class="attendance-item d-flex justify-content-between align-items-center py-2 px-3 border-bottom">
                        <div>
                            <strong>${fechaFormateada}</strong>
                        </div>
                        <div class="attendance-status ${estadoClase}">
                            <i class="bi ${icono}"></i>
                        </div>
                    </div>
                `;
            }).join('');

            return `
                <div class="accordion-item attendance-card mb-3 border rounded-3 overflow-hidden bg-white shadow-sm">
                    <h2 class="accordion-header">
                        <button class="accordion-button collapsed attendance-button bg-white text-dark" type="button" data-bs-toggle="collapse" data-bs-target="#${collapseId}">
                            <div class="d-flex align-items-center w-100">
                                <div class="attendance-icon p-2 bg-light rounded border text-muted me-3">
                                    <i class="bi bi-calendar-check"></i>
                                </div>
                                <div class="ms-1">
                                    <h5 class="mb-1 fw-bold fs-6">${nombre}</h5>
                                    <small class="text-muted">${total} clases registradas • ${porcentaje}% de asistencia</small>
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
            <div class="alert alert-danger shadow-sm text-center w-100">
                Error al cargar las asistencias. Intenta de nuevo.
            </div>
        `;
        console.error(error);
    }
}
// Inicialización automática al cargar el archivo de scripts
document.addEventListener("DOMContentLoaded", () => {
    cargarAsistenciasEstudiante();
});