package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.AutorDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.service.AutorService;

import java.util.List;

@RestController
@RequestMapping("/api/autores")
@CrossOrigin(origins = "*")
public class AutorController {

    @Autowired
    private AutorService autorService;

    @GetMapping
    public ResponseEntity<List<AutorDTO>> listarTodos() {
        return ResponseEntity.ok(autorService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AutorDTO> obtenerPorId(@PathVariable Integer id) {
        AutorDTO dto = autorService.obtenerPorId(id);
        if (dto != null) {
            return ResponseEntity.ok(dto);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<GenericResponseDTO> insertarAutor(@RequestBody AutorDTO dto) {
        GenericResponseDTO response = autorService.insertarAutor(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> actualizarAutor(@PathVariable Integer id, @RequestBody AutorDTO dto) {
        dto.setIdAutor(id);
        GenericResponseDTO response = autorService.actualizarAutor(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> eliminarAutor(@PathVariable Integer id) {
        GenericResponseDTO response = autorService.eliminarAutor(id);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
}
