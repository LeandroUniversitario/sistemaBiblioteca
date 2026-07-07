package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.CarreraDao;
import pe.edu.unp.biblioteca.dto.CarreraDTO;

import java.util.List;

@Service
public class CarreraService {

    @Autowired
    private CarreraDao carreraDao;

    public List<CarreraDTO> listarCarreras() {
        return carreraDao.listarCarreras();
    }
}
