package pe.edu.unp.biblioteca.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.FacultadDTO;
import pe.edu.unp.biblioteca.service.FacultadService;

import java.util.List;

@RestController
@RequestMapping("/api/facultades")
public class FacultadController {

    private final FacultadService facultadService;

    public FacultadController(FacultadService facultadService) {
        this.facultadService = facultadService;
    }

    @PostMapping
    public ResponseEntity<FacultadDTO> registrarFacultad(@RequestBody FacultadDTO facultad) {
        FacultadDTO nuevaFacultad = facultadService.registrarFacultad(facultad);
        return new ResponseEntity<>(nuevaFacultad, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> actualizarFacultad(@PathVariable Integer id, @RequestBody FacultadDTO facultad) {
        facultadService.actualizarFacultad(id, facultad);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarFacultad(@PathVariable Integer id) {
        facultadService.eliminarFacultad(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @GetMapping
    public ResponseEntity<List<FacultadDTO>> listarFacultades() {
        List<FacultadDTO> lista = facultadService.listarFacultades();
        return new ResponseEntity<>(lista, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<FacultadDTO> obtenerFacultad(@PathVariable Integer id) {
        FacultadDTO facultad = facultadService.obtenerFacultad(id);
        if (facultad != null) {
            return new ResponseEntity<>(facultad, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
