package pe.edu.unp.biblioteca.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.HashMap;
import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
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

    @GetMapping("/stats-bibliotecario")
    public Map<String, Integer> getStatsBibliotecario() {
        Map<String, Integer> stats = new HashMap<>();
        
        try {
            Map<String, Object> result = jdbcTemplate.queryForMap("CALL sp_dashboard_bibliotecario_stats()");
            
            Number librosDisponibles = (Number) result.get("librosDisponibles");
            Number titulosDisponibles = (Number) result.get("titulosDisponibles");
            Number prestamosActivos = (Number) result.get("prestamosActivos");
            Number devolucionesAtrasadas = (Number) result.get("devolucionesAtrasadas");

            stats.put("librosDisponibles", librosDisponibles != null ? librosDisponibles.intValue() : 0);
            stats.put("titulosDisponibles", titulosDisponibles != null ? titulosDisponibles.intValue() : 0);
            stats.put("prestamosActivos", prestamosActivos != null ? prestamosActivos.intValue() : 0);
            stats.put("devolucionesAtrasadas", devolucionesAtrasadas != null ? devolucionesAtrasadas.intValue() : 0);
        } catch (Exception e) {
            stats.put("librosDisponibles", 0);
            stats.put("titulosDisponibles", 0);
            stats.put("prestamosActivos", 0);
            stats.put("devolucionesAtrasadas", 0);
        }
        
        return stats;
    }

    @GetMapping("/prestamos-recientes")
    public List<Map<String, Object>> getPrestamosRecientes() {
        try {
            return jdbcTemplate.queryForList("CALL sp_dashboard_prestamos_recientes()");
        } catch (Exception e) {
            return java.util.Collections.emptyList();
        }
    }

    @GetMapping("/alertas-vencimiento")
    public List<Map<String, Object>> getAlertasVencimiento() {
        try {
            return jdbcTemplate.queryForList("CALL sp_dashboard_alertas_vencimiento()");
        } catch (Exception e) {
            return java.util.Collections.emptyList();
        }
    }
}
