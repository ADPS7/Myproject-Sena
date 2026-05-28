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