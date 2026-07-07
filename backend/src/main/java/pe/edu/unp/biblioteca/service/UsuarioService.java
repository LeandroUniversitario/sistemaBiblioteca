package pe.edu.unp.biblioteca.service;

import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.UsuarioDao;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.RegistroUsuarioDTO;

import java.util.Map;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioDao usuarioDao;

    public GenericResponseDTO registrarUsuario(RegistroUsuarioDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        
        try {
            // Validaciones básicas
            if (dto.getRol() == null || dto.getPassword() == null || dto.getEmail() == null) {
                response.setSuccess(false);
                response.setMessage("Datos incompletos. Faltan campos obligatorios.");
                return response;
            }

            // Hashear contraseña
            String hashedPassword = BCrypt.hashpw(dto.getPassword(), BCrypt.gensalt(12));

            // Llamar al SP correspondiente según el rol
            String rol = dto.getRol().toLowerCase();
            if (rol.equals("administrador")) {
                usuarioDao.registrarAdministrador(dto, hashedPassword);
            } else if (rol.equals("bibliotecario")) {
                usuarioDao.registrarBibliotecario(dto, hashedPassword);
            } else if (rol.equals("lector")) {
                usuarioDao.registrarLector(dto, hashedPassword);
            } else {
                response.setSuccess(false);
                response.setMessage("Rol no válido.");
                return response;
            }

            response.setSuccess(true);
            response.setMessage("Usuario registrado correctamente.");

        } catch (Exception e) {
            response.setSuccess(false);
            // Si es un error de la BD, normalmente extraemos el mensaje real
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("MESSAGE_TEXT")) {
                // Parsear un poco el error para mostrarlo limpio
                response.setMessage("Error al registrar: Revisar datos o duplicados.");
            } else {
                response.setMessage("Error de servidor: " + e.getMessage());
            }
        }

        return response;
    }
}
