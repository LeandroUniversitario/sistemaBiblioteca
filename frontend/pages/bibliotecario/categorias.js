// categorias.js
let modalCategoriaInstance = null;

document.addEventListener('DOMContentLoaded', () => {
    // Solo inicializar si es necesario algo al cargar el script, 
    // pero la carga se llama desde el HTML cuando se muestra la seccion.
});

window.cargarCategorias = async function() {
    try {
        const response = await fetch('http://localhost:8080/api/categorias');
        if (!response.ok) throw new Error('Error al cargar categorías');
        const data = await response.json();
        
        const tbody = document.querySelector('#tablaCategorias tbody');
        tbody.innerHTML = '';
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-light-50">No hay categorías registradas</td></tr>';
            return;
        }

        data.forEach(cat => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><span class="badge bg-secondary bg-opacity-25 text-secondary border border-secondary border-opacity-50">${cat.codigoCategoria}</span></td>
                <td class="fw-semibold text-white">${cat.nombreCategoria}</td>
                <td class="text-light-50">${cat.descripcion || '-'}</td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-info me-1" onclick='editarCategoria(${JSON.stringify(cat).replace(/'/g, "&#39;")})'><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-danger" onclick="eliminarCategoria(${cat.idCategoria})"><i class="bi bi-trash"></i></button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error(error);
        const tbody = document.querySelector('#tablaCategorias tbody');
        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-danger">Error al cargar datos</td></tr>';
    }
};

window.abrirModalCategoria = function() {
    document.getElementById('formCategoria').reset();
    document.getElementById('catId').value = '';
    document.getElementById('modalCategoriaLabel').textContent = 'Nueva Categoría';
    
    if (!modalCategoriaInstance) {
        modalCategoriaInstance = new bootstrap.Modal(document.getElementById('modalCategoria'));
    }
    modalCategoriaInstance.show();
};

window.editarCategoria = function(cat) {
    document.getElementById('formCategoria').reset();
    document.getElementById('catId').value = cat.idCategoria;
    document.getElementById('catNombre').value = cat.nombreCategoria;
    document.getElementById('catDescripcion').value = cat.descripcion || '';
    document.getElementById('modalCategoriaLabel').textContent = 'Editar Categoría';
    
    if (!modalCategoriaInstance) {
        modalCategoriaInstance = new bootstrap.Modal(document.getElementById('modalCategoria'));
    }
    modalCategoriaInstance.show();
};

window.guardarCategoria = async function() {
    const id = document.getElementById('catId').value;
    const nombre = document.getElementById('catNombre').value.trim();
    const descripcion = document.getElementById('catDescripcion').value.trim();
    
    if (!nombre) {
        alert('El nombre es obligatorio.');
        return;
    }

    const payload = {
        nombreCategoria: nombre,
        descripcion: descripcion
    };

    const method = id ? 'PUT' : 'POST';
    const url = id ? `http://localhost:8080/api/categorias/${id}` : 'http://localhost:8080/api/categorias';

    try {
        const response = await fetch(url, {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        
        const result = await response.json();
        
        if (response.ok && result.success) {
            modalCategoriaInstance.hide();
            cargarCategorias();
        } else {
            alert(result.message || 'Error al guardar la categoría');
        }
    } catch (error) {
        console.error(error);
        alert('Ocurrió un error en la comunicación con el servidor.');
    }
};

window.eliminarCategoria = async function(id) {
    if (!confirm('¿Está seguro de eliminar esta categoría?')) return;
    
    try {
        const response = await fetch(`http://localhost:8080/api/categorias/${id}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (response.ok && result.success) {
            cargarCategorias();
        } else {
            alert(result.message || 'Error al eliminar la categoría');
        }
    } catch (error) {
        console.error(error);
        alert('Ocurrió un error en la comunicación con el servidor.');
    }
};
