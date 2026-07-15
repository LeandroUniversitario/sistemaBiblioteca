package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dao.ParametroDao;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.ParametroDTO;

import java.util.List;

@RestController
@RequestMapping("/api/parametros")
@CrossOrigin(origins = "*")
public class ParametroController {

    @Autowired
    private ParametroDao parametroDao;

    @GetMapping
    public List<ParametroDTO> listarParametros() {
        return parametroDao.listarParametros();
    }

    @PostMapping
    public ResponseEntity<GenericResponseDTO> insertarParametro(@RequestBody ParametroDTO dto) {
        try {
            if (dto.getNombreParametro() == null || dto.getValor() == null) {
                return ResponseEntity.badRequest().body(new GenericResponseDTO(false, "Nombre y valor son requeridos."));
            }
            Integer id = parametroDao.insertarParametro(dto);
            if (id != null) {
                return ResponseEntity.ok(new GenericResponseDTO(true, "Parámetro insertado correctamente con ID: " + id));
            } else {
                return ResponseEntity.badRequest().body(new GenericResponseDTO(false, "No se pudo insertar el parámetro."));
            }
        } catch (Exception e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("Ya existe")) {
                return ResponseEntity.badRequest().body(new GenericResponseDTO(false, "El parámetro ya existe."));
            }
            return ResponseEntity.internalServerError().body(new GenericResponseDTO(false, "Error: " + msg));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> actualizarParametro(@PathVariable Integer id, @RequestBody ParametroDTO dto) {
        try {
            dto.setIdParametro(id);
            parametroDao.actualizarParametro(dto);
            return ResponseEntity.ok(new GenericResponseDTO(true, "Parámetro actualizado correctamente."));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(new GenericResponseDTO(false, "Error: " + e.getMessage()));
        }
    }
}
