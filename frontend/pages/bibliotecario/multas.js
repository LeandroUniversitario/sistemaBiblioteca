// Variables globales para modales
let modalPagarMulta = null;

document.addEventListener('DOMContentLoaded', () => {
    // Inicializar modales
    modalPagarMulta = new bootstrap.Modal(document.getElementById('modalPagarMulta'));
});

// Función para cargar multas pendientes
window.cargarMultasPendientes = async function() {
    try {
        const tbody = document.getElementById('tbodyMultas');
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-4">Cargando...</td></tr>';
        
        const multas = await fetchApi('/multas/pendientes');
        tbody.innerHTML = '';
        
        if (!multas || multas.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-4">No hay multas pendientes.</td></tr>';
            return;
        }
        
        multas.forEach(m => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="fw-bold">#${m.idMulta}</td>
                <td>${m.lector}</td>
                <td><small class="text-muted">${m.documentoIdentidad || 'N/A'}</small></td>
                <td><small>${m.libro}</small></td>
                <td class="fw-bold text-danger">S/ ${parseFloat(m.monto).toFixed(2)}</td>
                <td><small>${m.fechaGeneracion}</small></td>
                <td class="text-end">
                    <button class="btn btn-sm btn-warning text-dark me-1" onclick="abrirModalPagar(${m.idMulta}, '${m.lector}', ${m.monto})" title="Pagar Multa">
                        <i class="bi bi-cash-coin"></i> Pagar
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error('Error cargando multas:', error);
        document.getElementById('tbodyMultas').innerHTML = '<tr><td colspan="7" class="text-center text-danger py-4">Error cargando datos.</td></tr>';
    }
};

window.abrirModalPagar = function(idMulta, lector, monto) {
    document.getElementById('pagoMultaId').value = idMulta;
    document.getElementById('pagoMultaLector').textContent = lector;
    document.getElementById('pagoMultaMonto').textContent = parseFloat(monto).toFixed(2);
    
    const alertBox = document.getElementById('pagoMultaAlert');
    alertBox.classList.add('d-none');
    
    modalPagarMulta.show();
};

window.ejecutarPagoMulta = async function() {
    const idMulta = document.getElementById('pagoMultaId').value;
    const alertBox = document.getElementById('pagoMultaAlert');
    
    // Obtener ID del bibliotecario activo
    const userInfo = JSON.parse(localStorage.getItem('usuarioInfo') || '{}');
    const idBibliotecario = userInfo.idUsuario;
    
    if (!idBibliotecario) {
        mostrarAlerta(alertBox, 'Error: Sesión no válida.', 'danger');
        return;
    }
    
    try {
        const res = await fetchApi(`/multas/${idMulta}/pagar?idBibliotecario=${idBibliotecario}`, 'POST');
        
        mostrarAlerta(alertBox, res.message, 'success');
        setTimeout(() => {
            modalPagarMulta.hide();
            cargarMultasPendientes();
            
            // Opcional: Mostrar ticket (reutilizamos o creamos nuevo para multa)
            if (res.data && res.data.comprobante) {
                mostrarTicketMulta(res.data.comprobante, idMulta);
            }
        }, 1500);
    } catch (error) {
        mostrarAlerta(alertBox, error.message, 'danger');
    }
};

function mostrarAlerta(elemento, mensaje, tipo) {
    elemento.className = `alert alert-${tipo} text-center small mt-3`;
    elemento.textContent = mensaje;
    elemento.classList.remove('d-none');
}

window.mostrarTicketMulta = async function(comprobante, idMulta) {
    try {
        const datos = await fetchApi(`/multas/${idMulta}/comprobante`);
        // Asumiendo que existe el modal de ticket (reusamos del prestamo o creamos uno generico)
        const content = document.getElementById('ticketContent');
        if (content) {
            content.innerHTML = `
                <div class="text-center mb-3 border-bottom pb-2">
                    <h5 class="fw-bold mb-0">Comprobante de Pago</h5>
                    <small class="text-muted">N° ${datos.numeroComprobante}</small>
                </div>
                <div class="small mb-2">
                    <div><strong>Fecha:</strong> ${datos.fechaEmision}</div>
                    <div><strong>Lector:</strong> ${datos.nombreLector}</div>
                    <div><strong>Documento:</strong> ${datos.documentoLector}</div>
                </div>
                <div class="border text-center p-2 mb-2 bg-light">
                    <div class="fw-bold text-success mb-1">DETALLE DE MULTA PAGADA</div>
                    <div class="small">${datos.concepto}</div>
                    <div class="fw-bold fs-5 mt-2">S/ ${parseFloat(datos.monto).toFixed(2)}</div>
                </div>
                <div class="text-center small text-muted">
                    <p class="mb-0">Atendido por: ${datos.nombreBibliotecario}</p>
                </div>
            `;
            
            const modalTicket = new bootstrap.Modal(document.getElementById('modalTicket'));
            modalTicket.show();
        } else {
            alert(`Comprobante generado: ${datos.numeroComprobante}. Atendido por ${datos.bibliotecario}`);
        }
    } catch (error) {
        console.error('Error cargando ticket:', error);
    }
};
