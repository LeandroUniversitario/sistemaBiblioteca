let modalFacultadInstance;
let modalEliminarInstance;

document.addEventListener('DOMContentLoaded', () => {
    cargarEstadisticas();
    cargarFacultades();
    modalFacultadInstance = new bootstrap.Modal(document.getElementById('modalFacultad'));
    modalEliminarInstance = new bootstrap.Modal(document.getElementById('modalEliminarFacultad'));
    
    // Navegación
    const linkFacultades = document.getElementById('linkFacultades');
    const panelFacultades = document.getElementById('panelFacultades');
    if (linkFacultades) {
        linkFacultades.addEventListener('click', (e) => {
            e.preventDefault();
            document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active', 'fw-semibold'));
            document.querySelectorAll('.nav-link').forEach(el => el.classList.add('text-light-50'));
            
            linkFacultades.classList.add('active', 'fw-semibold');
            linkFacultades.classList.remove('text-light-50');
            
            document.querySelectorAll('.tab-transition').forEach(el => el.classList.add('d-none'));
            panelFacultades.classList.remove('d-none');
        });
    }
});

async function cargarFacultades() {
    const tbody = document.getElementById('tbodyFacultades');
    try {
        const facultades = await fetchApi('/facultades');
        
        if (!facultades || facultades.length === 0) {
            tbody.innerHTML = `<tr><td colspan="3" class="text-center text-white-50 py-3">No hay facultades registradas</td></tr>`;
            return;
        }

        tbody.innerHTML = '';
        facultades.forEach(fac => {
            const codigo = fac.codigoFacultad ? fac.codigoFacultad : '#FAC-' + fac.idFacultad;

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${codigo}</td>
                <td>${fac.nombreFacultad}</td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-info border-0 hover-glow" onclick="editarFacultad(${fac.idFacultad})" title="Editar"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-danger border-0 hover-glow" onclick="eliminarFacultad(${fac.idFacultad})" title="Eliminar"><i class="bi bi-trash"></i></button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        tbody.innerHTML = `<tr><td colspan="3" class="text-center text-danger py-3">Error al cargar las facultades</td></tr>`;
        console.error('Error cargando facultades:', error);
    }
}

async function cargarEstadisticas() {
    try {
        const stats = await fetchApi('/dashboard/stats');
        if (stats) {
            document.getElementById('countFacultades').innerText = stats.facultades || 0;
            document.getElementById('countCarreras').innerText = stats.carreras || 0;
            document.getElementById('countUsuarios').innerText = stats.usuarios || 0;
        }
    } catch (error) {
        console.error('Error cargando estadísticas:', error);
    }
}

function abrirModalFacultad() {
    document.getElementById('formFacultad').reset();
    document.getElementById('facultadId').value = '';
    document.getElementById('modalFacultadTitle').innerText = 'Nueva Facultad';
    modalFacultadInstance.show();
}

async function editarFacultad(id) {
    try {
        const fac = await fetchApi(`/facultades/${id}`);
        document.getElementById('facultadId').value = fac.idFacultad;
        document.getElementById('facultadNombre').value = fac.nombreFacultad;
        document.getElementById('facultadNombre').value = fac.nombreFacultad;
        
        document.getElementById('modalFacultadTitle').innerText = 'Editar Facultad';
        modalFacultadInstance.show();
    } catch (error) {
        alert('Error al cargar datos de la facultad');
    }
}

async function guardarFacultad() {
    const id = document.getElementById('facultadId').value;
    const nombre = document.getElementById('facultadNombre').value;

    if (!nombre) {
        alert('El nombre es obligatorio');
        return;
    }

    const payload = {
        nombreFacultad: nombre
    };

    try {
        if (id) {
            // Actualizar
            payload.idFacultad = parseInt(id);
            await fetchApi(`/facultades/${id}`, 'PUT', payload);
        } else {
            // Crear
            await fetchApi('/facultades', 'POST', payload);
        }
        modalFacultadInstance.hide();
        cargarFacultades();
    } catch (error) {
        alert('Error al guardar: ' + error.message);
    }
}

function eliminarFacultad(id) {
    document.getElementById('facultadEliminarId').value = id;
    modalEliminarInstance.show();
}

async function confirmarEliminarFacultad() {
    const id = document.getElementById('facultadEliminarId').value;
    try {
        await fetchApi(`/facultades/${id}`, 'DELETE');
        modalEliminarInstance.hide();
        cargarFacultades();
    } catch (error) {
        alert('Error al eliminar: ' + (error.message || 'Error desconocido'));
    }
}
