let modalCarreraInstance;
let modalEliminarCarreraInstance;

// Asumiendo que la navegación ya existe en index.html o se maneja en otro script
// Añadiremos los listeners básicos para el panel si es necesario.
document.addEventListener('DOMContentLoaded', () => {
    // Inicializar modales
    modalCarreraInstance = new bootstrap.Modal(document.getElementById('modalCarrera'));
    modalEliminarCarreraInstance = new bootstrap.Modal(document.getElementById('modalEliminarCarrera'));
    
    // Cargar los datos iniciales
    cargarCarreras();
    cargarOpcionesFacultades();
    
    // Configurar menú de navegación (básico, si no se maneja centralmente)
    const linkCarreras = document.getElementById('linkCarreras');
    if (linkCarreras) {
        linkCarreras.addEventListener('click', (e) => {
            e.preventDefault();
            document.querySelectorAll('.tab-transition').forEach(el => el.classList.add('d-none'));
            document.getElementById('panelCarreras').classList.remove('d-none');
            
            // Activar link
            document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active', 'fw-semibold'));
            document.querySelectorAll('.nav-link').forEach(el => el.classList.add('text-light-50'));
            linkCarreras.classList.add('active', 'fw-semibold');
            linkCarreras.classList.remove('text-light-50');
        });
    }
});

async function cargarCarreras() {
    const tbody = document.getElementById('tbodyCarreras');
    try {
        const carreras = await fetchApi('/carreras');
        
        if (!carreras || carreras.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" class="text-center text-white-50 py-3">No hay carreras registradas</td></tr>`;
            return;
        }

        tbody.innerHTML = '';
        carreras.forEach(car => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${car.idCarrera}</td>
                <td>${car.codigoCarrera || '-'}</td>
                <td>${car.nombreCarrera}</td>
                <td>${car.nombreFacultad || '-'}</td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-info border-0 hover-glow" onclick="editarCarrera(${car.idCarrera})" title="Editar"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-danger border-0 hover-glow" onclick="eliminarCarrera(${car.idCarrera})" title="Eliminar"><i class="bi bi-trash"></i></button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger py-3">Error al cargar las carreras</td></tr>`;
        console.error('Error cargando carreras:', error);
    }
}

async function cargarOpcionesFacultades() {
    const select = document.getElementById('carreraFacultad');
    try {
        const facultades = await fetchApi('/facultades');
        if (facultades) {
            // Limpiar opciones previas excepto la primera
            select.innerHTML = '<option value="">Seleccione una facultad...</option>';
            facultades.forEach(fac => {
                // Asumimos que queremos mostrar todas, o solo las activas
                const option = document.createElement('option');
                option.value = fac.idFacultad;
                option.textContent = fac.nombreFacultad;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error cargando opciones de facultades:', error);
    }
}

function abrirModalCarrera() {
    document.getElementById('formCarrera').reset();
    document.getElementById('carreraId').value = '';
    document.getElementById('modalCarreraTitle').innerText = 'Nueva Carrera';
    modalCarreraInstance.show();
}

async function editarCarrera(id) {
    try {
        const car = await fetchApi(`/carreras/${id}`);
        if (car) {
            document.getElementById('carreraId').value = car.idCarrera;
            document.getElementById('carreraNombre').value = car.nombreCarrera;
            document.getElementById('carreraFacultad').value = car.idFacultad;
            
            document.getElementById('modalCarreraTitle').innerText = 'Editar Carrera';
            modalCarreraInstance.show();
        }
    } catch (error) {
        alert('Error al cargar datos de la carrera');
    }
}

async function guardarCarrera() {
    const id = document.getElementById('carreraId').value;
    const nombre = document.getElementById('carreraNombre').value;
    const idFacultad = document.getElementById('carreraFacultad').value;

    if (!nombre || !idFacultad) {
        alert('El nombre y la facultad son obligatorios');
        return;
    }

    const payload = {
        nombreCarrera: nombre,
        idFacultad: parseInt(idFacultad)
    };

    try {
        if (id) {
            // Actualizar
            payload.idCarrera = parseInt(id);
            await fetchApi(`/carreras/${id}`, 'PUT', payload);
        } else {
            // Crear
            await fetchApi('/carreras', 'POST', payload);
        }
        modalCarreraInstance.hide();
        cargarCarreras();
        
        // Refrescar las estadísticas si el dashboard de contadores existe
        if (typeof cargarEstadisticas === 'function') {
            cargarEstadisticas();
        }
        
        // Actualizar el combobox del modal de usuarios
        if (typeof cargarCarrerasEnSelect === 'function') {
            cargarCarrerasEnSelect();
        }
    } catch (error) {
        alert('Error al guardar: ' + error.message);
    }
}

function eliminarCarrera(id) {
    document.getElementById('carreraEliminarId').value = id;
    modalEliminarCarreraInstance.show();
}

async function confirmarEliminarCarrera() {
    const id = document.getElementById('carreraEliminarId').value;
    try {
        await fetchApi(`/carreras/${id}`, 'DELETE');
        modalEliminarCarreraInstance.hide();
        cargarCarreras();
        
        // Refrescar estadísticas
        if (typeof cargarEstadisticas === 'function') {
            cargarEstadisticas();
        }
        
        // Actualizar el combobox del modal de usuarios
        if (typeof cargarCarrerasEnSelect === 'function') {
            cargarCarrerasEnSelect();
        }
    } catch (error) {
        alert('Error al eliminar: ' + (error.message || 'Error desconocido'));
    }
}
