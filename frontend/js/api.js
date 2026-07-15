// Base URL del API Backend
const API_BASE_URL = 'http://localhost:8080/api';

/**
 * Función genérica para hacer peticiones al backend
 * @param {string} endpoint - Ejemplo: '/facultades'
 * @param {string} method - 'GET', 'POST', 'PUT', 'DELETE'
 * @param {object} body - Datos a enviar (opcional)
 */
async function fetchApi(endpoint, method = 'GET', body = null) {
    const headers = {
        'Content-Type': 'application/json'
    };

    const options = {
        method,
        headers,
    };

    if (body) {
        options.body = JSON.stringify(body);
    }

    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, options);
        
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.error || `Error HTTP: ${response.status}`);
        }

        // Si es 204 No Content u otro código 200 sin cuerpo, no fallamos
        if (response.status === 204) {
            return null;
        }

        const text = await response.text();
        return text ? JSON.parse(text) : null;
    } catch (error) {
        console.error(`Error en API ${endpoint}:`, error);
        throw error;
    }
}
