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

        // Si es 204 No Content, no intentamos parsear JSON
        if (response.status === 204) {
            return null;
        }

        return await response.json();
    } catch (error) {
        console.error(`Error en API ${endpoint}:`, error);
        throw error;
    }
}
