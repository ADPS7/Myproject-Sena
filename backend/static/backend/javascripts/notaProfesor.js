document.addEventListener("DOMContentLoaded", () => {
    const cursoSelect = document.getElementById("cursoSelect");
    const moduloSelect = document.getElementById("moduloSelect");
    const tablaEstudiantes = document.getElementById("tablaEstudiantes");

    // Datos simulados (reemplazar con fetch desde backend)
    const cursos = [
        { id: 1, nombre: "Matemáticas", modulos: ["Álgebra", "Geometría"] },
        { id: 2, nombre: "Historia", modulos: ["Antigua", "Moderna"] }
    ];

    const estudiantes = [
        { id: 101, nombre: "Juan Pérez", correo: "juan@example.com" },
        { id: 102, nombre: "María Gómez", correo: "maria@example.com" }
    ];

    // Cargar cursos
    cursos.forEach(c => {
        const option = document.createElement("option");
        option.value = c.id;
        option.textContent = c.nombre;
        cursoSelect.appendChild(option);
    });

    // Cargar módulos según curso
    cursoSelect.addEventListener("change", () => {
        moduloSelect.innerHTML = '<option value="">-- Selecciona un módulo --</option>';
        const curso = cursos.find(c => c.id == cursoSelect.value);
        if (curso) {
            curso.modulos.forEach(m => {
                const option = document.createElement("option");
                option.textContent = m;
                moduloSelect.appendChild(option);
            });
        }
    });

    // Mostrar estudiantes al elegir módulo
    moduloSelect.addEventListener("change", () => {
        tablaEstudiantes.innerHTML = "";
        estudiantes.forEach(e => {
            const fila = document.createElement("tr");
            fila.innerHTML = `
                <td>${e.nombre}</td>
                <td>${e.correo}</td>
                <td><input type="number" class="form-control nota-input" min="0" max="5" step="0.1" data-id="${e.id}"></td>
                <td><button class="btn btn-success btn-sm guardar-btn" data-id="${e.id}">Guardar</button></td>
            `;
            tablaEstudiantes.appendChild(fila);
        });

        // Acción de guardar
        document.querySelectorAll(".guardar-btn").forEach(btn => {
            btn.addEventListener("click", () => {
                const id = btn.dataset.id;
                const nota = document.querySelector(`.nota-input[data-id="${id}"]`).value;
                alert(`Nota guardada para estudiante ${id}: ${nota}`);
                // Aquí puedes hacer fetch POST al backend
            });
        });
    });
});
