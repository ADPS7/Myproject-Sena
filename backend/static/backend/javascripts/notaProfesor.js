document.addEventListener("DOMContentLoaded", () => {
    const cursoSelect = document.getElementById("cursoSelect");
    const moduloSelect = document.getElementById("moduloSelect");
    const tablaEstudiantes = document.getElementById("tablaEstudiantes");
    const selectedCourseName = document.getElementById("selectedCourseName");
    const selectedModuleName = document.getElementById("selectedModuleName");
    const notaFeedback = document.getElementById("notaFeedback");
    const viewAllNotasBtn = document.getElementById("viewAllNotasBtn");
    const notasModalBody = document.getElementById("notasModalBody");
    const notasModalEl = document.getElementById("notasModal");

    // 🔹 Cargar cursos desde el backend (usa `id_curso`)
    fetch("/cursos")
        .then(res => res.json())
        .then(cursos => {
            cursos.forEach(c => {
                const option = document.createElement("option");
                option.value = c.id_curso || c.id || c.idCurso;
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
                        option.value = m.id_modulo || m.id;
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
            // habilitar botón ver notas
            if (viewAllNotasBtn) viewAllNotasBtn.disabled = false;
            // endpoint que devuelve estudiantes (y notas si existen): /notas/modulo/<id_modulo>
            fetch(`/notas/modulo/${moduloId}`)
                .then(res => res.json())
                .then(estudiantes => {
                    // esperar array con objetos que incluyan: id_usuario, nombres, apellidos, correo, nota, id_nota
                    estudiantes.forEach(e => {
                        const studentName = e.nombre || `${e.nombres || ''} ${e.apellidos || ''}`.trim();
                        const studentId = e.id_usuario || e.id || e.user_id;
                        const studentEmail = e.correo || e.email || '';
                        const notaVal = (e.nota !== undefined && e.nota !== null) ? e.nota : '';

                        const fila = document.createElement("tr");
                        fila.innerHTML = `
                            <td>${studentName}</td>
                            <td>${studentEmail}</td>
                            <td><input type="number" class="form-control nota-input" min="0" max="5" step="0.1" data-id="${studentId}" value="${notaVal}"></td>
                            <td class="text-nowrap"><button class="btn btn-success btn-sm guardar-btn" data-id="${studentId}">Guardar</button></td>
                        `;
                        tablaEstudiantes.appendChild(fila);
                    });

                    // Acción de guardar nota (por estudiante)
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
        } else {
            if (viewAllNotasBtn) viewAllNotasBtn.disabled = true;
        }
    });

    // Ver todas las notas en modal
    if (viewAllNotasBtn) {
        viewAllNotasBtn.addEventListener('click', () => {
            const moduloId = moduloSelect.value;
            if (!moduloId) return;
            notasModalBody.innerHTML = '<tr><td colspan="3" class="text-center py-3">Cargando...</td></tr>';

            fetch(`/notas/modulo/${moduloId}`)
                .then(res => res.json())
                .then(list => {
                    notasModalBody.innerHTML = '';

                    if (!Array.isArray(list) || !list.length) {
                        notasModalBody.innerHTML = '<tr><td colspan="3" class="text-center text-secondary">No hay notas para este módulo.</td></tr>';
                        return;
                    }

                    list.forEach(e => {
                        const studentName = e.nombre || `${e.nombres || ''} ${e.apellidos || ''}`.trim();
                        const studentEmail = e.correo || e.email || '';
                        const notaVal = (e.nota !== undefined && e.nota !== null) ? e.nota : '-';
                        const tr = document.createElement('tr');
                        tr.innerHTML = `<td>${studentName}</td><td>${studentEmail}</td><td>${notaVal}</td>`;
                        notasModalBody.appendChild(tr);
                    });

                    if (typeof bootstrap !== 'undefined' && notasModalEl) {
                        const modal = new bootstrap.Modal(notasModalEl);
                        modal.show();
                    }
                })
                .catch(err => {
                    console.error(err);
                    notasModalBody.innerHTML = '<tr><td colspan="3" class="text-danger text-center">Error al cargar notas.</td></tr>';
                });
        });
    }
});
