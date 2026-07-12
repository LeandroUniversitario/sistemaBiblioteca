package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.RegistroUsuarioDTO;
import pe.edu.unp.biblioteca.service.UsuarioService;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/registrar")
    public ResponseEntity<GenericResponseDTO> registrarUsuario(@RequestBody RegistroUsuarioDTO dto) {
        GenericResponseDTO response = usuarioService.registrarUsuario(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping
    public ResponseEntity<List<pe.edu.unp.biblioteca.dto.UsuarioListDTO>> listarTodos() {
        return ResponseEntity.ok(usuarioService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerPorId(@PathVariable Integer id, @RequestParam String rol) {
        pe.edu.unp.biblioteca.dto.UsuarioListDTO usuario = usuarioService.obtenerPorId(id, rol);
        if (usuario != null) {
            return ResponseEntity.ok(usuario);
        }
        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<GenericResponseDTO> actualizarUsuario(@PathVariable Integer id, @RequestBody RegistroUsuarioDTO dto) {
        dto.setIdUsuario(id);
        GenericResponseDTO response = usuarioService.actualizarUsuario(dto);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}/estado")
    public ResponseEntity<GenericResponseDTO> cambiarEstado(@PathVariable Integer id, @RequestParam String accion) {
        GenericResponseDTO response = usuarioService.cambiarEstado(id, accion);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }

    @PutMapping("/{id}/password")
    public ResponseEntity<GenericResponseDTO> cambiarPassword(@PathVariable Integer id, @RequestBody java.util.Map<String, String> body) {
        String nuevaPassword = body.get("password");
        GenericResponseDTO response = usuarioService.cambiarPassword(id, nuevaPassword);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
}
