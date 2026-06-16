document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("recoverForm");
    const loginCard = document.querySelector(".login-card");
    
    // Variables de control de estado interno
    let correoUsuario = "";
    let faseActual = 1; // 1: Correo, 2: Código, 3: Nueva Contraseña

    form.addEventListener("submit", async (e) => {
        e.preventDefault();
        
        const submitBtn = document.getElementById("submitBtn");
        // Evitamos clicks repetidos deshabilitando el botón de envío
        submitBtn.disabled = true;

        if (faseActual === 1) {
            await manejarFaseCorreo(submitBtn);
        } else if (faseActual === 2) {
            await manejarFaseCodigo(submitBtn);
        } else if (faseActual === 3) {
            await manejarFaseNuevaClave(submitBtn);
        }
    });

    // =========================================================================
    // FASE 1: CONSULTAR CORREO Y ENVIAR EL CÓDIGO
    // =========================================================================
    async function manejarFaseCorreo(submitBtn) {
        const emailInput = document.getElementById("email");
        correoUsuario = emailInput.value.trim();

        try {
            // Verificar si el correo existe en la base de datos
            const checkRes = await fetch("/check-email", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ correo: correoUsuario })
            });

            if (!checkRes.ok) {
                alert("El correo electrónico no se encuentra registrado en el sistema.");
                submitBtn.disabled = false;
                return;
            }

            // Si existe, solicitar a Flask que genere y envíe el código
            submitBtn.innerText = "Enviando código...";
            const resetRes = await fetch("/request-reset", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ correo: correoUsuario })
            });

            if (resetRes.ok) {
                alert("Código enviado con éxito. Revisa tu correo electrónico.");
                cambiarInterfazAFaseCodigo();
            } else {
                const errData = await resetRes.json();
                alert(errData.error || "Ocurrió un error al enviar el código.");
                submitBtn.disabled = false;
                submitBtn.innerText = "Enviar Instrucciones";
            }

        } catch (error) {
            console.error("Error en Fase 1:", error);
            alert("No se pudo conectar con el servidor.");
            submitBtn.disabled = false;
            submitBtn.innerText = "Enviar Instrucciones";
        }
    }

    // =========================================================================
    // FASE 2: VERIFICACIÓN DEL CÓDIGO (CONTEO DE INTENTOS)
    // =========================================================================
    async function manejarFaseCodigo(submitBtn) {
        const codigoInput = document.getElementById("codigoVerificacion");
        const codigoVal = codigoInput.value.trim();

        try {
            const res = await fetch("/verify-code", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ correo: correoUsuario, codigo: codigoVal })
            });

            const data = await res.json();

            if (res.status === 200 && data.success) {
                alert("¡Código verificado correctamente!");
                cambiarInterfazAFaseNuevaClave();
            } else if (res.status === 403) {
                // Se acabaron los 3 intentos en el servidor
                alert(data.error + " El flujo se reiniciará automáticamente.");
                window.location.reload(); 
            } else {
                // Código inválido con intentos restantes
                alert(data.error);
                codigoInput.value = "";
                codigoInput.focus();
                submitBtn.disabled = false;
            }

        } catch (error) {
            console.error("Error en Fase 2:", error);
            alert("Error de conexión al validar el código.");
            submitBtn.disabled = false;
        }
    }

    // =========================================================================
    // FASE 3: ENVÍO DE LA NUEVA CONTRASEÑA ENCRIPTADA
    // =========================================================================
    async function manejarFaseNuevaClave(submitBtn) {
        const passwordInput = document.getElementById("nuevaPassword");
        const confirmInput = document.getElementById("confirmarPassword");
        
        const clave = passwordInput.value;
        const confirmar = confirmInput.value;

        if (clave !== confirmar) {
            alert("Las contraseñas ingresadas no coinciden.");
            submitBtn.disabled = false;
            return;
        }

        try {
            const res = await fetch("/update-password", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ correo: correoUsuario, clave: clave })
            });

            const data = await res.json();

            if (res.ok && data.success) {
                alert("Tu contraseña ha sido restablecida con éxito.");
                // Redirección directa a tu login estático
                window.location.href = "/login"; 
            } else {
                alert(data.error || "No se pudo actualizar la contraseña.");
                submitBtn.disabled = false;
            }

        } catch (error) {
            console.error("Error en Fase 3:", error);
            alert("Error de red al intentar actualizar la contraseña.");
            submitBtn.disabled = false;
        }
    }

    // =========================================================================
    // INTERFACES DINÁMICAS (MUTACIONES DEL DOM CON TUS CLASES)
    // =========================================================================
    
    function cambiarInterfazAFaseCodigo() {
        faseActual = 2;
        
        // Modificar textos de la tarjeta
        loginCard.querySelector("h2").innerText = "Verifica tu Identidad";
        loginCard.querySelector(".subtitle").innerText = `Ingresa el código de 6 dígitos que enviamos a: ${correoUsuario}`;

        // Inyectamos el input del código con las mismas clases estéticas
        const contenedorInputs = form.querySelector(".input-group-custom");
        contenedorInputs.innerHTML = `
            <label>Código de Verificación</label>
            <div class="input-field">
                <input type="text" id="codigoVerificacion" class="form-control" placeholder="123456" maxlength="6" required style="letter-spacing: 5px; font-weight: bold; text-align: center; padding-left: 12px;">
                <i class="bi bi-shield-check" style="left: auto; right: 16px;"></i>
            </div>
        `;

        const submitBtn = document.getElementById("submitBtn");
        submitBtn.innerText = "Validar Código";
        submitBtn.disabled = false;
    }

    function cambiarInterfazAFaseNuevaClave() {
        faseActual = 3;

        // Modificar textos de la tarjeta
        loginCard.querySelector("h2").innerText = "Nueva Contraseña";
        loginCard.querySelector(".subtitle").innerText = "Escribe tu nueva clave de acceso para actualizar tu cuenta.";

        // Inyectamos los dos campos de contraseña heredando tu diseño impecable
        const contenedorInputs = form.querySelector(".input-group-custom");
        contenedorInputs.innerHTML = `
            <div class="mb-3">
                <label>Nueva Contraseña</label>
                <div class="input-field">
                    <input type="password" id="nuevaPassword" class="form-control" placeholder="••••••••" required>
                    <i class="bi bi-lock"></i>
                </div>
            </div>
            <div>
                <label>Confirmar Contraseña</label>
                <div class="input-field">
                    <input type="password" id="confirmarPassword" class="form-control" placeholder="••••••••" required>
                    <i class="bi bi-lock-fill"></i>
                </div>
            </div>
        `;

        const submitBtn = document.getElementById("submitBtn");
        submitBtn.innerText = "Actualizar Contraseña";
        submitBtn.disabled = false;
    }
});