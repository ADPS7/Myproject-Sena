document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('registerForm');
    const passwordInput = document.getElementById('password');
    const submitBtn = document.getElementById('submitBtn');

    form.addEventListener('submit', async function(e) {
        e.preventDefault();

        if (passwordInput.value.length <= 6) {
            showMessage("La contraseña debe tener más de 6 caracteres", "danger");
            passwordInput.focus();
            return;
        }

        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = `
            <span class="spinner-border spinner-border-sm" role="status"></span>
            Registrando...
        `;

        const formData = new FormData(form);

        try {
            const response = await fetch('/create_user', {
                method: 'POST',
                body: formData
            });

            let result;
            try {
                result = await response.json();
            } catch {
                result = { error: "Error del servidor" };
            }

            if (response.ok) {
                showMessage("¡Registro exitoso! Redirigiendo...", "success");
                setTimeout(() => {
                    window.location.href = '/login';
                }, 1500);
            } else {
                let msg = result.error || "Error al registrar usuario";
                showMessage(msg, "danger");
            }
        } catch (err) {
            showMessage("Error de conexión con el servidor", "danger");
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    });
});

function showMessage(message, type = "success") {
    // Eliminar alertas anteriores
    document.querySelectorAll('.custom-alert').forEach(el => el.remove());

    const alertDiv = document.createElement('div');
    alertDiv.className = `custom-alert alert alert-${type} alert-dismissible fade show`;
    alertDiv.style.position = 'fixed';
    alertDiv.style.top = '20px';
    alertDiv.style.left = '50%';
    alertDiv.style.transform = 'translateX(-50%)';
    alertDiv.style.zIndex = '9999';
    alertDiv.style.minWidth = '340px';
    alertDiv.style.boxShadow = '0 10px 30px rgba(0,0,0,0.2)';

    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" aria-label="Close"></button>
    `;

    document.body.appendChild(alertDiv);

    const closeBtn = alertDiv.querySelector('.btn-close');
    closeBtn.addEventListener('click', () => {
        alertDiv.remove();
    });

    setTimeout(() => {
        if (alertDiv.parentNode) alertDiv.remove();
    }, 5000);
}