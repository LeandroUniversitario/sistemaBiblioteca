// autores.js
let modalAutorInstance = null;

document.addEventListener('DOMContentLoaded', () => {
    // Inicialización si es necesario
});

window.cargarAutores = async function() {
    try {
        const response = await fetch('https://unp-biblioteca-api.loca.lt/api/autores');
        if (!response.ok) throw new Error('Error al cargar autores');
        const data = await response.json();
        
        const tbody = document.querySelector('#tablaAutores tbody');
        tbody.innerHTML = '';
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-light-50">No hay autores registrados</td></tr>';
            return;
        }

        data.forEach(autor => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td class="fw-semibold text-white">${autor.nombre}</td>
                <td class="text-white">${autor.apellido}</td>
                <td class="text-light-50">${autor.nacionalidad || '-'}</td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-info me-1" onclick='editarAutor(${JSON.stringify(autor).replace(/'/g, "&#39;")})'><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-danger" onclick="eliminarAutor(${autor.idAutor})"><i class="bi bi-trash"></i></button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error(error);
        const tbody = document.querySelector('#tablaAutores tbody');
        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-danger">Error al cargar datos</td></tr>';
    }
};

window.abrirModalAutor = function() {
    document.getElementById('formAutor').reset();
    document.getElementById('autorId').value = '';
    document.getElementById('modalAutorLabel').textContent = 'Nuevo Autor';
    
    if (!modalAutorInstance) {
        modalAutorInstance = new bootstrap.Modal(document.getElementById('modalAutor'));
    }
    modalAutorInstance.show();
};

window.editarAutor = function(autor) {
    document.getElementById('formAutor').reset();
    document.getElementById('autorId').value = autor.idAutor;
    document.getElementById('autorNombre').value = autor.nombre;
    document.getElementById('autorApellido').value = autor.apellido;
    document.getElementById('autorNacionalidad').value = autor.nacionalidad || '';
    document.getElementById('modalAutorLabel').textContent = 'Editar Autor';
    
    if (!modalAutorInstance) {
        modalAutorInstance = new bootstrap.Modal(document.getElementById('modalAutor'));
    }
    modalAutorInstance.show();
};

window.guardarAutor = async function() {
    const id = document.getElementById('autorId').value;
    const nombre = document.getElementById('autorNombre').value.trim();
    const apellido = document.getElementById('autorApellido').value.trim();
    const nacionalidad = document.getElementById('autorNacionalidad').value.trim();
    
    if (!nombre || !apellido) {
        alert('Nombre y apellido son obligatorios.');
        return;
    }

    const payload = {
        nombre: nombre,
        apellido: apellido,
        nacionalidad: nacionalidad
    };

    const method = id ? 'PUT' : 'POST';
    const url = id ? `https://unp-biblioteca-api.loca.lt/api/autores/${id}` : 'https://unp-biblioteca-api.loca.lt/api/autores';

    try {
        const response = await fetch(url, {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        
        const result = await response.json();
        
        if (response.ok && result.success) {
            modalAutorInstance.hide();
            cargarAutores();
        } else {
            alert(result.message || 'Error al guardar el autor');
        }
    } catch (error) {
        console.error(error);
        alert('Ocurrió un error en la comunicación con el servidor.');
    }
};

window.eliminarAutor = async function(id) {
    if (!confirm('¿Está seguro de eliminar este autor?')) return;
    
    try {
        const response = await fetch(`https://unp-biblioteca-api.loca.lt/api/autores/${id}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (response.ok && result.success) {
            cargarAutores();
        } else {
            alert(result.message || 'Error al eliminar el autor');
        }
    } catch (error) {
        console.error(error);
        alert('Ocurrió un error en la comunicación con el servidor.');
    }
};
