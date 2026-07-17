package pe.edu.unp.biblioteca.service;

import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.AuthDao;
import pe.edu.unp.biblioteca.dto.LoginRequestDTO;
import pe.edu.unp.biblioteca.dto.LoginResponseDTO;

import java.util.Map;

@Service
public class AuthService {

    @Autowired
    private AuthDao authDao;

    public LoginResponseDTO login(LoginRequestDTO request) {
        LoginResponseDTO response = new LoginResponseDTO();

        if (request.getEmail() == null || request.getPassword() == null) {
            response.setSuccess(false);
            response.setMessage("El correo y la contraseña son obligatorios.");
            return response;
        }

        // Llamar al SP
        Map<String, Object> dbResult = authDao.loginUser(request.getEmail());

        Integer idUsuario = (Integer) dbResult.get("p_id_usuario");
        String passwordHash = (String) dbResult.get("p_password_hash");
        String rol = (String) dbResult.get("p_rol");
        String nombreCompleto = (String) dbResult.get("p_nombre_completo");
        String estadoCodigo = (String) dbResult.get("p_estado_codigo");

        // Validar si el usuario existe (idUsuario será null si no se encontró el email)
        if (idUsuario == null) {
            response.setSuccess(false);
            response.setMessage("Correo o contraseña incorrectos.");
            return response;
        }

        // Validar si está inactivo
        if ("inactivo".equalsIgnoreCase(estadoCodigo)) {
            response.setSuccess(false);
            response.setMessage("La cuenta de usuario está desactivada.");
            return response;
        }

        // Verificar la contraseña usando BCrypt
        boolean passwordMatch = false;
        try {
            passwordMatch = BCrypt.checkpw(request.getPassword(), passwordHash);
        } catch (Exception e) {
            // En caso de que el hash en DB sea inválido (por pruebas previas, etc.)
            passwordMatch = false;
        }

        if (!passwordMatch) {
            response.setSuccess(false);
            response.setMessage("Correo o contraseña incorrectos.");
            return response;
        }

        // Credenciales correctas
        response.setSuccess(true);
        response.setMessage("Inicio de sesión exitoso");
        response.setIdUsuario(idUsuario);
        response.setRol(rol);
        response.setNombreCompleto(nombreCompleto);
        response.setEstadoCodigo(estadoCodigo);

        return response;
    }

    public pe.edu.unp.biblioteca.dto.GenericResponseDTO restablecerPassword(pe.edu.unp.biblioteca.dto.RestablecerPasswordDTO request) {
        pe.edu.unp.biblioteca.dto.GenericResponseDTO response = new pe.edu.unp.biblioteca.dto.GenericResponseDTO();

        System.out.println("Restablecer Password DEBUG: Email=" + request.getEmail() + ", Documento=" + request.getDocumentoIdentidad() + ", NuevaPassword=" + request.getNuevaPassword());

        if (request.getEmail() == null || request.getDocumentoIdentidad() == null || request.getNuevaPassword() == null) {
            response.setSuccess(false);
            response.setMessage("El correo, el documento de identidad y la nueva contraseña son obligatorios.");
            return response;
        }

        // El nuevo hash será la contraseña proveída
        String nuevoHash = BCrypt.hashpw(request.getNuevaPassword(), BCrypt.gensalt());

        Map<String, Object> dbResult = authDao.restablecerPassword(request.getEmail(), request.getDocumentoIdentidad(), nuevoHash);

        Integer resultado = (Integer) dbResult.get("p_resultado");
        String mensaje = (String) dbResult.get("p_mensaje");

        if (resultado != null && resultado == 1) {
            response.setSuccess(true);
            response.setMessage(mensaje);
        } else {
            response.setSuccess(false);
            response.setMessage(mensaje != null ? mensaje : "Error desconocido al restablecer la contraseña.");
        }

        return response;
    }
}
