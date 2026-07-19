document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');
    const loginAlert = document.getElementById('loginAlert');
    const btnLogin = document.getElementById('btnLogin');
    const btnText = document.getElementById('btnText');
    const btnSpinner = document.getElementById('btnSpinner');

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault(); // Evitar que se recargue la página

        const email = document.getElementById('username').value;
        const password = document.getElementById('password').value;

        // Limpiar alertas previas
        loginAlert.classList.add('d-none');
        
        // Mostrar spinner
        btnLogin.disabled = true;
        btnText.textContent = 'Verificando...';
        btnSpinner.classList.remove('d-none');

        try {
            const response = await fetch(`${API_BASE_URL}/auth/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();

            if (response.ok && data.success) {
                // Guardar info del usuario en localStorage por si se necesita
                localStorage.setItem('usuarioInfo', JSON.stringify(data));
                
                // Redirigir según el rol
                if (data.rol === 'administrador') {
                    window.location.href = 'pages/administrador/index.html';
                } else if (data.rol === 'bibliotecario') {
                    window.location.href = 'pages/bibliotecario/index.html';
                } else if (data.rol === 'lector') {
                    window.location.href = 'pages/lector/index.html';
                } else {
                    showError('Rol desconocido. Comuníquese con soporte.');
                }
            } else {
                showError(data.message || 'Error al iniciar sesión');
            }
        } catch (error) {
            console.error('Error de red:', error);
            showError('No se pudo conectar con el servidor. ¿El backend está corriendo?');
        } finally {
            // Restaurar botón
            btnLogin.disabled = false;
            btnText.textContent = 'Iniciar Sesión';
            btnSpinner.classList.add('d-none');
        }
    });

    function showError(message) {
        loginAlert.textContent = message;
        loginAlert.classList.remove('d-none');
    }

    // Lógica para restablecer contraseña
    const forgotPasswordForm = document.getElementById('forgotPasswordForm');
    const resetAlert = document.getElementById('resetAlert');
    const btnReset = document.getElementById('btnReset');
    const btnResetText = document.getElementById('btnResetText');
    const btnResetSpinner = document.getElementById('btnResetSpinner');

    if (forgotPasswordForm) {
        forgotPasswordForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const email = document.getElementById('resetEmail').value;
            const documentoIdentidad = document.getElementById('resetDocumento').value;
            const nuevaPassword = document.getElementById('resetNuevaPassword').value;
            const confirmarPassword = document.getElementById('resetConfirmarPassword').value;

            resetAlert.classList.add('d-none');
            resetAlert.classList.remove('alert-success', 'alert-danger');

            if (nuevaPassword !== confirmarPassword) {
                resetAlert.textContent = 'Las contraseñas no coinciden.';
                resetAlert.classList.add('alert-danger');
                resetAlert.classList.remove('d-none');
                return;
            }

            btnReset.disabled = true;
            btnResetText.textContent = 'Procesando...';
            btnResetSpinner.classList.remove('d-none');

            try {
                const response = await fetch(`${API_BASE_URL}/auth/restablecer-password`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, documentoIdentidad, nuevaPassword })
                });

                const data = await response.json();

                if (response.ok && data.success) {
                    resetAlert.textContent = data.message;
                    resetAlert.classList.add('alert-success');
                    resetAlert.classList.remove('d-none');
                    forgotPasswordForm.reset();
                } else {
                    resetAlert.textContent = data.message || 'Error al restablecer la contraseña';
                    resetAlert.classList.add('alert-danger');
                    resetAlert.classList.remove('d-none');
                }
            } catch (error) {
                console.error('Error:', error);
                resetAlert.textContent = 'No se pudo conectar con el servidor.';
                resetAlert.classList.add('alert-danger');
                resetAlert.classList.remove('d-none');
            } finally {
                btnReset.disabled = false;
                btnResetText.textContent = 'Restablecer Contraseña';
                btnResetSpinner.classList.add('d-none');
            }
        });
    }
});
