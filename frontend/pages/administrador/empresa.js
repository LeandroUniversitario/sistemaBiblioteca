document.addEventListener('DOMContentLoaded', () => {
    // Configurar menú de navegación para Empresa
    const linkEmpresa = document.getElementById('linkEmpresa');
    if (linkEmpresa) {
        linkEmpresa.addEventListener('click', (e) => {
            e.preventDefault();
            // Ocultar todos los paneles
            document.querySelectorAll('.tab-transition').forEach(el => el.classList.add('d-none'));
            document.getElementById('panelEmpresa').classList.remove('d-none');
            
            // Actualizar active state en links
            document.querySelectorAll('.nav-link').forEach(el => {
                el.classList.remove('active', 'fw-semibold');
                el.classList.add('text-light-50');
            });
            linkEmpresa.classList.add('active', 'fw-semibold');
            linkEmpresa.classList.remove('text-light-50');
            
            cargarEmpresa();
        });
    }
});

window.cargarEmpresa = async function() {
    try {
        const empresa = await fetchApi('/empresa');
        if (empresa) {
            document.getElementById('empresaId').value = empresa.idEmpresa || '';
            document.getElementById('empresaRazonSocial').value = empresa.razonSocial || '';
            document.getElementById('empresaRuc').value = empresa.ruc || '';
            document.getElementById('empresaDireccion').value = empresa.direccion || '';
            document.getElementById('empresaTelefono').value = empresa.telefonoContacto || '';
            document.getElementById('empresaLogo').value = empresa.logoUrl || '';
        }
    } catch (error) {
        console.error('Error cargando empresa:', error);
    }
};

window.actualizarEmpresa = async function() {
    const id = document.getElementById('empresaId').value;
    const razonSocial = document.getElementById('empresaRazonSocial').value.trim();
    const ruc = document.getElementById('empresaRuc').value.trim();
    const direccion = document.getElementById('empresaDireccion').value.trim();
    const telefono = document.getElementById('empresaTelefono').value.trim();
    const logo = document.getElementById('empresaLogo').value.trim();
    const alertBox = document.getElementById('empresaAlert');

    if (!razonSocial || !ruc || !direccion) {
        mostrarAlerta(alertBox, 'Los campos Razón Social, RUC y Dirección son obligatorios', 'warning');
        return;
    }

    const dto = {
        idEmpresa: id ? parseInt(id) : null,
        razonSocial: razonSocial,
        ruc: ruc,
        direccion: direccion,
        telefonoContacto: telefono,
        logoUrl: logo
    };

    try {
        const res = await fetchApi('/empresa', 'PUT', dto);
        
        mostrarAlerta(alertBox, res.message, 'success');
        cargarEmpresa();
    } catch (error) {
        mostrarAlerta(alertBox, error.message, 'danger');
    }
};

function mostrarAlerta(elemento, mensaje, tipo) {
    elemento.className = `alert alert-${tipo} text-center small mt-3`;
    elemento.textContent = mensaje;
    elemento.classList.remove('d-none');
    setTimeout(() => {
        elemento.classList.add('d-none');
    }, 4000);
}
