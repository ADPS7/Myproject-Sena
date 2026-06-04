document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('registerForm');
    const emailInput = document.getElementById('email');
    const fechaInput = document.getElementById('fecha_nacimiento');
    const passwordInput = document.getElementById('password');
    const submitBtn = document.getElementById('submitBtn');

    //---------------------
    const nombreInput = document.querySelector('input[name="nombre"]');
    const apellidoInput = document.querySelector('input[name="apellido"]');

    function soloLetras(event) {
    event.target.value = event.target.value.replace(
        /[^A-Za-zÁÉÍÓÚáéíóúÑñ\s]/g,
        ''
    );
    }

    nombreInput.addEventListener('input', soloLetras);
    apellidoInput.addEventListener('input', soloLetras);
    //---------------------

    form.addEventListener('submit', async function(e) {
        e.preventDefault();
//------------------------------------------------------
        const regexNombre = /^[A-Za-zÁÉÍÓÚáéíóúÑñ\s]+$/;

if (!regexNombre.test(nombreInput.value.trim())) {
    showMessage("❌ El nombre solo puede contener letras", "danger");
    nombreInput.focus();
    return;
}

if (!regexNombre.test(apellidoInput.value.trim())) {
    showMessage("❌ El apellido solo puede contener letras", "danger");
    apellidoInput.focus();
    return;
}
//------------------------------------------------------

        // 1. Validación de Correo (Estricta: Solo letras después del @)
        // [a-zA-Z0-9._%+-]+ : Usuario
        // @[a-zA-Z]+        : Dominio (SOLO LETRAS, sin números ni guiones)
        // \.[a-zA-Z]{2,6}$  : Extensión (SOLO LETRAS)
        const regexCorreo = /^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\.[a-zA-Z]{2,6}$/;
        
        if (!regexCorreo.test(emailInput.value.trim())) {
            showMessage("❌ El dominio del correo debe contener únicamente letras (ej: gmail.com)", "danger");
            emailInput.focus();
            return;
        }

        // 2. Validación de Edad (Mayor o igual a 16 años)
        const fechaNac = new Date(fechaInput.value);
        const hoy = new Date();
        let edad = hoy.getFullYear() - fechaNac.getFullYear();
        const m = hoy.getMonth() - fechaNac.getMonth();
        if (m < 0 || (m === 0 && hoy.getDate() < fechaNac.getDate())) edad--;

        if (isNaN(edad) || edad < 16) {
            showMessage("❌ Debes tener al menos 16 años para registrarte", "danger");
            return;
        }

        // 3. Validación de Contraseña
        const pass = passwordInput.value;
        const tieneMayuscula = /[A-Z]/;
        const tieneMinuscula = /[a-z]/;
        const tieneNumero = /[0-9]/;
        const tieneSimbolo = /[!@#$%^&*(),.?":{}|<>_+\-\[\]\\\/`~;]/;

        if (pass.length < 7 || !tieneMayuscula.test(pass) || !tieneMinuscula.test(pass) || !tieneNumero.test(pass) || !tieneSimbolo.test(pass)) {
            showMessage("❌ La contraseña debe tener mín. 7 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 símbolo", "danger");
            return;
        }

        // Envío al servidor
        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = `<span class="spinner-border spinner-border-sm"></span> Procesando...`;

        const formData = new FormData(form);

        try {
            const response = await fetch('/create_user', {
                method: 'POST',
                body: formData
            });

            const result = await response.json().catch(() => ({ error: "Error del servidor" }));

            if (response.ok) {
                showMessage("✅ ¡Registro exitoso!", "success");
                setTimeout(() => window.location.href = '/login', 1500);
            } else {
                showMessage(result.error || "Error al registrar", "danger");
            }
        } catch (err) {
            showMessage("❌ Error de conexión", "danger");
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    });
});

function showMessage(message, type) {
    document.querySelectorAll('.custom-alert').forEach(el => el.remove());
    const alertDiv = document.createElement('div');
    alertDiv.className = `custom-alert alert alert-${type} shadow`;
    alertDiv.style.cssText = 'position:fixed; top:20px; left:50%; transform:translateX(-50%); z-index:9999; min-width:300px; text-align:center;';
    alertDiv.innerHTML = message;
    document.body.appendChild(alertDiv);
    setTimeout(() => alertDiv.remove(), 4000);
}