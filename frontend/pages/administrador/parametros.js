let parametrosGlobal = [];

document.addEventListener('DOMContentLoaded', () => {
    const linkParametros = document.getElementById('linkParametros');
    if(linkParametros) {
        linkParametros.addEventListener('click', (e) => {
            e.preventDefault();
            // Reset active classes
            document.querySelectorAll('.nav-link').forEach(link => {
                link.classList.remove('active', 'fw-semibold');
                link.classList.add('text-light-50');
            });
            // Set current active
            linkParametros.classList.add('active', 'fw-semibold');
            linkParametros.classList.remove('text-light-50');

            // Hide all panels
            document.querySelectorAll('.tab-transition').forEach(panel => {
                panel.classList.add('d-none');
            });

            // Show parametros panel
            const panel = document.getElementById('panelParametros');
            if (panel) panel.classList.remove('d-none');

            cargarParametros();
        });
    }
});

async function cargarParametros() {
    try {
        const parametros = await fetchApi('/parametros');
        parametrosGlobal = parametros;
        const tbody = document.getElementById('tbodyParametros');
        tbody.innerHTML = '';
        
        if (!parametros || parametros.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-white-50 py-3">No hay parámetros registrados.</td></tr>';
            return;
        }

        parametros.forEach(p => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${p.idParametro}</td>
                <td class="fw-bold">${p.nombreParametro}</td>
                <td><span class="badge bg-secondary bg-opacity-25 text-white border border-secondary">${p.valor}</span></td>
                <td class="text-light-50 small">${p.descripcion || ''}</td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-info custom-btn-outline me-2" onclick="abrirModalParametro(${p.idParametro})" title="Editar">
                        <i class="bi bi-pencil"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (e) {
        console.error(e);
        document.getElementById('tbodyParametros').innerHTML = `<tr><td colspan="5" class="text-center text-danger py-3">Error: ${e.message}</td></tr>`;
    }
}

function abrirModalParametro(id = null) {
    const modalEl = document.getElementById('modalParametro');
    const modal = new bootstrap.Modal(modalEl);
    const form = document.getElementById('formParametro');
    form.reset();

    if (id) {
        document.getElementById('modalParametroTitle').textContent = 'Editar Parámetro';
        const p = parametrosGlobal.find(x => x.idParametro === id);
        if (p) {
            document.getElementById('parametroId').value = p.idParametro;
            document.getElementById('parametroNombre').value = p.nombreParametro;
            document.getElementById('parametroNombre').readOnly = true; // El nombre suele no cambiar
            document.getElementById('parametroValor').value = p.valor;
            document.getElementById('parametroDescripcion').value = p.descripcion || '';
        }
    } else {
        document.getElementById('modalParametroTitle').textContent = 'Nuevo Parámetro';
        document.getElementById('parametroId').value = '';
        document.getElementById('parametroNombre').readOnly = false;
    }
    modal.show();
}

async function guardarParametro() {
    const id = document.getElementById('parametroId').value;
    const nombre = document.getElementById('parametroNombre').value.trim();
    const valor = document.getElementById('parametroValor').value.trim();
    const descripcion = document.getElementById('parametroDescripcion').value.trim();

    if (!nombre || !valor) {
        alert('Nombre y valor son obligatorios.');
        return;
    }

    const userInfo = JSON.parse(localStorage.getItem('usuarioInfo') || '{}');
    const idAdministrador = userInfo.idUsuario || 1; // Fallback to 1 if not found

    const payload = {
        nombreParametro: nombre,
        valor: valor,
        descripcion: descripcion,
        idAdministrador: idAdministrador
    };

    try {
        let res;
        if (id) {
            res = await fetchApi(`/parametros/${id}`, 'PUT', payload);
        } else {
            res = await fetchApi('/parametros', 'POST', payload);
        }
        
        alert(res.message || 'Parámetro guardado correctamente.');
        bootstrap.Modal.getInstance(document.getElementById('modalParametro')).hide();
        cargarParametros();
    } catch (e) {
        alert('Error: ' + e.message);
    }
}
