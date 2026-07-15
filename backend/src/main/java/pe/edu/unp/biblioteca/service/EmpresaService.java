package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.EmpresaDao;
import pe.edu.unp.biblioteca.dto.EmpresaDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;

@Service
public class EmpresaService {

    @Autowired
    private EmpresaDao empresaDao;

    public EmpresaDTO obtenerEmpresa() {
        return empresaDao.obtenerEmpresa();
    }

    public GenericResponseDTO actualizarEmpresa(EmpresaDTO dto) {
        try {
            empresaDao.actualizarEmpresa(dto);
            return new GenericResponseDTO(true, "Datos de la institución actualizados correctamente.");
        } catch (Exception e) {
            return new GenericResponseDTO(false, "Error al actualizar los datos: " + e.getMessage());
        }
    }
}
