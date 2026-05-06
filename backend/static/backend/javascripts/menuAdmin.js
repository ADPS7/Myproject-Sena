function mostrarvistaInicioAdmin() {
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: block;"
}

function mostrarvistaUsuarioAdmin() {
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:none;"
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: block;"
}
function mostrarvistaModulosAdmin() {
    inicio = document.getElementById("mostrarInicioAdmin").style = "display: none;"
    usuario = document.getElementById("mostrarUsuarioAdmin").style = "display: none;"
    modulo = document.getElementById("mostrarModulosAdmin").style = "display:block;"
}
