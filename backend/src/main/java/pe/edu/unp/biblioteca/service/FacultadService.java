package pe.edu.unp.biblioteca.service;

import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.FacultadDao;
import pe.edu.unp.biblioteca.dto.FacultadDTO;

import java.util.List;

@Service
public class FacultadService {

    private final FacultadDao facultadDao;

    public FacultadService(FacultadDao facultadDao) {
        this.facultadDao = facultadDao;
    }

    public FacultadDTO registrarFacultad(FacultadDTO facultad) {
        return facultadDao.insertar(facultad);
    }

    public void actualizarFacultad(Integer id, FacultadDTO facultad) {
        facultad.setIdFacultad(id);
        facultadDao.actualizar(facultad);
    }

    public void eliminarFacultad(Integer idFacultad) {
        facultadDao.eliminar(idFacultad);
    }

    public List<FacultadDTO> listarFacultades() {
        return facultadDao.listarTodas();
    }

    public FacultadDTO obtenerFacultad(Integer idFacultad) {
        return facultadDao.obtenerPorId(idFacultad);
    }
}
