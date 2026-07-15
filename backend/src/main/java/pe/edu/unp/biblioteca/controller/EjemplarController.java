package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.EjemplarDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.service.EjemplarService;

import java.util.List;

@RestController
@RequestMapping("/api/ejemplares")
public class EjemplarController {

    @Autowired
    private EjemplarService ejemplarService;

    @GetMapping("/disponibles")
    public ResponseEntity<List<EjemplarDTO>> listarEjemplaresDisponibles() {
        return ResponseEntity.ok(ejemplarService.listarEjemplaresDisponibles());
    }

    @GetMapping("/libro/{idLibro}")
    public ResponseEntity<List<EjemplarDTO>> listarEjemplaresPorLibro(@PathVariable Integer idLibro) {
        return ResponseEntity.ok(ejemplarService.listarEjemplaresPorLibro(idLibro));
    }

    @PostMapping
    public ResponseEntity<GenericResponseDTO> insertarEjemplar(@RequestBody EjemplarDTO dto) {
        GenericResponseDTO response = ejemplarService.insertarEjemplar(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping
    public ResponseEntity<GenericResponseDTO> actualizarEjemplar(@RequestBody EjemplarDTO dto) {
        GenericResponseDTO response = ejemplarService.actualizarEjemplar(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}/estado")
    public ResponseEntity<GenericResponseDTO> cambiarEstado(@PathVariable Integer id, @RequestParam String estado) {
        GenericResponseDTO response = ejemplarService.cambiarEstado(id, estado);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> eliminarEjemplar(@PathVariable Integer id) {
        GenericResponseDTO response = ejemplarService.eliminarEjemplar(id);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
}
