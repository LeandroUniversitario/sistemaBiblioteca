package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.CategoriaDao;
import pe.edu.unp.biblioteca.dto.CategoriaDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;

import java.util.List;

@Service
public class CategoriaService {

    @Autowired
    private CategoriaDao categoriaDao;

    public List<CategoriaDTO> listarTodos() {
        return categoriaDao.listarCategorias();
    }

    public CategoriaDTO obtenerPorId(Integer id) {
        return categoriaDao.obtenerPorId(id);
    }

    public GenericResponseDTO insertarCategoria(CategoriaDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            categoriaDao.insertarCategoria(dto);
            response.setSuccess(true);
            response.setMessage("Categoría registrada exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO actualizarCategoria(CategoriaDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            categoriaDao.actualizarCategoria(dto);
            response.setSuccess(true);
            response.setMessage("Categoría actualizada exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO eliminarCategoria(Integer id) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            categoriaDao.eliminarCategoria(id);
            response.setSuccess(true);
            response.setMessage("Categoría eliminada exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }
}
