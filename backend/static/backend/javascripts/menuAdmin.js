function mostrarvistaInicioAdmin() {
    ocultarTodasLasVistas();
    document.getElementById("mostrarInicioAdmin").style.display = "block";
    
    // Marcar activo
    document.querySelectorAll('.nav-link-item').forEach(link => link.classList.remove('active'));
    event.currentTarget.classList.add('active');
}

function mostrarvistaUsuarioAdmin() {
    ocultarTodasLasVistas();
    document.getElementById("mostrarUsuarioAdmin").style.display = "block";
    
    document.querySelectorAll('.nav-link-item').forEach(link => link.classList.remove('active'));
    event.currentTarget.classList.add('active');
}

function mostrarvistaCursosAdmin() {
    ocultarTodasLasVistas();
    
    const vistaCursos = document.getElementById('mostrarCursosAdmin');
    if (vistaCursos) {
        vistaCursos.style.display = 'block';
        
        // Inicializar datos
        setTimeout(inicializarCursosAdmin, 150);
    }

    document.querySelectorAll('.nav-link-item').forEach(link => link.classList.remove('active'));
    if (event && event.currentTarget) event.currentTarget.classList.add('active');
}

function ocultarTodasLasVistas() {
    document.getElementById('mostrarInicioAdmin').style.display = 'none';
    document.getElementById('mostrarUsuarioAdmin').style.display = 'none';
    document.getElementById('mostrarCursosAdmin').style.display = 'none';
}