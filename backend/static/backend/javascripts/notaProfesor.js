document.addEventListener("DOMContentLoaded", () => {
    const cursoSelect = document.getElementById("cursoSelect");
    const moduloSelect = document.getElementById("moduloSelect");
    const tablaEstudiantes = document.getElementById("tablaEstudiantes");
    const selectedCourseName = document.getElementById("selectedCourseName");
    const selectedModuleName = document.getElementById("selectedModuleName");
    const notaFeedback = document.getElementById("notaFeedback");
    const viewAllNotasBtn = document.getElementById("viewAllNotasBtn");
    const searchStudentInput = document.getElementById("searchStudentInput");
    const applyAllNotaBtn = document.getElementById("applyAllNotaBtn");

    // 🔹 Cargar cursos desde el backend (usa `id_curso`) - solo cursos del profesor
    fetch(`/cursos/profesor/${window.USER_ID}`)
        .then(res => res.json())
        .then(cursos => {
            cursos.forEach(c => {
                const option = document.createElement("option");
                option.value = c.id_curso || c.id || c.idCurso;
                option.textContent = c.nombre;
                cursoSelect.appendChild(option);
            });
        })
        .catch(err => {
            console.error('Error al cargar cursos del profesor:', err);
            cursoSelect.innerHTML = '<option value="">Error al cargar cursos</option>';
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

    // Delegated handlers: evitar listeners repetidos
    // Click delegado para botones de guardar individuales
    if (tablaEstudiantes && !tablaEstudiantes.dataset.delegateAttached) {
        tablaEstudiantes.dataset.delegateAttached = '1';
        tablaEstudiantes.addEventListener('click', async (ev) => {
            const btn = ev.target.closest('.guardar-btn');
            if (!btn) return;
            const id = btn.dataset.id;
            const input = tablaEstudiantes.querySelector(`.nota-input[data-id="${id}"]`);
            if (!input) return;

            // Validar valor
            const raw = (input.value || '').toString().trim();
            const n = parseFloat(raw);
            notaFeedback.innerHTML = '';
            if (raw === '' || isNaN(n) || n < 0 || n > 5) {
                input.classList.add('is-invalid');
                btn.disabled = true;
                notaFeedback.innerHTML = `<div class="alert alert-warning">Ingrese una nota válida entre 0 y 5.</div>`;
                return;
            }

            // Enviar petición individual
            btn.disabled = true;
            try {
                const res = await fetch(`/notas`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ id_usuario: Number(id), id_modulo: Number(moduloSelect.value), nota: Number(n) })
                });
                const data = await res.json();
                if (data.success) {
                    notaFeedback.innerHTML = `<div class="alert alert-success">Nota guardada correctamente.</div>`;
                    input.classList.remove('is-invalid');
                    input.classList.add('is-valid');
                } else {
                    notaFeedback.innerHTML = `<div class="alert alert-danger">Error: ${data.error || 'No se pudo guardar la nota'}</div>`;
                }
            } catch (err) {
                console.error(err);
                notaFeedback.innerHTML = `<div class="alert alert-danger">Error al guardar la nota.</div>`;
            } finally {
                btn.disabled = false;
            }
        });
    }

    // Input delegado para validar en tiempo real y habilitar/deshabilitar botones guardar
    if (tablaEstudiantes && !tablaEstudiantes.dataset.inputAttached) {
        tablaEstudiantes.dataset.inputAttached = '1';
        tablaEstudiantes.addEventListener('input', (ev) => {
            const input = ev.target.closest('.nota-input');
            if (!input) return;
            const raw = (input.value || '').toString().trim();
            const btn = tablaEstudiantes.querySelector(`.guardar-btn[data-id="${input.dataset.id}"]`);
            if (raw === '') {
                input.classList.remove('is-invalid', 'is-valid');
                if (btn) btn.disabled = false;
                return;
            }
            const n = parseFloat(raw);
            if (isNaN(n) || n < 0 || n > 5) {
                input.classList.add('is-invalid');
                input.classList.remove('is-valid');
                if (btn) btn.disabled = true;
            } else {
                input.classList.remove('is-invalid');
                input.classList.add('is-valid');
                if (btn) btn.disabled = false;
            }
        });
    }

    if (searchStudentInput) {
        searchStudentInput.addEventListener('input', () => {
            filtrarEstudiantesPorNombre(searchStudentInput.value);
        });
    }

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
                    const seen = new Set();
                    estudiantes.forEach(e => {
                        const studentId = e.id_usuario || e.id || e.user_id;
                        const sid = String(studentId);
                        if (seen.has(sid)) return; // ignorar duplicados
                        seen.add(sid);

                        const studentName = e.nombre || `${e.nombres || ''} ${e.apellidos || ''}`.trim();
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

                    // Habilitar botón de aplicar notas si hay estudiantes
                    const hasStudents = estudiantes && estudiantes.length;
                    if (applyAllNotaBtn) applyAllNotaBtn.disabled = !hasStudents;
                    if (searchStudentInput) {
                        searchStudentInput.disabled = !hasStudents;
                        searchStudentInput.value = '';
                    }
                    filtrarEstudiantesPorNombre('');

                    // Lógica: guardar en lote las notas actualmente ingresadas en los inputs
                    if (applyAllNotaBtn && !applyAllNotaBtn.dataset.bulkAttached) {
                        applyAllNotaBtn.dataset.bulkAttached = '1';
                        applyAllNotaBtn.addEventListener('click', async () => {
                            const moduloIdLocal = moduloId;
                            notaFeedback.innerHTML = '';

                            const inputs = Array.from(document.querySelectorAll('.nota-input'));
                            if (!inputs.length) {
                                notaFeedback.innerHTML = `<div class="alert alert-secondary">No hay estudiantes listados.</div>`;
                                return;
                            }


                            // Validar y marcar inputs: solo valores numéricos entre 0 y 5 se enviarán
                            inputs.forEach(i => i.classList.remove('is-invalid', 'is-valid'));
                            const updates = [];
                            let invalidCount = 0;
                            inputs.forEach(i => {
                                const raw = (i.value || '').toString().trim();
                                if (raw === '') return; // vacío -> omitir
                                const n = parseFloat(raw);
                                if (isNaN(n) || n < 0 || n > 5) {
                                    i.classList.add('is-invalid');
                                    invalidCount++;
                                } else {
                                    i.classList.add('is-valid');
                                    updates.push({ id: i.dataset.id, nota: n });
                                }
                            });

                            if (invalidCount > 0) {
                                notaFeedback.innerHTML = `<div class="alert alert-warning">Hay ${invalidCount} entradas inválidas. Corrija los campos marcados antes de aplicar.</div>`;
                                return;
                            }

                            if (!updates.length) {
                                notaFeedback.innerHTML = `<div class="alert alert-warning">No hay notas válidas para guardar. Complete las notas antes de aplicar.</div>`;
                                return;
                            }

                            const guardarBtns = Array.from(document.querySelectorAll('.guardar-btn'));
                            guardarBtns.forEach(b => b.disabled = true);
                            if (applyAllNotaBtn) applyAllNotaBtn.disabled = true;

                            const promises = updates.map(u => {
                                return fetch(`/notas`, {
                                    method: "POST",
                                    headers: { "Content-Type": "application/json" },
                                    body: JSON.stringify({ id_usuario: Number(u.id), id_modulo: Number(moduloIdLocal), nota: Number(u.nota) })
                                })
                                .then(res => res.json())
                                .then(data => ({ id: u.id, ok: !!data.success, error: data.error }))
                                .catch(err => ({ id: u.id, ok: false, error: err && err.message }))
                            });

                            const results = await Promise.all(promises);
                            const successCount = results.filter(r => r.ok).length;
                            const failCount = results.length - successCount;

                            if (successCount && !failCount) {
                                notaFeedback.innerHTML = `<div class="alert alert-success">Notas guardadas correctamente: ${successCount}.</div>`;
                            } else if (successCount && failCount) {
                                notaFeedback.innerHTML = `<div class="alert alert-warning">${successCount} guardadas, ${failCount} fallaron.</div>`;
                            } else {
                                notaFeedback.innerHTML = `<div class="alert alert-danger">No se pudieron guardar las notas.</div>`;
                            }

                            guardarBtns.forEach(b => b.disabled = false);
                            if (applyAllNotaBtn) applyAllNotaBtn.disabled = false;
                        });
                    }
                });
        } else {
            if (viewAllNotasBtn) viewAllNotasBtn.disabled = true;
        }
    });

    // Ver todas las notas: mostrar la vista completa del módulo (sin modal)
    if (viewAllNotasBtn) {
        viewAllNotasBtn.addEventListener('click', () => {
            const moduloId = moduloSelect.value;
            const nombreModulo = selectedModuleName.textContent || '';
            if (!moduloId) return;
            verHistorialNotasModulo(moduloId, nombreModulo);
        });
    }
});

// --- Vista completa de notas (historial) ---
async function verHistorialNotasModulo(idModulo, nombreModulo) {
    // Mostrar la vista propia de historial de notas y renderizar dentro
    const mostrarNotasDiv = document.getElementById('mostrarNotasProfesor');
    const mostrarHistorialDiv = document.getElementById('mostrarHistorialNotas');
    if (mostrarNotasDiv) mostrarNotasDiv.style.display = 'none';
    if (mostrarHistorialDiv) mostrarHistorialDiv.style.display = 'block';

    const titleEl = document.getElementById('historial-view-title');
    const subtitleEl = document.getElementById('historial-view-subtitle');
    if (titleEl) titleEl.innerText = nombreModulo || 'Notas del módulo';
    if (subtitleEl) subtitleEl.innerText = 'Historial y resumen de calificaciones del módulo';

    const historialContainer = document.getElementById('historialNotasContainer');
    if (!historialContainer) return;
    historialContainer.innerHTML = `<div class="col-12"><div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Cargando...</span></div><p class="mt-2 text-muted">Cargando historial de notas...</p></div></div>`;

    // Conectar botón volver en la nueva vista
    const backBtn = document.getElementById('historial-back-btn');
    if (backBtn) backBtn.onclick = () => {
        if (mostrarHistorialDiv) mostrarHistorialDiv.style.display = 'none';
        if (mostrarNotasDiv) mostrarNotasDiv.style.display = 'block';
        // restaurar títulos
        const mainTitle = document.getElementById('view-title');
        const mainSubtitle = document.getElementById('view-subtitle');
        if (mainTitle) mainTitle.innerText = 'Notas';
        if (mainSubtitle) mainSubtitle.innerText = 'Aquí puedes ver y actualizar las calificaciones de tus estudiantes.';
        historialContainer.innerHTML = '';
    };

    try {
        const res = await fetch(`/notas/modulo/${idModulo}`);
        const data = await res.json();
        if (!Array.isArray(data)) throw new Error('Respuesta inesperada del servidor');
        renderizarHistorialNotas(data);
    } catch (err) {
        console.error('Error cargando historial de notas:', err);
        historialContainer.innerHTML = `<div class="alert alert-danger">No se pudo cargar el historial de notas.</div>`;
    }
}

function filtrarEstudiantesPorNombre(query) {
        const tbody = document.getElementById('tablaEstudiantes');
        if (!tbody) return;
        const texto = (query || '').toLowerCase().trim();
        let visibleCount = 0;

        tbody.querySelectorAll('tr').forEach(row => {
            const nombre = (row.querySelector('td:nth-child(1)')?.textContent || '').toLowerCase();
            const correo = (row.querySelector('td:nth-child(2)')?.textContent || '').toLowerCase();
            const matches = !texto || nombre.includes(texto) || correo.includes(texto);
            row.style.display = matches ? '' : 'none';
            if (matches) visibleCount += 1;
        });

        let placeholder = document.getElementById('tablaEstudiantesPlaceholder');
        if (visibleCount === 0 && tbody.querySelectorAll('tr').length > 0) {
            if (!placeholder) {
                placeholder = document.createElement('tr');
                placeholder.id = 'tablaEstudiantesPlaceholder';
                placeholder.innerHTML = `<td colspan="4" class="text-center text-muted py-4">No se encontró ningún estudiante.</td>`;
                tbody.appendChild(placeholder);
            }
        } else if (placeholder) {
            placeholder.remove();
        }
    }

    function renderizarHistorialNotas(list) {
    const historialContainer = document.getElementById('historialNotasContainer');
    if (!historialContainer) return;

    if (!Array.isArray(list) || list.length === 0) {
        historialContainer.innerHTML = `
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <div class="text-muted">Aún no hay notas registradas para este módulo.</div>
            </div>
        `;
        return;
    }

    // Agrupar por estudiante
    const alumnos = {};
    list.forEach(item => {
        const nombre = item.nombre || (`Usuario ${item.id_usuario || ''}`);
        const notaVal = (item.nota !== undefined && item.nota !== null) ? Number(item.nota) : null;
        if (!alumnos[nombre]) alumnos[nombre] = { id_usuario: item.id_usuario, nombre: nombre, notas: [] };
        if (notaVal !== null) alumnos[nombre].notas.push(notaVal);
    });

    const rows = Object.values(alumnos).map(est => {
        const notasArr = est.notas || [];
        const promedio = notasArr.length ? (notasArr.reduce((a,b)=>a+b,0)/notasArr.length) : null;
        const alerta = promedio !== null ? promedio < 3.0 : false;
        const promedioDisplay = promedio !== null ? promedio.toFixed(2) : '—';
        const ultimosHtml = notasArr.length ? notasArr.slice(0,10).map(n => `<span class="badge bg-info text-dark me-1">${n}</span>`).join('') : '<small class="text-muted">Sin notas</small>';

        return `
            <tr class="${alerta ? 'table-warning' : ''}">
                <td class="ps-4"><div class="fw-bold">${est.nombre}</div></td>
                <td class="text-center"><span class="fw-bold">${promedioDisplay}</span></td>
                <td class="text-center">${alerta ? '<span class="badge bg-danger">Reprobado</span>' : '<span class="badge bg-success">Aprobado</span>'}</td>
                <td class="ps-4"><div class="d-flex gap-1 align-items-center">${ultimosHtml}</div></td>
            </tr>
        `;
    }).join('');

    historialContainer.innerHTML = `
        <div class="card border-0 shadow-sm rounded-4 p-4">
            <h5 class="fw-semibold mb-3">Historial de notas</h5>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th class="ps-4">Estudiante</th>
                            <th class="text-center">Promedio</th>
                            <th class="text-center">Estado</th>
                            <th class="ps-4">Últimas notas</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${rows}
                    </tbody>
                </table>
            </div>
        </div>
    `;
}

