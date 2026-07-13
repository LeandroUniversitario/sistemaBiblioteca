package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.LibroDao;
import pe.edu.unp.biblioteca.dto.AutorDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.LibroDTO;

import java.util.List;

@Service
public class LibroService {

    @Autowired
    private LibroDao libroDao;

    public List<LibroDTO> listarLibros() {
        return libroDao.listarLibros();
    }

    public LibroDTO obtenerPorId(Integer id) {
        return libroDao.obtenerPorId(id);
    }

    public List<LibroDTO> buscarLibros(String termino) {
        return libroDao.buscarLibros(termino);
    }

    public GenericResponseDTO insertarLibro(LibroDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            libroDao.insertarLibro(dto);
            response.setSuccess(true);
            response.setMessage("Libro registrado exitosamente.");
            response.setData(dto.getIdLibro());
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO actualizarLibro(LibroDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            libroDao.actualizarLibro(dto);
            response.setSuccess(true);
            response.setMessage("Libro actualizado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO darBajaLibro(Integer idLibro) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            libroDao.darBajaLibro(idLibro);
            response.setSuccess(true);
            response.setMessage("Libro dado de baja exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO reactivarLibro(Integer idLibro) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            libroDao.reactivarLibro(idLibro);
            response.setSuccess(true);
            response.setMessage("Libro reactivado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO asignarAutor(Integer idLibro, Integer idAutor) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            libroDao.asignarAutorLibro(idLibro, idAutor);
            response.setSuccess(true);
            response.setMessage("Autor asignado al libro exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO quitarAutor(Integer idLibro, Integer idAutor) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            libroDao.quitarAutorLibro(idLibro, idAutor);
            response.setSuccess(true);
            response.setMessage("Autor removido del libro exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public List<AutorDTO> listarAutoresPorLibro(Integer idLibro) {
        return libroDao.listarAutoresPorLibro(idLibro);
    }
}
