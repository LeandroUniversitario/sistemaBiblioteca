let choicesCarrera = null;
let modalUsuarioInstance;
let modalEstadoUsuarioInstance;
let modalCambiarPasswordInstance;

document.addEventListener('DOMContentLoaded', () => {
    // Inicializar modals
    modalUsuarioInstance = new bootstrap.Modal(document.getElementById('modalUsuario'));
    modalEstadoUsuarioInstance = new bootstrap.Modal(document.getElementById('modalEstadoUsuario'));
    modalCambiarPasswordInstance = new bootstrap.Modal(document.getElementById('modalCambiarPassword'));

    // Navegación (Mejorada para manejar todas las pestañas)
    const linkUsuarios = document.getElementById('linkUsuarios');
    const linkFacultades = document.getElementById('linkFacultades');
    const linkCarreras = document.getElementById('linkCarreras');
    const panelUsuarios = document.getElementById('panelUsuarios');

    if(linkUsuarios) {
        linkUsuarios.addEventListener('click', (e) => {
            e.preventDefault();
            document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active', 'fw-semibold'));
            document.querySelectorAll('.nav-link').forEach(el => el.classList.add('text-light-50'));
            
            linkUsuarios.classList.add('active', 'fw-semibold');
            linkUsuarios.classList.remove('text-light-50');
            
            document.querySelectorAll('.tab-transition').forEach(el => el.classList.add('d-none'));
            panelUsuarios.classList.remove('d-none');
        });
    }

    // Comportamiento del combobox de rol en el modal
    const regRol = document.getElementById('regRol');
    const seccionLector = document.getElementById('seccionLector');

    if(regRol && seccionLector) {
        regRol.addEventListener('change', (e) => {
            if (e.target.value === 'lector') {
                seccionLector.classList.remove('d-none');
            } else {
                seccionLector.classList.add('d-none');
            }
        });
    }

    // Inicializar Choices para Carreras
    const regIdCarrera = document.getElementById('regIdCarrera');
    if (regIdCarrera) {
        choicesCarrera = new Choices(regIdCarrera, {
            searchEnabled: true,
            itemSelectText: '',
            noResultsText: 'No se encontraron carreras'
        });
    }

    // Cargar listas iniciales
    cargarCarrerasEnSelect();
    cargarUsuarios();

    // Evento de submit del formulario (para crear o actualizar)
    const formRegistro = document.getElementById('formRegistroUsuario');
    if (formRegistro) {
        formRegistro.addEventListener('submit', guardarUsuario);
    }
});

async function cargarUsuarios() {
    const tbody = document.getElementById('tbodyUsuarios');
    if (!tbody) return;

    try {
        const usuarios = await fetchApi('/usuarios');
        
        if (!usuarios || usuarios.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" class="text-center text-white-50 py-3">No hay usuarios registrados</td></tr>`;
            return;
        }

        tbody.innerHTML = '';
        usuarios.forEach(u => {
            const estadoTexto = u.estado || 'activo';
            const estadoBadge = estadoTexto.toLowerCase() === 'activo' 
                ? '<span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-50 px-2 py-1">Activo</span>'
                : '<span class="badge bg-danger bg-opacity-25 text-danger border border-danger border-opacity-50 px-2 py-1">Inactivo</span>';

            const esActivo = estadoTexto.toLowerCase() === 'activo';
            const iconEstado = esActivo ? 'bi-person-x' : 'bi-person-check';
            const colorEstado = esActivo ? 'btn-outline-danger' : 'btn-outline-success';
            const titleEstado = esActivo ? 'Desactivar' : 'Activar';

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${u.idUsuario}</td>
                <td>
                    <div class="fw-bold">${u.nombre} ${u.apellido}</div>
                    <div class="small text-light-50">${u.telefono || '-'}</div>
                </td>
                <td>
                    <div>${u.email}</div>
                    <div class="small text-light-50">DNI: ${u.documentoIdentidad}</div>
                </td>
                <td><span class="text-capitalize">${u.rol}</span></td>
                <td>${estadoBadge}</td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-warning border-0 hover-glow" onclick="abrirModalPassword(${u.idUsuario})" title="Cambiar Contraseña"><i class="bi bi-key"></i></button>
                    <button class="btn btn-sm btn-outline-info border-0 hover-glow" onclick="editarUsuario(${u.idUsuario}, '${u.rol}')" title="Editar"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm ${colorEstado} border-0 hover-glow" onclick="abrirModalEstadoUsuario(${u.idUsuario}, '${esActivo ? 'desactivar' : 'activar'}')" title="${titleEstado}"><i class="bi ${iconEstado}"></i></button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger py-3">Error al cargar usuarios</td></tr>`;
        console.error('Error:', error);
    }
}

async function cargarCarrerasEnSelect() {
    try {
        const carreras = await fetchApi('/carreras');
        if (carreras && choicesCarrera) {
            const options = carreras.map(c => ({
                value: c.idCarrera,
                label: `${c.nombreCarrera} (${c.codigoCarrera || 'Sin Cód'})`
            }));
            choicesCarrera.clearChoices();
            choicesCarrera.setChoices(options, 'value', 'label', true);
        }
    } catch (error) {
        console.error('Error cargando carreras para el select:', error);
    }
}

function abrirModalUsuario() {
    document.getElementById('formRegistroUsuario').reset();
    document.getElementById('usuarioId').value = '';
    document.getElementById('modalUsuarioTitle').innerText = 'Nuevo Usuario';
    
    // Recargar las carreras para que el combobox esté actualizado
    cargarCarrerasEnSelect();
    
    // Habilitar campos que no se pueden editar después
    document.getElementById('regEmail').disabled = false;
    document.getElementById('regDni').disabled = false;
    document.getElementById('regRol').disabled = false;
    document.getElementById('divPassword').classList.remove('d-none');
    document.getElementById('regPassword').required = true;
    
    // Disparar evento change para mostrar/ocultar sección lector
    document.getElementById('regRol').dispatchEvent(new Event('change'));

    const alertEl = document.getElementById('registroAlert');
    alertEl.classList.add('d-none');
    alertEl.classList.remove('alert-success', 'alert-danger');

    modalUsuarioInstance.show();
}

async function editarUsuario(id, rol) {
    try {
        const u = await fetchApi(`/usuarios/${id}?rol=${rol}`);
        if (!u) return;

        document.getElementById('usuarioId').value = u.idUsuario;
        document.getElementById('modalUsuarioTitle').innerText = 'Editar Usuario';
        
        document.getElementById('regNombre').value = u.nombre;
        document.getElementById('regApellido').value = u.apellido;
        document.getElementById('regEmail').value = u.email;
        document.getElementById('regDni').value = u.documentoIdentidad;
        document.getElementById('regTelefono').value = u.telefono || '';
        document.getElementById('regRol').value = u.rol;

        // Deshabilitar campos críticos en edición
        document.getElementById('regEmail').disabled = true;
        document.getElementById('regDni').disabled = true;
        document.getElementById('regRol').disabled = true;
        document.getElementById('divPassword').classList.add('d-none');
        document.getElementById('regPassword').required = false;

        document.getElementById('regRol').dispatchEvent(new Event('change'));

        if (u.rol === 'lector') {
            document.getElementById('regTipoLector').value = u.tipoLector;
            document.getElementById('regCodigoUniv').value = u.codigo;
            if (choicesCarrera && u.idCarrera) {
                choicesCarrera.setChoiceByValue(u.idCarrera);
            }
        }

        const alertEl = document.getElementById('registroAlert');
        alertEl.classList.add('d-none');

        modalUsuarioInstance.show();
    } catch (error) {
        alert('Error al cargar datos del usuario.');
        console.error(error);
    }
}

async function guardarUsuario(e) {
    if (e && typeof e.preventDefault === 'function') e.preventDefault();
    const id = document.getElementById('usuarioId').value;
    const alertEl = document.getElementById('registroAlert');
    const btnSubmit = document.getElementById('btnGuardarUsuario');
    
    alertEl.classList.add('d-none');
    alertEl.classList.remove('alert-success', 'alert-danger');
    btnSubmit.disabled = true;
    btnSubmit.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Guardando...';

    const payload = {
        nombre: document.getElementById('regNombre').value,
        apellido: document.getElementById('regApellido').value,
        telefono: document.getElementById('regTelefono').value,
        rol: document.getElementById('regRol').value,
    };

    // Si es nuevo usuario, enviamos todo
    if (!id) {
        payload.email = document.getElementById('regEmail').value;
        payload.documentoIdentidad = document.getElementById('regDni').value;
        payload.password = document.getElementById('regPassword').value;
    }

    if (payload.rol === 'lector') {
        payload.tipoLector = document.getElementById('regTipoLector').value;
        let cod = document.getElementById('regCodigoUniv').value;
        
        // Si no escribe código, usamos su DNI como código por defecto para evitar duplicados
        if (!cod || cod.trim() === '') {
            cod = document.getElementById('regDni').value;
        }
        payload.codigoUniversitario = cod;
        
        const carreraVal = document.getElementById('regIdCarrera').value;
        payload.idCarrera = (carreraVal && carreraVal.trim() !== '') ? parseInt(carreraVal, 10) : null;
    }

    try {
        let res;
        if (id) {
            res = await fetchApi(`/usuarios/${id}`, 'PUT', payload);
        } else {
            res = await fetchApi('/usuarios/registrar', 'POST', payload);
        }
        
        alertEl.textContent = res.message || 'Operación exitosa.';
        alertEl.classList.remove('alert-danger');
        alertEl.classList.add('alert-success');
        alertEl.classList.remove('d-none');
        
        setTimeout(() => {
            modalUsuarioInstance.hide();
            cargarUsuarios();
            if (typeof cargarEstadisticas === 'function') cargarEstadisticas();
        }, 1500);
        
    } catch (error) {
        alertEl.textContent = error.message || 'Ocurrió un error inesperado.';
        alertEl.classList.remove('alert-success');
        alertEl.classList.add('alert-danger');
        alertEl.classList.remove('d-none');
    } finally {
        btnSubmit.disabled = false;
        btnSubmit.innerHTML = 'Guardar';
    }
}

function abrirModalEstadoUsuario(id, accion) {
    document.getElementById('usuarioEstadoId').value = id;
    document.getElementById('usuarioEstadoAccion').value = accion;
    
    if (accion === 'activar') {
        document.getElementById('tituloEstadoUsuario').innerText = '¿Activar Usuario?';
        document.getElementById('mensajeEstadoUsuario').innerText = 'El usuario podrá volver a acceder al sistema.';
    } else {
        document.getElementById('tituloEstadoUsuario').innerText = '¿Desactivar Usuario?';
        document.getElementById('mensajeEstadoUsuario').innerText = 'El usuario no podrá acceder al sistema, pero su historial se mantendrá intacto.';
    }
    
    modalEstadoUsuarioInstance.show();
}

async function confirmarCambiarEstadoUsuario() {
    const id = document.getElementById('usuarioEstadoId').value;
    const accion = document.getElementById('usuarioEstadoAccion').value;
    
    try {
        await fetchApi(`/usuarios/${id}/estado?accion=${accion}`, 'PUT');
        modalEstadoUsuarioInstance.hide();
        cargarUsuarios();
        if (typeof cargarEstadisticas === 'function') cargarEstadisticas();
    } catch (error) {
        alert('Error al cambiar el estado: ' + error.message);
    }
}

function abrirModalPassword(id) {
    document.getElementById('passwordUsuarioId').value = id;
    document.getElementById('nuevaPassword').value = '';
    const alertEl = document.getElementById('passwordAlert');
    alertEl.classList.add('d-none');
    alertEl.classList.remove('alert-success', 'alert-danger');
    modalCambiarPasswordInstance.show();
}

async function guardarNuevaPassword() {
    const id = document.getElementById('passwordUsuarioId').value;
    const nuevaPassword = document.getElementById('nuevaPassword').value;
    const alertEl = document.getElementById('passwordAlert');
    
    if (!nuevaPassword) {
        alertEl.textContent = 'Debes ingresar una contraseña.';
        alertEl.classList.add('alert-danger');
        alertEl.classList.remove('d-none');
        return;
    }
    
    alertEl.classList.add('d-none');
    
    try {
        const res = await fetchApi(`/usuarios/${id}/password`, 'PUT', { password: nuevaPassword });
        alertEl.textContent = res.message || 'Contraseña actualizada.';
        alertEl.classList.remove('alert-danger');
        alertEl.classList.add('alert-success');
        alertEl.classList.remove('d-none');
        
        setTimeout(() => {
            modalCambiarPasswordInstance.hide();
        }, 1500);
    } catch (error) {
        alertEl.textContent = error.message || 'Error al actualizar.';
        alertEl.classList.remove('alert-success');
        alertEl.classList.add('alert-danger');
        alertEl.classList.remove('d-none');
    }
}
