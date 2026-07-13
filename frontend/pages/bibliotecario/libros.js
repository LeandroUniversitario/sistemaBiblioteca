// libros.js

let modalLibroInstance = null;
let modalEjemplarInstance = null;
let choicesAutores = null;
let currentLibroIdParaEjemplares = null;
let listaAutoresGlobal = [];

window.cargarLibros = async function() {
    try {
        const response = await fetch('http://localhost:8080/api/libros');
        if (!response.ok) throw new Error('Error al cargar libros');
        const libros = await response.json();
        
        const tbody = document.querySelector('#tablaLibros tbody');
        tbody.innerHTML = '';
        
        if (libros.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-light-50 py-3">No hay libros registrados</td></tr>';
            return;
        }

        libros.forEach(libro => {
            // Badges para autores
            let autoresHtml = '';
            if (libro.autores) {
                const autoresArray = libro.autores.split(', ');
                autoresHtml = autoresArray.map(a => `<span class="badge bg-secondary bg-opacity-25 border border-secondary text-light mb-1 d-inline-block text-truncate" style="max-width: 150px;" title="${a}">${a}</span>`).join(' ');
            } else {
                autoresHtml = '<span class="text-light-50 small">Sin autores</span>';
            }

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><span class="badge bg-primary bg-opacity-25 text-primary border border-primary border-opacity-50">${libro.isbn}</span></td>
                <td>
                    <div class="fw-semibold text-white">${libro.titulo}</div>
                    <div class="small">${autoresHtml}</div>
                </td>
                <td class="text-light-50">${libro.nombreCategoria || 'Sin categoría'}</td>
                <td>
                    <span class="badge ${libro.ejemplaresDisponibles > 0 ? 'bg-success' : 'bg-danger'} rounded-pill">
                        ${libro.ejemplaresDisponibles} / ${libro.totalEjemplares}
                    </span>
                </td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-info me-1" title="Ver/Gestionar Ejemplares" onclick="verEjemplares(${libro.idLibro})"><i class="bi bi-collection"></i></button>
                    <button class="btn btn-sm btn-outline-warning me-1" title="Editar Libro" onclick='editarLibro(${JSON.stringify(libro).replace(/'/g, "&#39;")})'><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-danger" title="Dar de baja" onclick="eliminarLibro(${libro.idLibro})"><i class="bi bi-trash"></i></button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error(error);
        const tbody = document.querySelector('#tablaLibros tbody');
        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger py-3"><i class="bi bi-exclamation-triangle"></i> Error al cargar datos</td></tr>';
    }
}

// Cargar opciones para los selects en el modal (Categorías y Autores)
async function cargarOpcionesSelects() {
    try {
        // Cargar Categorías
        const resCat = await fetch('http://localhost:8080/api/categorias');
        const categorias = await resCat.json();
        const selectCat = document.getElementById('libroCategoria');
        selectCat.innerHTML = '<option value="">Seleccione...</option>';
        categorias.forEach(c => {
            selectCat.innerHTML += `<option value="${c.idCategoria}">${c.nombreCategoria}</option>`;
        });

        // Cargar Autores (Para Choices.js)
        const resAut = await fetch('http://localhost:8080/api/autores');
        listaAutoresGlobal = await resAut.json();
        
        const selectAutores = document.getElementById('libroAutores');
        
        // Destruir instancia previa de choices si existe
        if (choicesAutores) {
            choicesAutores.destroy();
        }

        // Limpiar y llenar
        selectAutores.innerHTML = '';
        const choicesOpciones = listaAutoresGlobal.map(a => ({
            value: a.idAutor,
            label: `${a.nombre} ${a.apellido}`
        }));

        choicesAutores = new Choices(selectAutores, {
            removeItemButton: true,
            searchPlaceholderValue: 'Buscar autor...',
            noResultsText: 'No se encontraron autores',
            itemSelectText: 'Presione enter para seleccionar'
        });
        choicesAutores.setChoices(choicesOpciones, 'value', 'label', true);

    } catch (error) {
        console.error("Error al cargar opciones de select:", error);
    }
}

window.abrirModalLibro = async function() {
    document.getElementById('formLibro').reset();
    document.getElementById('libroId').value = '';
    document.getElementById('modalLibroLabel').textContent = 'Nuevo Libro';
    
    // Si es nuevo libro, no permitimos asignar autores todavía (es más fácil asignarlos después de crearlo, o adaptar la API).
    // Nuestra API permite crearlos pero para simplificar, mostraremos el selector de autores solo al editar, o adaptaremos el guardado.
    // Vamos a permitirlo.
    document.getElementById('divLibroAutores').style.display = 'block';

    await cargarOpcionesSelects();

    if (!modalLibroInstance) {
        modalLibroInstance = new bootstrap.Modal(document.getElementById('modalLibro'));
    }
    modalLibroInstance.show();
}

window.editarLibro = async function(libroRow) {
    try {
        const response = await fetch(`http://localhost:8080/api/libros/${libroRow.idLibro}`);
        if (!response.ok) throw new Error("Error al obtener libro");
        const libro = await response.json();

        document.getElementById('formLibro').reset();
        document.getElementById('libroId').value = libro.idLibro;
        document.getElementById('libroTitulo').value = libro.titulo;
        document.getElementById('libroIsbn').value = libro.isbn;
        document.getElementById('libroAnio').value = libro.anioPublicacion || '';
        document.getElementById('libroEditorial').value = libro.editorial || '';
        
        document.getElementById('modalLibroLabel').textContent = 'Editar Libro';
        document.getElementById('divLibroAutores').style.display = 'block';

        await cargarOpcionesSelects();

        // Seleccionar categoría
        document.getElementById('libroCategoria').value = libro.idCategoria || '';

        // Seleccionar autores existentes
        if (libro.autores && choicesAutores && listaAutoresGlobal.length > 0) {
            const nombresAutores = libro.autores.split(', ');
            const autoresIds = nombresAutores.map(nombre => {
                const autor = listaAutoresGlobal.find(a => `${a.nombre} ${a.apellido}` === nombre);
                return autor ? autor.idAutor : null;
            }).filter(id => id !== null);
            
            choicesAutores.setChoiceByValue(autoresIds);
        }

        if (!modalLibroInstance) {
            modalLibroInstance = new bootstrap.Modal(document.getElementById('modalLibro'));
        }
        modalLibroInstance.show();
    } catch (e) {
        console.error(e);
        alert("Error al cargar los datos completos del libro.");
    }
}

window.guardarLibro = async function() {
    const id = document.getElementById('libroId').value;
    const titulo = document.getElementById('libroTitulo').value.trim();
    const isbn = document.getElementById('libroIsbn').value.trim();
    const idCategoria = document.getElementById('libroCategoria').value;
    const anioPublicacion = document.getElementById('libroAnio').value;
    const editorial = document.getElementById('libroEditorial').value.trim();
    
    if (!titulo || !isbn || !idCategoria) {
        alert("El título, ISBN y la categoría son obligatorios.");
        return;
    }

    const payload = {
        titulo: titulo,
        isbn: isbn,
        idCategoria: parseInt(idCategoria),
        anioPublicacion: anioPublicacion ? parseInt(anioPublicacion) : null,
        editorial: editorial || null
    };

    const url = 'http://localhost:8080/api/libros';
    const method = id ? 'PUT' : 'POST';

    try {
        const response = await fetch(url, {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        const result = await response.json();
        
        if (response.ok && result.success) {
            const autoresSeleccionados = choicesAutores ? choicesAutores.getValue(true) : [];
            const targetLibroId = id || result.data;
            
            if (targetLibroId && autoresSeleccionados.length > 0) {
                for (const idAutor of autoresSeleccionados) {
                    await fetch(`http://localhost:8080/api/libros/${targetLibroId}/autores/${idAutor}`, {
                        method: 'POST'
                    });
                }
            }

            modalLibroInstance.hide();
            cargarLibros();
        } else {
            alert(result.message || 'Error al guardar el libro');
        }
    } catch (error) {
        console.error(error);
        alert('Error de conexión al servidor');
    }
}

window.eliminarLibro = async function(id) {
    if (confirm("¿Estás seguro de dar de baja este libro? Los ejemplares podrían verse afectados.")) {
        try {
            const response = await fetch(`http://localhost:8080/api/libros/${id}`, {
                method: 'DELETE'
            });
            const result = await response.json();
            if (response.ok && result.success) {
                cargarLibros();
            } else {
                alert(result.message || "Error al eliminar");
            }
        } catch(e) {
            console.error(e);
            alert("Error de red");
        }
    }
}

// ==========================================
// EJEMPLARES
// ==========================================

window.verEjemplares = async function(libroId) {
    currentLibroIdParaEjemplares = libroId;
    document.getElementById('ejemplarLibroId').value = libroId;
    document.getElementById('formEjemplar').reset();
    
    await cargarEjemplaresList(libroId);
    
    if (!modalEjemplarInstance) {
        modalEjemplarInstance = new bootstrap.Modal(document.getElementById('modalEjemplar'));
    }
    modalEjemplarInstance.show();
}

async function cargarEjemplaresList(libroId) {
    try {
        const response = await fetch(`http://localhost:8080/api/ejemplares/libro/${libroId}`);
        const ejemplares = await response.json();
        
        const tbody = document.querySelector('#tablaEjemplaresList tbody');
        tbody.innerHTML = '';
        
        if (ejemplares.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-light-50 py-3">No hay ejemplares registrados</td></tr>';
            return;
        }

        ejemplares.forEach(ej => {
            let badgeClass = 'bg-secondary';
            if (ej.estado === 'DISPONIBLE') badgeClass = 'bg-success';
            if (ej.estado === 'PRESTADO') badgeClass = 'bg-warning text-dark';
            if (ej.estado === 'MANTENIMIENTO' || ej.estado === 'DAÑADO') badgeClass = 'bg-danger';

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><span class="text-white fw-bold">${ej.codigoEjemplar}</span></td>
                <td class="text-light-50">${ej.ubicacion || '-'}</td>
                <td><span class="badge ${badgeClass}">${ej.estado}</span></td>
                <td class="text-end">
                    ${ej.estado !== 'DAÑADO' && ej.estado !== 'BAJA' ? 
                      `<button class="btn btn-sm btn-outline-danger" title="Marcar como dañado" onclick="cambiarEstadoEjemplar(${ej.idEjemplar}, 'DAÑADO')"><i class="bi bi-x-octagon"></i></button>` : ''}
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (e) {
        console.error(e);
        const tbody = document.querySelector('#tablaEjemplaresList tbody');
        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-danger py-3">Error al cargar ejemplares</td></tr>';
    }
}

window.agregarEjemplar = async function() {
    const idLibro = currentLibroIdParaEjemplares;
    const codigo = document.getElementById('ejemplarCodigo').value.trim();
    const ubicacion = document.getElementById('ejemplarUbicacion').value.trim();

    if (!codigo || !ubicacion) {
        alert("El código y ubicación son obligatorios");
        return;
    }

    const payload = {
        idLibro: idLibro,
        codigoEjemplar: codigo,
        ubicacion: ubicacion
    };

    try {
        const response = await fetch('http://localhost:8080/api/ejemplares', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        const result = await response.json();
        if (response.ok && result.success) {
            document.getElementById('formEjemplar').reset();
            cargarEjemplaresList(idLibro);
            cargarLibros(); // Actualizar contador en tabla principal
        } else {
            alert(result.message || 'Error al agregar ejemplar');
        }
    } catch(e) {
        console.error(e);
        alert('Error de red');
    }
}

window.cambiarEstadoEjemplar = async function(idEjemplar, nuevoEstado) {
    if (confirm(`¿Marcar este ejemplar como ${nuevoEstado}?`)) {
        try {
            const response = await fetch(`http://localhost:8080/api/ejemplares/${idEjemplar}/estado?estado=${nuevoEstado}`, {
                method: 'PUT'
            });
            const result = await response.json();
            if (response.ok && result.success) {
                cargarEjemplaresList(currentLibroIdParaEjemplares);
                cargarLibros(); // Actualizar contadores
            } else {
                alert(result.message || 'Error al cambiar estado');
            }
        } catch(e) {
            console.error(e);
            alert('Error de red');
        }
    }
}
