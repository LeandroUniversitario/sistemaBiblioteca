document.addEventListener('DOMContentLoaded', () => {
    configurarNavegacionLector();
});

function configurarNavegacionLector() {
    const links = {
        'linkExplorar': 'panelExplorar',
        'linkMisPrestamos': 'panelMisPrestamos',
        'linkMisMultas': 'panelMisMultas'
    };

    for (const [linkId, sectionId] of Object.entries(links)) {
        const link = document.getElementById(linkId);
        if (link) {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                
                // Actualizar UI del navbar
                document.querySelectorAll('.navbar-nav .nav-link').forEach(l => {
                    l.classList.remove('active', 'fw-semibold');
                    l.classList.add('text-light-50');
                });
                link.classList.remove('text-light-50');
                link.classList.add('active', 'fw-semibold');

                // Ocultar todas las secciones
                document.querySelectorAll('.tab-transition').forEach(el => el.classList.add('d-none'));

                // Mostrar seccion
                const targetSec = document.getElementById(sectionId);
                if (targetSec) {
                    targetSec.classList.remove('d-none');
                    // Cargar datos
                    if (sectionId === 'panelMisPrestamos') cargarMisPrestamos();
                    if (sectionId === 'panelMisMultas') cargarMisMultas();
                }
            });
        }
    }
}

async function cargarMisPrestamos() {
    const userInfo = JSON.parse(localStorage.getItem('usuarioInfo') || '{}');
    const idLector = userInfo.idUsuario;
    
    if (!idLector) return;

    try {
        const tbody = document.getElementById('tbodyMisPrestamos');
        tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Cargando...</td></tr>';
        
        const prestamos = await fetchApi(`/prestamos/lector/${idLector}`);
        tbody.innerHTML = '';
        
        if (!prestamos || prestamos.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">No tienes historial de préstamos.</td></tr>';
            return;
        }
        
        prestamos.forEach(p => {
            let badgeClass = 'bg-secondary';
            if (p.estado === 'Activo') badgeClass = 'bg-success';
            if (p.estado === 'Vencido') badgeClass = 'bg-danger';
            if (p.estado === 'Devuelto') badgeClass = 'bg-info';

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="fw-bold">#${p.idPrestamo}</td>
                <td><small>${p.titulo}<br><span class="text-muted">Ejemplar: ${p.codigoEjemplar}</span></small></td>
                <td><small>${p.fechaPrestamo}</small></td>
                <td><small>${p.fechaLimite}</small></td>
                <td><small>${p.fechaDevolucion || '---'}</small></td>
                <td><span class="badge ${badgeClass}">${p.estado}</span></td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error('Error cargando préstamos:', error);
        document.getElementById('tbodyMisPrestamos').innerHTML = '<tr><td colspan="6" class="text-center text-danger py-4">Error cargando datos.</td></tr>';
    }
}

async function cargarMisMultas() {
    const userInfo = JSON.parse(localStorage.getItem('usuarioInfo') || '{}');
    const idLector = userInfo.idUsuario;
    
    if (!idLector) return;

    try {
        const tbody = document.getElementById('tbodyMisMultas');
        tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Cargando...</td></tr>';
        
        const multas = await fetchApi(`/multas/lector/${idLector}`);
        tbody.innerHTML = '';
        
        if (!multas || multas.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">No tienes historial de multas.</td></tr>';
            return;
        }
        
        multas.forEach(m => {
            let badgeClass = m.estado === 'Pagado' ? 'bg-success' : 'bg-danger';

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="fw-bold">#${m.idMulta}</td>
                <td><small>${m.libro}</small></td>
                <td class="fw-bold">S/ ${parseFloat(m.monto).toFixed(2)}</td>
                <td><small>${m.fechaGeneracion}</small></td>
                <td><small>${m.numeroComprobante || '---'}</small></td>
                <td><span class="badge ${badgeClass}">${m.estado}</span></td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error('Error cargando multas:', error);
        document.getElementById('tbodyMisMultas').innerHTML = '<tr><td colspan="6" class="text-center text-danger py-4">Error cargando datos.</td></tr>';
    }
}
