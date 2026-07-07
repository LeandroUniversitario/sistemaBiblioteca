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
            const response = await fetch('http://localhost:8080/api/auth/login', {
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
});
