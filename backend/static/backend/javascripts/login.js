document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('loginForm');
    const submitBtn = document.getElementById('submitBtn');

    form.addEventListener('submit', async function(e) {
        e.preventDefault();

        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = `
            <span class="spinner-border spinner-border-sm"></span>
            Iniciando sesión...
        `;

        const formData = new FormData(form);

        try {
            const response = await fetch('/login', {
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
                window.location.href = '/dashboard';
            } else {
                let msg = result.error || "Correo o contraseña incorrectos";
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

// Función mejorada con cierre instantáneo
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
        <button type="button" class="btn-close instant-close" aria-label="Close"></button>
    `;

    document.body.appendChild(alertDiv);

    // Cierre instantáneo al tocar la X
    const closeBtn = alertDiv.querySelector('.btn-close');
    closeBtn.addEventListener('click', () => {
        alertDiv.style.transition = 'none';
        alertDiv.style.opacity = '0';
        setTimeout(() => alertDiv.remove(), 10);
    });

    // Auto-cerrar después de 5 segundos
    setTimeout(() => {
        if (alertDiv.parentNode) {
            alertDiv.style.transition = 'opacity 0.3s';
            alertDiv.style.opacity = '0';
            setTimeout(() => alertDiv.remove(), 300);
        }
    }, 5000);
}