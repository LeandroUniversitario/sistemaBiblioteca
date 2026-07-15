package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.CarreraDao;
import pe.edu.unp.biblioteca.dto.CarreraDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;

import java.util.List;

@Service
public class CarreraService {

    @Autowired
    private CarreraDao carreraDao;

    public List<CarreraDTO> listarCarreras() {
        return carreraDao.listarCarreras();
    }

    public List<CarreraDTO> listarCarrerasPorFacultad(Integer idFacultad) {
        return carreraDao.listarCarrerasPorFacultad(idFacultad);
    }

    public CarreraDTO obtenerPorId(Integer id) {
        return carreraDao.obtenerPorId(id);
    }

    public GenericResponseDTO insertarCarrera(CarreraDTO carrera) {
        try {
            Integer id = carreraDao.insertar(carrera);
            return new GenericResponseDTO(true, "Carrera insertada correctamente con ID " + id);
        } catch (Exception e) {
            return new GenericResponseDTO(false, "Error: " + e.getMessage());
        }
    }

    public GenericResponseDTO actualizarCarrera(CarreraDTO carrera) {
        try {
            carreraDao.actualizar(carrera);
            return new GenericResponseDTO(true, "Carrera actualizada correctamente.");
        } catch (Exception e) {
            return new GenericResponseDTO(false, "Error: " + e.getMessage());
        }
    }

    public GenericResponseDTO eliminarCarrera(Integer id) {
        try {
            carreraDao.eliminar(id);
            return new GenericResponseDTO(true, "Carrera eliminada correctamente.");
        } catch (Exception e) {
            return new GenericResponseDTO(false, "Error: " + e.getMessage());
        }
    }
}
