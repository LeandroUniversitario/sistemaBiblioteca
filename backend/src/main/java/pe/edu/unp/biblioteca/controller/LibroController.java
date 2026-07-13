package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.AutorDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.LibroDTO;
import pe.edu.unp.biblioteca.service.LibroService;

import java.util.List;

@RestController
@RequestMapping("/api/libros")
@CrossOrigin(origins = "*")
public class LibroController {

    @Autowired
    private LibroService libroService;

    @GetMapping
    public ResponseEntity<List<LibroDTO>> listarLibros() {
        return ResponseEntity.ok(libroService.listarLibros());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LibroDTO> obtenerPorId(@PathVariable Integer id) {
        LibroDTO dto = libroService.obtenerPorId(id);
        if (dto != null) {
            return ResponseEntity.ok(dto);
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/buscar")
    public ResponseEntity<List<LibroDTO>> buscarLibros(@RequestParam String termino) {
        return ResponseEntity.ok(libroService.buscarLibros(termino));
    }

    @PostMapping
    public ResponseEntity<GenericResponseDTO> insertarLibro(@RequestBody LibroDTO dto) {
        GenericResponseDTO response = libroService.insertarLibro(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping
    public ResponseEntity<GenericResponseDTO> actualizarLibro(@RequestBody LibroDTO dto) {
        GenericResponseDTO response = libroService.actualizarLibro(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}/baja")
    public ResponseEntity<GenericResponseDTO> darBajaLibro(@PathVariable Integer id) {
        GenericResponseDTO response = libroService.darBajaLibro(id);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}/reactivar")
    public ResponseEntity<GenericResponseDTO> reactivarLibro(@PathVariable Integer id) {
        GenericResponseDTO response = libroService.reactivarLibro(id);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/{id}/autores/{idAutor}")
    public ResponseEntity<GenericResponseDTO> asignarAutor(@PathVariable Integer id, @PathVariable Integer idAutor) {
        GenericResponseDTO response = libroService.asignarAutor(id, idAutor);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @DeleteMapping("/{id}/autores/{idAutor}")
    public ResponseEntity<GenericResponseDTO> quitarAutor(@PathVariable Integer id, @PathVariable Integer idAutor) {
        GenericResponseDTO response = libroService.quitarAutor(id, idAutor);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @GetMapping("/{id}/autores")
    public ResponseEntity<List<AutorDTO>> listarAutoresPorLibro(@PathVariable Integer id) {
        return ResponseEntity.ok(libroService.listarAutoresPorLibro(id));
    }
}
