document.addEventListener("DOMContentLoaded", () => {
    const cursoSelect = document.getElementById("cursoSelect");
    const moduloSelect = document.getElementById("moduloSelect");
    const tablaEstudiantes = document.getElementById("tablaEstudiantes");
    const selectedCourseName = document.getElementById("selectedCourseName");
    const selectedModuleName = document.getElementById("selectedModuleName");
    const notaFeedback = document.getElementById("notaFeedback");

    // 🔹 Cargar cursos desde el backend
    fetch("/cursos")
        .then(res => res.json())
        .then(cursos => {
            cursos.forEach(c => {
                const option = document.createElement("option");
                option.value = c.id;
                option.textContent = c.nombre;
                cursoSelect.appendChild(option);
            });
        });

    // 🔹 Cargar módulos según curso
    cursoSelect.addEventListener("change", () => {
        moduloSelect.innerHTML = '<option value="">-- Selecciona un módulo --</option>';
        const cursoId = cursoSelect.value;

        selectedCourseName.textContent = cursoSelect.options[cursoSelect.selectedIndex].text || '—';

        if (cursoId) {
            fetch(`/modulos/curso/${cursoId}`)
                .then(res => res.json())
                .then(modulos => {
                    modulos.forEach(m => {
                        const option = document.createElement("option");
                        option.value = m.id;
                        option.textContent = m.nombre;
                        moduloSelect.appendChild(option);
                    });
                });
        }
    });

    // 🔹 Mostrar estudiantes al elegir módulo
    moduloSelect.addEventListener("change", () => {
        tablaEstudiantes.innerHTML = "";
        const moduloId = moduloSelect.value;

        tablaEstudiantes.innerHTML = "";
        selectedModuleName.textContent = moduloSelect.options[moduloSelect.selectedIndex].text || '—';

        if (moduloId) {
            fetch(`/modulo/${moduloId}/students`)
                .then(res => res.json())
                .then(estudiantes => {
                    estudiantes.forEach(e => {
                        const fila = document.createElement("tr");
                        fila.innerHTML = `
                            <td>${e.nombre}</td>
                            <td>${e.correo}</td>
                            <td><input type="number" class="form-control nota-input" min="0" max="5" step="0.1" data-id="${e.id}"></td>
                            <td class="text-nowrap"><button class="btn btn-success btn-sm guardar-btn" data-id="${e.id}">Guardar</button></td>
                        `;
                        tablaEstudiantes.appendChild(fila);
                    });

                    // Acción de guardar nota
                    document.querySelectorAll(".guardar-btn").forEach(btn => {
                        btn.addEventListener("click", () => {
                            const id = btn.dataset.id;
                            const nota = document.querySelector(`.nota-input[data-id="${id}"]`).value;
                            notaFeedback.innerHTML = '';

                            fetch(`/notas`, {
                                method: "POST",
                                headers: { "Content-Type": "application/json" },
                                body: JSON.stringify({ id_usuario: Number(id), id_modulo: Number(moduloId), nota: Number(nota) })
                            })
                            .then(res => res.json())
                            .then(data => {
                                if (data.success) {
                                    notaFeedback.innerHTML = `<div class="alert alert-success">Nota guardada correctamente.</div>`;
                                } else {
                                    notaFeedback.innerHTML = `<div class="alert alert-danger">Error: ${data.error || 'No se pudo guardar la nota'}</div>`;
                                }
                            })
                            .catch(err => {
                                console.error(err);
                                notaFeedback.innerHTML = `<div class="alert alert-danger">Error al guardar la nota.</div>`;
                            });
                        });
                    });
                });
        }
    });
});
