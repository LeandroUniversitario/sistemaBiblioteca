package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.CarreraDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.service.CarreraService;

import java.util.List;

@RestController
@RequestMapping("/api/carreras")
public class CarreraController {

    @Autowired
    private CarreraService carreraService;

    @GetMapping
    public ResponseEntity<List<CarreraDTO>> listarCarreras() {
        List<CarreraDTO> carreras = carreraService.listarCarreras();
        return ResponseEntity.ok(carreras);
    }

    @GetMapping("/facultad/{id}")
    public ResponseEntity<List<CarreraDTO>> listarCarrerasPorFacultad(@PathVariable Integer id) {
        List<CarreraDTO> carreras = carreraService.listarCarrerasPorFacultad(id);
        return ResponseEntity.ok(carreras);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerPorId(@PathVariable Integer id) {
        CarreraDTO carrera = carreraService.obtenerPorId(id);
        if (carrera != null) {
            return ResponseEntity.ok(carrera);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<GenericResponseDTO> insertarCarrera(@RequestBody CarreraDTO dto) {
        GenericResponseDTO response = carreraService.insertarCarrera(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> actualizarCarrera(@PathVariable Integer id, @RequestBody CarreraDTO dto) {
        dto.setIdCarrera(id);
        GenericResponseDTO response = carreraService.actualizarCarrera(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> eliminarCarrera(@PathVariable Integer id) {
        GenericResponseDTO response = carreraService.eliminarCarrera(id);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
}
