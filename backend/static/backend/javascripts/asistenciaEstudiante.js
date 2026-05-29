async function verAsistencia(idModulo, nombreModulo){

    document.getElementById("tituloModulo").innerHTML =
        `Asistencias - ${nombreModulo}`;

    const tabla = document.getElementById("tablaAsistencia");

    tabla.innerHTML = `
        <tr>
            <td colspan="3" class="text-center">
                Cargando...
            </td>
        </tr>
    `;

    try{

        const response = await fetch(`/asistencia/modulo/${idModulo}`);

        const data = await response.json();

        if(data.length === 0){

            tabla.innerHTML = `
                <tr>
                    <td colspan="3" class="text-center text-muted">
                        No hay asistencias registradas
                    </td>
                </tr>
            `;

            return;
        }

        tabla.innerHTML = "";

        data.forEach(asistencia => {

            const estadoClase =
                asistencia.estado === "FALTA"
                ? "estado-falta"
                : "estado-asistio";

            tabla.innerHTML += `
                <tr>

                    <td>${asistencia.fecha}</td>

                    <td>
                        <span class="${estadoClase}">
                            ${asistencia.estado}
                        </span>
                    </td>

                    <td>
                        ${asistencia.observacion || '-'}
                    </td>

                </tr>
            `;

        });

    }catch(error){

        tabla.innerHTML = `
            <tr>
                <td colspan="3" class="text-danger text-center">
                    Error al cargar asistencias
                </td>
            </tr>
        `;

        console.error(error);

    }

}

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
                const fecha = registro.fecha ? registro.fecha.split('T')[0] : 'Fecha no disponible';
                return `
                    <div class="attendance-item">
                        <div>
                            <strong>${fecha}</strong>
                        </div>
                        <div class="attendance-status ${estadoClase}">
                            <i class="bi ${icono}"></i>
                        </div>
                    </div>
                `;
            }).join('');

            return `
                <div class="accordion-item attendance-card">
                    <h2 class="accordion-header">
                        <button class="accordion-button collapsed attendance-button" type="button" data-bs-toggle="collapse" data-bs-target="#${collapseId}">
                            <div class="d-flex align-items-center w-100">
                                <div class="attendance-icon">
                                    <i class="bi bi-calendar-check"></i>
                                </div>
                                <div class="ms-3">
                                    <h5 class="mb-1 fw-bold">${nombre}</h5>
                                    <small class="text-muted">${total} registros • ${porcentaje}%</small>
                                </div>
                            </div>
                        </button>
                    </h2>
                    <div id="${collapseId}" class="accordion-collapse collapse" data-bs-parent="#accordionAsistencia">
                        <div class="accordion-body">
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
