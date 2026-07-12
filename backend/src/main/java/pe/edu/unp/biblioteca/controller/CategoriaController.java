package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.CategoriaDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.service.CategoriaService;

import java.util.List;

@RestController
@RequestMapping("/api/categorias")
@CrossOrigin(origins = "*")
public class CategoriaController {

    @Autowired
    private CategoriaService categoriaService;

    @GetMapping
    public ResponseEntity<List<CategoriaDTO>> listarTodos() {
        return ResponseEntity.ok(categoriaService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CategoriaDTO> obtenerPorId(@PathVariable Integer id) {
        CategoriaDTO dto = categoriaService.obtenerPorId(id);
        if (dto != null) {
            return ResponseEntity.ok(dto);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<GenericResponseDTO> insertarCategoria(@RequestBody CategoriaDTO dto) {
        GenericResponseDTO response = categoriaService.insertarCategoria(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> actualizarCategoria(@PathVariable Integer id, @RequestBody CategoriaDTO dto) {
        dto.setIdCategoria(id);
        GenericResponseDTO response = categoriaService.actualizarCategoria(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> eliminarCategoria(@PathVariable Integer id) {
        GenericResponseDTO response = categoriaService.eliminarCategoria(id);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
}
