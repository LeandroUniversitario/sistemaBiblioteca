// ============================================================
// prestamos.js – Módulo de Préstamos (Bibliotecario)
// ============================================================

/**
 * Carga la tabla de préstamos activos/vencidos
 */
async function cargarPrestamosActivos() {
    try {
        const prestamos = await fetchApi('/prestamos/activos');
        const tbody = document.getElementById('tbodyPrestamos');
        if (!tbody) return;

        if (!prestamos || prestamos.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-4">No hay préstamos activos en este momento.</td></tr>';
            return;
        }

        tbody.innerHTML = prestamos.map(p => {
            const badgeClass = p.estado === 'vencido'
                ? 'bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25'
                : 'bg-success bg-opacity-10 text-success border border-success border-opacity-25';
            const estadoLabel = p.estado === 'vencido' ? 'Vencido' : 'Activo';

            return `
                <tr>
                    <td>
                        <div class="fw-semibold">${p.titulo}</div>
                        <small class="text-muted">${p.codigoEjemplar}</small>
                    </td>
                    <td>${p.lector}</td>
                    <td>${formatFecha(p.fechaPrestamo)}</td>
                    <td>${formatFecha(p.fechaLimite)}</td>
                    <td><span class="badge ${badgeClass}">${estadoLabel}</span></td>
                    <td class="text-end">
                        <button class="btn btn-sm custom-btn-outline" onclick="confirmarDevolucion(${p.idPrestamo}, '${escapar(p.titulo)}', '${escapar(p.lector)}')">
                            <i class="bi bi-box-arrow-in-left me-1"></i>Devolver
                        </button>
                    </td>
                </tr>
            `;
        }).join('');
    } catch (error) {
        console.error('Error cargando préstamos:', error);
    }
}

/**
 * Abre el modal para registrar un nuevo préstamo
 */
async function abrirModalPrestamo() {
    // Limpiar selects
    const selectEjemplar = document.getElementById('prestamoEjemplar');
    const selectLector = document.getElementById('prestamoLector');
    document.getElementById('prestamoAlert').classList.add('d-none');

    selectEjemplar.innerHTML = '<option value="">Cargando ejemplares...</option>';
    selectLector.innerHTML = '<option value="">Cargando lectores...</option>';

    const modal = new bootstrap.Modal(document.getElementById('modalNuevoPrestamo'));
    modal.show();

    try {
        // Cargar ejemplares disponibles
        const ejemplares = await fetchApi('/ejemplares/disponibles');
        selectEjemplar.innerHTML = '<option value="">Seleccione un ejemplar...</option>';
        if (ejemplares && ejemplares.length > 0) {
            ejemplares.forEach(ej => {
                selectEjemplar.innerHTML += `<option value="${ej.idEjemplar}">${ej.codigoEjemplar} — ${ej.tituloLibro}</option>`;
            });
        } else {
            selectEjemplar.innerHTML = '<option value="">No hay ejemplares disponibles</option>';
        }

        // Cargar lectores activos
        const usuarios = await fetchApi('/usuarios');
        const lectores = usuarios.filter(u => u.rol === 'lector' && u.estado === 'activo');
        selectLector.innerHTML = '<option value="">Seleccione un lector...</option>';
        lectores.forEach(l => {
            selectLector.innerHTML += `<option value="${l.idUsuario}">${l.nombre} ${l.apellido} (${l.documentoIdentidad})</option>`;
        });
    } catch (error) {
        console.error('Error cargando datos del modal:', error);
    }
}

/**
 * Guarda un nuevo préstamo
 */
async function guardarPrestamo() {
    const idEjemplar = document.getElementById('prestamoEjemplar').value;
    const idLector = document.getElementById('prestamoLector').value;
    const alertDiv = document.getElementById('prestamoAlert');

    if (!idEjemplar || !idLector) {
        mostrarAlerta(alertDiv, 'Seleccione un ejemplar y un lector.', 'warning');
        return;
    }

    // Obtener ID del bibliotecario logueado
    const userInfo = JSON.parse(localStorage.getItem('usuarioInfo') || '{}');
    const idBibliotecario = userInfo.idUsuario;

    if (!idBibliotecario) {
        mostrarAlerta(alertDiv, 'Error: no se pudo identificar al bibliotecario. Inicie sesión nuevamente.', 'danger');
        return;
    }

    try {
        const result = await fetchApi('/prestamos', 'POST', {
            idEjemplar: parseInt(idEjemplar),
            idLector: parseInt(idLector),
            idBibliotecario: idBibliotecario
        });

        mostrarAlerta(alertDiv, result.message, 'success');

        // Recargar tabla después de 1.5 segundos
        setTimeout(async () => {
            bootstrap.Modal.getInstance(document.getElementById('modalNuevoPrestamo')).hide();
            cargarPrestamosActivos();
            
            // Mostrar ticket si existe idPrestamo
            if (result.data && result.data.idPrestamo) {
                mostrarTicket(result.data.idPrestamo);
            }
        }, 1500);
    } catch (error) {
        mostrarAlerta(alertDiv, error.message, 'danger');
    }
}

/**
 * Abre modal de confirmación para devolver un libro
 */
function confirmarDevolucion(idPrestamo, titulo, lector) {
    document.getElementById('devolucionPrestamoId').value = idPrestamo;
    document.getElementById('devolucionTitulo').textContent = titulo;
    document.getElementById('devolucionLector').textContent = lector;
    document.getElementById('devolucionAlert').classList.add('d-none');

    const modal = new bootstrap.Modal(document.getElementById('modalDevolucion'));
    modal.show();
}

/**
 * Ejecuta la devolución
 */
async function ejecutarDevolucion() {
    const idPrestamo = document.getElementById('devolucionPrestamoId').value;
    const alertDiv = document.getElementById('devolucionAlert');
    
    const btnConfirmar = document.querySelector('#modalDevolucion .btn-primary');
    const btnCancelar = document.querySelector('#modalDevolucion .btn-outline-secondary');
    
    if (btnConfirmar) {
        btnConfirmar.disabled = true;
        btnConfirmar.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Procesando...';
    }
    if (btnCancelar) btnCancelar.disabled = true;

    try {
        const result = await fetchApi(`/prestamos/${idPrestamo}/devolucion`, 'POST');

        const tipo = result.data && result.data.diasRetraso > 0 ? 'warning' : 'success';
        mostrarAlerta(alertDiv, result.message, tipo);

        setTimeout(() => {
            bootstrap.Modal.getInstance(document.getElementById('modalDevolucion')).hide();
            cargarPrestamosActivos();
            if (btnConfirmar) {
                btnConfirmar.disabled = false;
                btnConfirmar.innerHTML = 'Confirmar';
            }
            if (btnCancelar) btnCancelar.disabled = false;
        }, 2500);
    } catch (error) {
        mostrarAlerta(alertDiv, error.message, 'danger');
        if (btnConfirmar) {
            btnConfirmar.disabled = false;
            btnConfirmar.innerHTML = 'Confirmar';
        }
        if (btnCancelar) btnCancelar.disabled = false;
    }
}

// ============================================================
// Funciones de Ticket
// ============================================================

async function mostrarTicket(idPrestamo) {
    try {
        const ticket = await fetchApi(`/prestamos/${idPrestamo}/comprobante`);
        if (!ticket) return;

        document.getElementById('ticketNumero').textContent = ticket.numeroComprobante;
        document.getElementById('ticketEmision').textContent = formatFecha(ticket.fechaEmision);
        document.getElementById('ticketBibliotecario').textContent = ticket.nombreBibliotecario;
        document.getElementById('ticketLector').textContent = ticket.nombreLector;
        document.getElementById('ticketDocumento').textContent = ticket.documentoLector;
        document.getElementById('ticketLibro').textContent = ticket.tituloLibro;
        document.getElementById('ticketEjemplar').textContent = ticket.codigoEjemplar;
        document.getElementById('ticketLimite').textContent = formatFecha(ticket.fechaLimite);

        const modal = new bootstrap.Modal(document.getElementById('modalTicket'));
        modal.show();
    } catch (error) {
        console.error('Error al cargar comprobante:', error);
    }
}

function imprimirTicket() {
    const contenido = document.getElementById('ticketContent').innerHTML;
    const ventana = window.open('', 'PRINT', 'height=600,width=800');

    ventana.document.write('<html><head><title>Imprimir Ticket</title>');
    ventana.document.write('<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">');
    ventana.document.write('<style>');
    ventana.document.write('body { font-family: monospace; padding: 20px; }');
    ventana.document.write('@media print { body { padding: 0; } }');
    ventana.document.write('</style>');
    ventana.document.write('</head><body>');
    ventana.document.write(contenido);
    ventana.document.write('</body></html>');

    ventana.document.close();
    ventana.focus();

    setTimeout(() => {
        ventana.print();
        ventana.close();
    }, 500);
}

// ============================================================
// Utilidades
// ============================================================

function formatFecha(fechaStr) {
    if (!fechaStr) return '—';
    return fechaStr;
}

function escapar(str) {
    if (!str) return '';
    return str.replace(/'/g, "\\'").replace(/"/g, '&quot;');
}

function mostrarAlerta(div, mensaje, tipo) {
    div.className = `alert alert-${tipo} text-center`;
    div.textContent = mensaje;
    div.classList.remove('d-none');
}

// Exportar para navegación SPA
window.cargarPrestamosActivos = cargarPrestamosActivos;
