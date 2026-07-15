package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.ComprobantePagoMultaDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.MultaDTO;
import pe.edu.unp.biblioteca.service.MultaService;

import java.util.List;

@RestController
@RequestMapping("/api/multas")
public class MultaController {

    @Autowired
    private MultaService multaService;

    @GetMapping("/pendientes")
    public ResponseEntity<List<MultaDTO>> listarMultasPendientes() {
        return ResponseEntity.ok(multaService.listarMultasPendientes());
    }

    @PostMapping("/{id}/pagar")
    public ResponseEntity<GenericResponseDTO> pagarMulta(@PathVariable("id") Integer idMulta, @RequestParam Integer idBibliotecario) {
        GenericResponseDTO response = multaService.pagarMulta(idMulta, idBibliotecario);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @GetMapping("/lector/{id}")
    public ResponseEntity<List<MultaDTO>> listarMultasPorLector(@PathVariable("id") Integer idLector) {
        return ResponseEntity.ok(multaService.listarMultasPorLector(idLector));
    }

    @GetMapping("/{id}/comprobante")
    public ResponseEntity<ComprobantePagoMultaDTO> obtenerComprobante(@PathVariable("id") Integer idMulta) {
        ComprobantePagoMultaDTO dto = multaService.obtenerComprobante(idMulta);
        if (dto != null) {
            return ResponseEntity.ok(dto);
        }
        return ResponseEntity.notFound().build();
    }
}
