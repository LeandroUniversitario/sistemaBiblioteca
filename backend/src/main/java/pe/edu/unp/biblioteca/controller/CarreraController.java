package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.CarreraDTO;
import pe.edu.unp.biblioteca.service.CarreraService;

import java.util.List;

@RestController
@RequestMapping("/api/carreras")
@CrossOrigin(origins = "*")
public class CarreraController {

    @Autowired
    private CarreraService carreraService;

    @GetMapping
    public ResponseEntity<List<CarreraDTO>> listarCarreras() {
        List<CarreraDTO> carreras = carreraService.listarCarreras();
        return ResponseEntity.ok(carreras);
    }
}
