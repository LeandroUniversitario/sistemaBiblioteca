document.addEventListener('DOMContentLoaded', () => {
    configurarNavegacionLector();
    cargarLibrosRecomendados();
    configurarBuscadorLector();
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

const gradients = [
    'linear-gradient(45deg, #4361ee, #3f37c9)',
    'linear-gradient(45deg, #f72585, #b5179e)',
    'linear-gradient(45deg, #4cc9f0, #4895ef)',
    'linear-gradient(45deg, #ffb703, #fb8500)',
    'linear-gradient(45deg, #2a9d8f, #264653)',
    'linear-gradient(45deg, #e76f51, #f4a261)'
];

const badgeColors = [
    { bg: 'bg-primary', text: 'text-primary', border: 'border-primary' },
    { bg: 'bg-danger', text: 'text-danger', border: 'border-danger' },
    { bg: 'bg-info', text: 'text-info', border: 'border-info' },
    { bg: 'bg-warning', text: 'text-warning', border: 'border-warning' },
    { bg: 'bg-success', text: 'text-success', border: 'border-success' },
    { bg: 'bg-secondary', text: 'text-secondary', border: 'border-secondary' }
];

async function cargarLibrosRecomendados(query = '') {
    try {
        const contenedor = document.getElementById('contenedorLibrosRecomendados');
        const tituloSeccion = document.getElementById('tituloSeccionLibros');
        if (!contenedor) return;

        const libros = await fetchApi('/libros');
        if (!libros || libros.length === 0) {
            contenedor.innerHTML = '<div class="col-12 text-center text-white-50 py-4">No hay libros disponibles.</div>';
            return;
        }

        // Filtrar los que tengan al menos 1 ejemplar
        let librosDisponibles = libros.filter(l => l.totalEjemplares > 0);

        // Si hay un término de búsqueda, filtramos por título, autor o categoría
        if (query.trim() !== '') {
            const q = query.toLowerCase().trim();
            librosDisponibles = librosDisponibles.filter(l => 
                (l.titulo && l.titulo.toLowerCase().includes(q)) ||
                (l.autores && l.autores.toLowerCase().includes(q)) ||
                (l.nombreCategoria && l.nombreCategoria.toLowerCase().includes(q))
            );
            
            if (tituloSeccion) {
                tituloSeccion.innerHTML = `<i class="bi bi-search text-primary me-2"></i>Resultados de búsqueda`;
            }
        } else {
            if (tituloSeccion) {
                tituloSeccion.innerHTML = `<i class="bi bi-collection text-warning me-2"></i>Catálogo de Libros`;
            }
        }

        if (librosDisponibles.length === 0) {
            contenedor.innerHTML = `<div class="col-12 text-center text-white-50 py-4">No se encontraron resultados para "${query}".</div>`;
            return;
        }

        contenedor.innerHTML = '';
        
        // Mostrar todos los resultados
        const recomendados = librosDisponibles;

        recomendados.forEach((libro, index) => {
            const gradient = gradients[index % gradients.length];
            const badge = badgeColors[index % badgeColors.length];
            const categoria = libro.nombreCategoria || 'General';
            const autores = libro.autores || 'Sin autor';

            const div = document.createElement('div');
            div.className = 'col-md-3';
            div.innerHTML = `
                <div class="glass-card book-card h-100 p-0 overflow-hidden">
                    <div class="book-cover-placeholder p-4 text-center d-flex align-items-center justify-content-center" style="height: 200px; background: ${gradient};">
                        <i class="bi bi-book fs-1 text-white opacity-50"></i>
                    </div>
                    <div class="p-4">
                        <span class="badge ${badge.bg} bg-opacity-25 ${badge.text} border ${badge.border} border-opacity-50 mb-2">${categoria}</span>
                        <h5 class="fw-bold text-white mb-1">${libro.titulo}</h5>
                        <p class="text-light-50 small mb-3">${autores}</p>
                        <button class="btn btn-sm btn-outline-light w-100 custom-btn-outline d-none">Reservar</button>
                    </div>
                </div>
            `;
            contenedor.appendChild(div);
        });

    } catch (error) {
        console.error('Error cargando libros recomendados:', error);
        const contenedor = document.getElementById('contenedorLibrosRecomendados');
        if (contenedor) {
            contenedor.innerHTML = '<div class="col-12 text-center text-danger py-4">Error al cargar recomendaciones.</div>';
        }
    }
}

function configurarBuscadorLector() {
    const input = document.getElementById('inputBuscarLibro');
    const btn = document.getElementById('btnBuscarLibro');
    
    if (input && btn) {
        const ejecutarBusqueda = () => {
            const query = input.value;
            cargarLibrosRecomendados(query);
        };

        btn.addEventListener('click', ejecutarBusqueda);
        
        input.addEventListener('keyup', (e) => {
            if (e.key === 'Enter') {
                ejecutarBusqueda();
            }
        });
        
        // Si el usuario borra todo, recargar recomendaciones
        input.addEventListener('input', (e) => {
            if (e.target.value.trim() === '') {
                cargarLibrosRecomendados();
            }
        });
    }
}
