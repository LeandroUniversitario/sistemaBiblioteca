package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.EjemplarDao;
import pe.edu.unp.biblioteca.dto.EjemplarDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;

import java.util.List;

@Service
public class EjemplarService {

    @Autowired
    private EjemplarDao ejemplarDao;

    public List<EjemplarDTO> listarEjemplaresDisponibles() {
        return ejemplarDao.listarEjemplaresDisponibles();
    }

    public List<EjemplarDTO> listarEjemplaresPorLibro(Integer idLibro) {
        return ejemplarDao.listarEjemplaresPorLibro(idLibro);
    }

    public GenericResponseDTO insertarEjemplar(EjemplarDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            ejemplarDao.insertarEjemplar(dto);
            response.setSuccess(true);
            response.setMessage("Ejemplar registrado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO actualizarEjemplar(EjemplarDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            ejemplarDao.actualizarEjemplar(dto);
            response.setSuccess(true);
            response.setMessage("Ejemplar actualizado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO cambiarEstado(Integer idEjemplar, String estado) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            ejemplarDao.cambiarEstadoEjemplar(idEjemplar, estado);
            response.setSuccess(true);
            response.setMessage("Estado del ejemplar actualizado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }

    public GenericResponseDTO eliminarEjemplar(Integer idEjemplar) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            ejemplarDao.eliminarEjemplar(idEjemplar);
            response.setSuccess(true);
            response.setMessage("Ejemplar eliminado exitosamente.");
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(e.getMessage());
        }
        return response;
    }
}
