document.addEventListener('DOMContentLoaded', () => {
    // Variable para la instancia de Choices
    let choicesCarrera = null;

    // Referencias a los enlaces
    const linkFacultades = document.getElementById('linkFacultades');
    const linkUsuarios = document.getElementById('linkUsuarios');
    
    // Referencias a los paneles
    const panelFacultades = document.getElementById('panelFacultades');
    const panelUsuarios = document.getElementById('panelUsuarios');
    
    // Navegación
    if(linkUsuarios && linkFacultades) {
        linkUsuarios.addEventListener('click', (e) => {
            e.preventDefault();
            linkUsuarios.classList.add('active', 'fw-semibold');
            linkUsuarios.classList.remove('text-light-50');
            linkFacultades.classList.remove('active', 'fw-semibold');
            linkFacultades.classList.add('text-light-50');
            
            panelFacultades.classList.add('d-none');
            panelUsuarios.classList.remove('d-none');
        });
        
        linkFacultades.addEventListener('click', (e) => {
            e.preventDefault();
            linkFacultades.classList.add('active', 'fw-semibold');
            linkFacultades.classList.remove('text-light-50');
            linkUsuarios.classList.remove('active', 'fw-semibold');
            linkUsuarios.classList.add('text-light-50');
            
            panelUsuarios.classList.add('d-none');
            panelFacultades.classList.remove('d-none');
        });
    }

    // Lógica del formulario de usuarios
    const regRol = document.getElementById('regRol');
    const seccionLector = document.getElementById('seccionLector');
    
    if(regRol) {
        regRol.addEventListener('change', (e) => {
            if(e.target.value === 'lector') {
                seccionLector.classList.remove('d-none');
            } else {
                seccionLector.classList.add('d-none');
            }
        });
    }

    // Cargar Carreras y configurar Choices.js
    async function cargarCarreras() {
        const selectCarrera = document.getElementById('regIdCarrera');
        if (!selectCarrera) return;

        try {
            const response = await fetch('http://localhost:8080/api/carreras');
            const carreras = await response.json();
            
            // Limpiar options
            selectCarrera.innerHTML = '<option value="">Seleccione una carrera...</option>';
            
            carreras.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.idCarrera;
                opt.textContent = `${c.nombreCarrera} (${c.nombreFacultad})`;
                selectCarrera.appendChild(opt);
            });

            // Inicializar Choices.js
            choicesCarrera = new Choices(selectCarrera, {
                searchEnabled: true,
                itemSelectText: '',
                placeholder: true,
                placeholderValue: 'Seleccione una carrera...',
                noResultsText: 'No se encontraron carreras',
                noChoicesText: 'No hay opciones',
                searchPlaceholderValue: 'Buscar carrera...'
            });
            
        } catch (error) {
            console.error('Error cargando carreras:', error);
            selectCarrera.innerHTML = '<option value="">Error al cargar carreras</option>';
        }
    }

    // Llamar a cargar carreras
    cargarCarreras();

    // Enviar formulario
    const formRegistroUsuario = document.getElementById('formRegistroUsuario');
    const registroAlert = document.getElementById('registroAlert');
    const btnRegistrar = document.getElementById('btnRegistrar');

    if(formRegistroUsuario) {
        formRegistroUsuario.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            // Ocultar alerta
            registroAlert.classList.add('d-none');
            
            // Recolectar datos
            const payload = {
                nombre: document.getElementById('regNombre').value,
                apellido: document.getElementById('regApellido').value,
                email: document.getElementById('regEmail').value,
                password: document.getElementById('regPassword').value,
                documentoIdentidad: document.getElementById('regDni').value,
                telefono: document.getElementById('regTelefono').value,
                rol: document.getElementById('regRol').value
            };
            
            // Si es lector, agregar campos extras
            if(payload.rol === 'lector') {
                payload.tipoLector = document.getElementById('regTipoLector').value;
                payload.codigoUniversitario = document.getElementById('regCodigoUniv').value;
                
                const idCarreraVal = document.getElementById('regIdCarrera').value;
                if(idCarreraVal) {
                    payload.idCarrera = parseInt(idCarreraVal);
                }
            }

            // Cambiar estado del botón
            btnRegistrar.disabled = true;
            btnRegistrar.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Registrando...';

            try {
                const response = await fetch('http://localhost:8080/api/usuarios/registrar', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                
                const data = await response.json();
                
                if (response.ok && data.success) {
                    showRegistroMsg(data.message, 'success');
                    formRegistroUsuario.reset();
                    if(choicesCarrera) choicesCarrera.setChoiceByValue(''); // Resetear el select
                    // Restaurar vista de lector
                    seccionLector.classList.remove('d-none');
                } else {
                    showRegistroMsg(data.message || 'Error al registrar', 'danger');
                }
            } catch (error) {
                console.error(error);
                showRegistroMsg('Error de conexión con el servidor.', 'danger');
            } finally {
                // Restaurar botón
                btnRegistrar.disabled = false;
                btnRegistrar.innerHTML = '<i class="bi bi-person-plus me-2"></i>Registrar Usuario';
            }
        });
    }

    function showRegistroMsg(msg, type) {
        registroAlert.textContent = msg;
        registroAlert.className = `alert alert-${type} mt-3 text-center`;
        registroAlert.classList.remove('d-none');
    }
});
