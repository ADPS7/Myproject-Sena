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

    // 🔹 Cargar cursos del profesor
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

    // ==================== GUARDAR NOTA INDIVIDUAL (delegado en body para soportar tabla o cards) ====================
    if (!document.body.dataset.profNotasDelegateAttached) {
        document.body.dataset.profNotasDelegateAttached = '1';
        document.body.addEventListener('click', async (ev) => {
            const btn = ev.target.closest('.guardar-btn');
            if (!btn) return;

            const id = btn.dataset.id;
            const input = document.querySelector(`.nota-input[data-id="${id}"]`);
            if (!input) return;

            const nombreActividad = document.getElementById('nombreActividad') ? 
                                  document.getElementById('nombreActividad').value.trim() || "Evaluación" : "Evaluación";

            const raw = (input.value || '').toString().trim();
            const n = parseFloat(raw);

            notaFeedback.innerHTML = '';
            if (raw === '' || isNaN(n) || n < 0 || n > 5) {
                input.classList.add('is-invalid');
                notaFeedback.innerHTML = `<div class="alert alert-warning">Ingrese una nota válida entre 0 y 5.</div>`;
                return;
            }

            btn.disabled = true;
            try {
                const res = await fetch(`/notas`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ 
                        id_usuario: Number(id), 
                        id_modulo: Number(moduloSelect.value), 
                        nota: Number(n),
                        nombre: nombreActividad
                    })
                });
                const data = await res.json();
                if (data.success) {
                    notaFeedback.innerHTML = `<div class="alert alert-success">✅ Nota guardada: <strong>${nombreActividad}</strong></div>`;
                    input.classList.remove('is-invalid');
                    input.classList.add('is-valid');
                } else {
                    notaFeedback.innerHTML = `<div class="alert alert-danger">Error: ${data.error || 'No se pudo guardar'}</div>`;
                }
            } catch (err) {
                console.error(err);
                notaFeedback.innerHTML = `<div class="alert alert-danger">Error al guardar la nota.</div>`;
            } finally {
                btn.disabled = false;
            }
        });
    }

    // Validación en tiempo real (delegada)
    if (!document.body.dataset.profNotasInputAttached) {
        document.body.dataset.profNotasInputAttached = '1';
        document.body.addEventListener('input', (ev) => {
            const input = ev.target.closest('.nota-input');
            if (!input) return;
            const raw = (input.value || '').toString().trim();
            const btn = document.querySelector(`.guardar-btn[data-id="${input.dataset.id}"]`);
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

    // ==================== MOSTRAR ESTUDIANTES + APLICAR NOTAS EN LOTE ====================
    moduloSelect.addEventListener("change", () => {
        if (tablaEstudiantes) tablaEstudiantes.innerHTML = "";
        const listaContainer = document.getElementById('listaEstudiantesNotas');
        if (listaContainer) listaContainer.innerHTML = "";
        const moduloId = moduloSelect.value;
        selectedModuleName.textContent = moduloSelect.options[moduloSelect.selectedIndex].text || '—';

        if (moduloId) {
            if (viewAllNotasBtn) viewAllNotasBtn.disabled = false;

            fetch(`/notas/modulo/${moduloId}`)
                .then(res => res.json())
                .then(estudiantes => {
                        const seen = new Set();
                        if (tablaEstudiantes) tablaEstudiantes.innerHTML = '';
                        estudiantes.forEach(e => {
                            const studentId = e.id_usuario || e.id || e.user_id;
                            const sid = String(studentId);
                            if (seen.has(sid)) return;
                            seen.add(sid);

                            const studentName = e.nombre || `${e.nombres || ''} ${e.apellidos || ''}`.trim();
                            const studentEmail = e.correo || e.email || '';
                            const notaVal = (e.nota !== undefined && e.nota !== null) ? e.nota : '';

                            // Crear fila en la tabla de estudiantes
                            const fila = document.createElement("tr");
                            fila.innerHTML = `
                                <td>${studentName}</td>
                                <td>${studentEmail}</td>
                                <td><input type="number" class="form-control nota-input" min="0" max="5" step="0.1" data-id="${studentId}" value="${notaVal}"></td>
                                <td class="text-nowrap"><button class="btn btn-success btn-sm guardar-btn" data-id="${studentId}">Guardar</button></td>
                            `;
                            if (tablaEstudiantes) tablaEstudiantes.appendChild(fila);
                        });

                    const hasStudents = estudiantes && estudiantes.length > 0;
                    if (applyAllNotaBtn) applyAllNotaBtn.disabled = !hasStudents;
                    if (searchStudentInput) {
                        searchStudentInput.disabled = !hasStudents;
                        searchStudentInput.value = '';
                    }
                    filtrarEstudiantesPorNombre('');

                    // ==================== BOTÓN APLICAR NOTAS (CORREGIDO) ====================
                    if (applyAllNotaBtn && !applyAllNotaBtn.dataset.bulkAttached) {
                        applyAllNotaBtn.dataset.bulkAttached = '1';
                        applyAllNotaBtn.addEventListener('click', async () => {
                            const moduloIdLocal = moduloSelect.value;
                            const nombreActividad = document.getElementById('nombreActividad') ? 
                                                  document.getElementById('nombreActividad').value.trim() || "Evaluación" : "Evaluación";

                            notaFeedback.innerHTML = '';

                            const inputs = Array.from(document.querySelectorAll('.nota-input'));
                            if (!inputs.length) {
                                notaFeedback.innerHTML = `<div class="alert alert-secondary">No hay estudiantes listados.</div>`;
                                return;
                            }

                            inputs.forEach(i => i.classList.remove('is-invalid', 'is-valid'));
                            const updates = [];
                            let invalidCount = 0;

                            inputs.forEach(i => {
                                const raw = (i.value || '').toString().trim();
                                if (raw === '') return;
                                const n = parseFloat(raw);
                                if (isNaN(n) || n < 0 || n > 5) {
                                    i.classList.add('is-invalid');
                                    invalidCount++;
                                } else {
                                    i.classList.add('is-valid');
                                    updates.push({ 
                                        id: i.dataset.id, 
                                        nota: n,
                                        nombre: nombreActividad
                                    });
                                }
                            });

                            if (invalidCount > 0) {
                                notaFeedback.innerHTML = `<div class="alert alert-warning">Hay ${invalidCount} notas inválidas. Corríjalas antes de aplicar.</div>`;
                                return;
                            }

                            if (!updates.length) {
                                notaFeedback.innerHTML = `<div class="alert alert-warning">No hay notas válidas para guardar.</div>`;
                                return;
                            }

                            const guardarBtns = Array.from(document.querySelectorAll('.guardar-btn'));
                            guardarBtns.forEach(b => b.disabled = true);
                            applyAllNotaBtn.disabled = true;

                            try {
                                const promises = updates.map(u => {
                                    return fetch(`/notas`, {
                                        method: "POST",
                                        headers: { "Content-Type": "application/json" },
                                        body: JSON.stringify({ 
                                            id_usuario: Number(u.id), 
                                            id_modulo: Number(moduloIdLocal), 
                                            nota: Number(u.nota),
                                            nombre: u.nombre
                                        })
                                    })
                                    .then(res => res.json())
                                    .then(data => ({ id: u.id, ok: !!data.success }))
                                    .catch(() => ({ id: u.id, ok: false }));
                                });

                                const results = await Promise.all(promises);
                                const successCount = results.filter(r => r.ok).length;
                                const failCount = results.length - successCount;

                                if (successCount && !failCount) {
                                    notaFeedback.innerHTML = `<div class="alert alert-success">✅ ${successCount} notas guardadas correctamente (${nombreActividad})</div>`;
                                } else if (successCount && failCount) {
                                    notaFeedback.innerHTML = `<div class="alert alert-warning">${successCount} guardadas, ${failCount} fallaron.</div>`;
                                } else {
                                    notaFeedback.innerHTML = `<div class="alert alert-danger">No se pudieron guardar las notas.</div>`;
                                }
                            } catch (err) {
                                notaFeedback.innerHTML = `<div class="alert alert-danger">Error de conexión.</div>`;
                            } finally {
                                guardarBtns.forEach(b => b.disabled = false);
                                applyAllNotaBtn.disabled = false;
                            }
                        });
                    }
                });
        } else {
            if (viewAllNotasBtn) viewAllNotasBtn.disabled = true;
        }
    });

    // Ver historial de notas
    if (viewAllNotasBtn) {
        viewAllNotasBtn.addEventListener('click', () => {
            const moduloId = moduloSelect.value;
            const nombreModulo = selectedModuleName.textContent || '';
            if (!moduloId) return;
            verHistorialNotasModulo(moduloId, nombreModulo);
        });
    }
});

async function verHistorialNotasModulo(idModulo, nombreModulo) {
    const mostrarNotasDiv = document.getElementById('mostrarNotasProfesor');
    const mostrarHistorialDiv = document.getElementById('mostrarHistorialNotas');
    if (mostrarNotasDiv) mostrarNotasDiv.style.display = 'none';
    if (mostrarHistorialDiv) mostrarHistorialDiv.style.display = 'block';

    const titleEl = document.getElementById('historial-view-title');
    const subtitleEl = document.getElementById('historial-view-subtitle');
    if (titleEl) titleEl.innerText = nombreModulo || 'Notas del módulo';
    if (subtitleEl) subtitleEl.innerText = 'Historial detallado de calificaciones';

    const historialContainer = document.getElementById('historialNotasContainer');
    if (!historialContainer) return;

    historialContainer.innerHTML = `
        <div class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-3 text-muted">Cargando historial detallado...</p>
        </div>`;

    const backBtn = document.getElementById('historial-back-btn');
    if (backBtn) {
        backBtn.onclick = () => {
            if (mostrarHistorialDiv) mostrarHistorialDiv.style.display = 'none';
            if (mostrarNotasDiv) mostrarNotasDiv.style.display = 'block';
        };
    }

        try {
        // NUEVA RUTA PARA HISTORIAL DETALLADO
        const res = await fetch(`/notas/modulo/historial/${idModulo}`);
        const data = await res.json();
        
        if (data.error) {
            throw new Error(data.error);
        }
        
        renderizarHistorialNotas(data);
    } catch (err) {
        console.error(err);
        historialContainer.innerHTML = `
            <div class="alert alert-danger text-center py-4">
                <i class="bi bi-exclamation-triangle-fill"></i><br>
                No se pudo cargar el historial de notas.
            </div>`;
    }
}

function filtrarEstudiantesPorNombre(query) {
    const texto = (query || '').toLowerCase().trim();
    let visibleCount = 0;

    // Filtrar filas de tabla (fallback)
    const tbody = document.getElementById('tablaEstudiantes');
    if (tbody) {
        tbody.querySelectorAll('tr').forEach(row => {
            const nombre = (row.querySelector('td:nth-child(1)')?.textContent || '').toLowerCase();
            const correo = (row.querySelector('td:nth-child(2)')?.textContent || '').toLowerCase();
            const matches = !texto || nombre.includes(texto) || correo.includes(texto);
            row.style.display = matches ? '' : 'none';
            if (matches) visibleCount += 1;
        });
    }

    // Filtrar cards en lista de estudiantes
    const lista = document.getElementById('listaEstudiantesNotas');
    if (lista) {
        Array.from(lista.children).forEach(col => {
            const nombre = (col.querySelector('h5')?.textContent || '').toLowerCase();
            const correo = (col.querySelector('.text-muted')?.textContent || '').toLowerCase();
            const matches = !texto || nombre.includes(texto) || correo.includes(texto);
            col.style.display = matches ? '' : 'none';
            if (matches) visibleCount += 1;
        });
    }

    return visibleCount;
}


function renderizarHistorialNotas(list) {
    const container = document.getElementById('historialNotasContainer');
    if (!container) return;

    if (!Array.isArray(list) || list.length === 0) {
        container.innerHTML = `
            <div class="alert alert-info text-center py-5">
                <i class="bi bi-info-circle fs-1 mb-3 d-block"></i>
                <h5>Aún no hay notas registradas</h5>
                <p class="text-muted">Cuando califiques a los estudiantes aparecerán aquí.</p>
            </div>`;
        return;
    }

    const estudiantes = {};

    list.forEach(item => {
        const id = item.id_usuario;
        if (!estudiantes[id]) {
            estudiantes[id] = {
                nombre: item.nombre || 'Estudiante',
                correo: item.correo || '',
                notas: []
            };
        }
        if (item.nota !== null && item.nota !== undefined) {
            estudiantes[id].notas.push({
                actividad: item.nombre_actividad || 'Sin nombre',
                nota: parseFloat(item.nota).toFixed(1),
                fecha: item.fecha || ''
            });
        }
    });

    let html = `<div class="row g-4">`;

    Object.values(estudiantes).forEach(est => {
        const total = est.notas.length;
        const promedio = total > 0 
            ? (est.notas.reduce((sum, n) => sum + parseFloat(n.nota), 0) / total).toFixed(1) 
            : '—';
        const notasHTML = total > 0
            ? est.notas.map((n, index) => `
                <li class="list-group-item d-flex justify-content-between align-items-center py-3 px-0 border-0 border-bottom">
                    <div>
                        <strong class="actividad-nombre">${n.actividad}</strong>
                        ${n.fecha ? `<div class="small text-muted mt-1">${n.fecha}</div>` : ''}
                    </div>
                    <span class="badge bg-${parseFloat(n.nota) >= 3 ? 'success' : 'danger'} bg-opacity-10 text-${parseFloat(n.nota) >= 3 ? 'success' : 'danger'} rounded-pill py-2 px-3">
                        ${n.nota}
                    </span>
                </li>
            `).join('')
            : `
                <div class="alert alert-warning py-3 mb-0 small text-center">
                    Sin calificaciones
                </div>
            `;
        const mostrarScroll = total > 5;

        html += `
            <div class="col-12 col-md-6 col-xl-4 mb-4">
                <div class="card border-0 shadow-sm notas-card h-100">
                    <div class="card-body d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                            <div>
                                <small class="text-uppercase text-primary fw-bold">Estudiante</small>
                                <h5 class="fw-bold mt-2 mb-1">${est.nombre}</h5>
                                <p class="text-muted mb-0">${est.correo}</p>
                            </div>
                            <div class="text-end">
                                <span class="badge ${promedio !== '—' ? 'bg-success text-white' : 'bg-secondary text-white'} rounded-pill py-2 px-3">
                                    ${promedio !== '—' ? promedio + ' / 5.0' : 'Sin nota'}
                                </span>
                            </div>
                        </div>
                        ${total > 0 ? `
                            <div class="notas-scroll ${mostrarScroll ? 'has-scroll' : ''}" style="max-height: 18rem; overflow-y: auto;">
                                <ul class="list-group list-group-flush mb-0 notas-list">
                                    ${notasHTML}
                                </ul>
                            </div>
                            ${mostrarScroll ? '<p class="text-muted small mt-2 mb-0">Desplázate para ver más notas.</p>' : ''}
                        ` : notasHTML}
                    </div>
                </div>
            </div>`;
    });

    html += `</div>`;
    container.innerHTML = html;
}