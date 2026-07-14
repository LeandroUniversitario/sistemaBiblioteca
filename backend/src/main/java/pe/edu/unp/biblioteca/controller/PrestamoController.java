package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.PrestamoDTO;
import pe.edu.unp.biblioteca.dto.RegistroPrestamoDTO;
import pe.edu.unp.biblioteca.service.PrestamoService;

import java.util.List;

@RestController
@RequestMapping("/api/prestamos")
@CrossOrigin(origins = "*")
public class PrestamoController {

    @Autowired
    private PrestamoService prestamoService;

    @GetMapping("/activos")
    public ResponseEntity<List<PrestamoDTO>> listarPrestamosActivos() {
        return ResponseEntity.ok(prestamoService.listarPrestamosActivos());
    }

    @PostMapping
    public ResponseEntity<GenericResponseDTO> registrarPrestamo(@RequestBody RegistroPrestamoDTO dto) {
        GenericResponseDTO response = prestamoService.registrarPrestamo(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PostMapping("/{id}/devolucion")
    public ResponseEntity<GenericResponseDTO> registrarDevolucion(@PathVariable("id") Integer idPrestamo) {
        GenericResponseDTO response = prestamoService.registrarDevolucion(idPrestamo);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @GetMapping("/{id}/comprobante")
    public ResponseEntity<pe.edu.unp.biblioteca.dto.ComprobantePrestamoDTO> obtenerComprobante(@PathVariable("id") Integer idPrestamo) {
        pe.edu.unp.biblioteca.dto.ComprobantePrestamoDTO dto = prestamoService.obtenerComprobante(idPrestamo);
        if (dto != null) {
            return ResponseEntity.ok(dto);
        }
        return ResponseEntity.notFound().build();
    }
}
