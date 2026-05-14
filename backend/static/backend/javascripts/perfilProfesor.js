document.addEventListener('DOMContentLoaded', function() {
    const inputFecha = document.getElementById('fecha_nacimiento_prof');
    
    if (inputFecha && inputFecha.getAttribute('value')) {
        // 1. Obtener el valor que viene de Flask/Jinja
        let fechaOriginal = inputFecha.getAttribute('value');
        
        try {
            // 2. Convertirlo a un objeto de fecha de JS
            let fecha = new Date(fechaOriginal);
            
            // 3. Validar que la fecha sea válida
            if (!isNaN(fecha.getTime())) {
                // 4. Formatear a YYYY-MM-DD
                let anio = fecha.getFullYear();
                let mes = String(fecha.getMonth() + 1).padStart(2, '0');
                let dia = String(fecha.getDate()).padStart(2, '0');
                
                let fechaFormateada = `${anio}-${mes}-${dia}`;
                
                // 5. Asignar el nuevo formato al input
                inputFecha.value = fechaFormateada;
            }
        } catch (e) {
            console.error("Error al formatear la fecha:", e);
        }
    }
});

function mostrarAlertaPersonalizada(titulo, mensaje, esExito = true) {
    const toastElement = document.getElementById('toastNotificacion');
    const toastTitulo = document.getElementById('toastTitulo');
    const toastMensaje = document.getElementById('toastMensaje');
    
    // Cambiar color según el resultado (Verde para éxito, Rojo para error)
    if (esExito) {
        toastElement.classList.replace('bg-danger', 'bg-success');
    } else {
        toastElement.classList.replace('bg-success', 'bg-danger');
    }

    toastTitulo.textContent = titulo;
    toastMensaje.textContent = mensaje;

    // Inicializar y mostrar con Bootstrap
    const toast = new bootstrap.Toast(toastElement, { delay: 3000 });
    toast.show();
}

function guardarPerfilProfesor() {
    const id = document.getElementById('id_usuario_prof').value;
    const nombres = document.getElementById('nombres_prof').value.trim();
    const apellidos = document.getElementById('apellidos_prof').value.trim();
    const correo = document.getElementById('correo_prof').value.trim();
    const fechaNacimiento = document.getElementById('fecha_nacimiento_prof').value;
    const clave = document.getElementById('nueva_clave_prof').value;

    if (!nombres || !apellidos || !correo || !fechaNacimiento) {
        mostrarAlertaPersonalizada("Atención", "Todos los campos son obligatorios.", false);
        return;
    }

    const datos = {
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        fecha_nacimiento: fechaNacimiento,
        nueva_clave: clave
    };

    fetch(`/actualizar_perfil/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(datos)
    })
    .then(res => res.json())
    .then(r => {
        if (r.success) {
            // Actualizar textos en la vista sin recargar
            const nombreVista = document.getElementById('nombreCompletoProfesorVista');
            if (nombreVista) nombreVista.textContent = `${nombres} ${apellidos}`;

            const avatar = document.querySelector('.avatar');
            if (avatar) avatar.textContent = nombres.charAt(0).toUpperCase();

            document.getElementById('nueva_clave_prof').value = "";

            // LANZAR LA ALERTA ABAJO (IGUAL A LA IMAGEN)
            mostrarAlertaPersonalizada("Éxito", "Asistencia registrada correctamente.", true);
        } else {
            mostrarAlertaPersonalizada("Error", r.error, false);
        }
    })
    .catch(error => {
        console.error("Error:", error);
        mostrarAlertaPersonalizada("Error", "No se pudo conectar con el servidor.", false);
    });
}