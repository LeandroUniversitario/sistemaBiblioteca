package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.AutorDao;
import pe.edu.unp.biblioteca.dto.AutorDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;

import java.util.List;

@Service
public class AutorService {

    @Autowired
    private AutorDao autorDao;

    public List<AutorDTO> listarTodos() {
        return autorDao.listarAutores();
    }

    public AutorDTO obtenerPorId(Integer id) {
        return autorDao.obtenerPorId(id);
    }

    public GenericResponseDTO insertarAutor(AutorDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            autorDao.insertarAutor(dto);
            response.setSuccess(true);
            response.setMessage("Autor registrado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO actualizarAutor(AutorDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            autorDao.actualizarAutor(dto);
            response.setSuccess(true);
            response.setMessage("Autor actualizado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO eliminarAutor(Integer id) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            autorDao.eliminarAutor(id);
            response.setSuccess(true);
            response.setMessage("Autor eliminado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }
}
