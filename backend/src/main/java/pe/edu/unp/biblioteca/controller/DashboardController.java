package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/stats")
    public Map<String, Integer> getStats() {
        Map<String, Integer> stats = new HashMap<>();
        
        try {
            Integer facultades = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM facultad", Integer.class);
            Integer carreras = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM carrera", Integer.class);
            
            String queryUsuarios = "SELECT COUNT(*) FROM usuario u " +
                                 "JOIN estado e ON u.id_estado = e.id_estado " +
                                 "WHERE e.entidad='usuario' AND e.codigo='activo'";
            Integer usuarios = jdbcTemplate.queryForObject(queryUsuarios, Integer.class);

            stats.put("facultades", facultades != null ? facultades : 0);
            stats.put("carreras", carreras != null ? carreras : 0);
            stats.put("usuarios", usuarios != null ? usuarios : 0);
        } catch (Exception e) {
            stats.put("facultades", 0);
            stats.put("carreras", 0);
            stats.put("usuarios", 0);
        }
        
        return stats;
    }
}
