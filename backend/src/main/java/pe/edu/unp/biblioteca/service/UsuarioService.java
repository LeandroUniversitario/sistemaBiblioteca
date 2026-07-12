package pe.edu.unp.biblioteca.service;

import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.UsuarioDao;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.RegistroUsuarioDTO;

import java.util.List;
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

    public List<pe.edu.unp.biblioteca.dto.UsuarioListDTO> listarTodos() {
        return usuarioDao.listarTodos();
    }

    public pe.edu.unp.biblioteca.dto.UsuarioListDTO obtenerPorId(Integer id, String rol) {
        return usuarioDao.obtenerPorId(id, rol);
    }

    public GenericResponseDTO actualizarUsuario(RegistroUsuarioDTO dto) {
        try {
            if (dto.getRol() == null) {
                return new GenericResponseDTO(false, "Rol no especificado para actualizar.");
            }
            
            String rol = dto.getRol().toLowerCase();
            if (rol.equals("administrador")) {
                usuarioDao.actualizarAdministrador(dto);
            } else if (rol.equals("bibliotecario")) {
                usuarioDao.actualizarBibliotecario(dto);
            } else if (rol.equals("lector")) {
                usuarioDao.actualizarLector(dto);
            } else {
                return new GenericResponseDTO(false, "Rol no válido.");
            }
            return new GenericResponseDTO(true, "Usuario actualizado correctamente.");
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("MESSAGE_TEXT")) {
                return new GenericResponseDTO(false, "Error al actualizar: Revisar datos o duplicados.");
            }
            return new GenericResponseDTO(false, "Error de servidor: " + e.getMessage());
        }
    }

    public GenericResponseDTO cambiarEstado(Integer id, String accion) {
        try {
            usuarioDao.cambiarEstado(id, accion);
            return new GenericResponseDTO(true, "Estado actualizado correctamente.");
        } catch (Exception e) {
            return new GenericResponseDTO(false, "Error: " + e.getMessage());
        }
    }

    public GenericResponseDTO cambiarPassword(Integer id, String nuevaPassword) {
        try {
            if (nuevaPassword == null || nuevaPassword.trim().isEmpty()) {
                return new GenericResponseDTO(false, "La contraseña no puede estar vacía.");
            }
            String hashedPassword = BCrypt.hashpw(nuevaPassword, BCrypt.gensalt(12));
            int rows = usuarioDao.cambiarPassword(id, hashedPassword);
            if (rows > 0) {
                return new GenericResponseDTO(true, "Contraseña actualizada correctamente.");
            } else {
                return new GenericResponseDTO(false, "No se encontró el usuario indicado.");
            }
        } catch (Exception e) {
            return new GenericResponseDTO(false, "Error de servidor: " + e.getMessage());
        }
    }
}
