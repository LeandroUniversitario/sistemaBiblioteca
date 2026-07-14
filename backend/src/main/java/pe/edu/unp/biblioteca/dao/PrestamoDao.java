package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.ComprobantePrestamoDTO;
import pe.edu.unp.biblioteca.dto.PrestamoDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

@Repository
public class PrestamoDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final SimpleDateFormat SDF = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    /**
     * Llama a sp_registrar_prestamo.
     * Retorna un Map con las claves OUT: p_id_prestamo, p_numero_comprobante
     */
    public Map<String, Object> registrarPrestamo(Integer idEjemplar, Integer idLector, Integer idBibliotecario) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_registrar_prestamo");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_ejemplar", idEjemplar)
                .addValue("p_id_lector", idLector)
                .addValue("p_id_bibliotecario", idBibliotecario);

        return jdbcCall.execute(in);
    }

    /**
     * Llama a sp_registrar_devolucion.
     * Retorna un Map con las claves OUT: p_dias_retraso, p_monto_multa
     */
    public Map<String, Object> registrarDevolucion(Integer idPrestamo) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_registrar_devolucion");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_prestamo", idPrestamo);

        return jdbcCall.execute(in);
    }

    /**
     * Llama a sp_actualizar_prestamos_vencidos (mantenimiento).
     */
    public void actualizarPrestamosVencidos() {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_prestamos_vencidos");
        jdbcCall.execute();
    }

    /**
     * Llama a sp_listar_prestamos_activos.
     * Retorna lista de PrestamoDTO con préstamos activos y vencidos.
     */
    public List<PrestamoDTO> listarPrestamosActivos() {
        String sql = "CALL sp_listar_prestamos_activos()";
        return jdbcTemplate.query(sql, new PrestamoRowMapper());
    }

    /**
     * Llama a sp_obtener_prestamo_por_id.
     */
    public PrestamoDTO obtenerPorId(Integer idPrestamo) {
        String sql = "CALL sp_obtener_prestamo_por_id(?)";
        List<PrestamoDTO> list = jdbcTemplate.query(sql, new RowMapper<PrestamoDTO>() {
            @Override
            public PrestamoDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                PrestamoDTO dto = new PrestamoDTO();
                dto.setIdPrestamo(rs.getInt("id_prestamo"));
                dto.setIdEjemplar(rs.getInt("id_ejemplar"));
                dto.setTitulo(rs.getString("titulo"));
                dto.setCodigoEjemplar(rs.getString("codigo_ejemplar"));
                dto.setIdLector(rs.getInt("id_lector"));
                dto.setLector(rs.getString("lector"));
                dto.setIdBibliotecario(rs.getInt("id_bibliotecario"));
                dto.setBibliotecario(rs.getString("bibliotecario"));
                dto.setEstado(rs.getString("estado"));

                Timestamp fp = rs.getTimestamp("fecha_prestamo");
                dto.setFechaPrestamo(fp != null ? SDF.format(fp) : null);
                Timestamp fl = rs.getTimestamp("fecha_limite");
                dto.setFechaLimite(fl != null ? SDF.format(fl) : null);
                Timestamp fd = rs.getTimestamp("fecha_devolucion");
                dto.setFechaDevolucion(fd != null ? SDF.format(fd) : null);

                return dto;
            }
        }, idPrestamo);

        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Consulta directa a la tabla comprobante_prestamo
     */
    public ComprobantePrestamoDTO obtenerComprobantePorPrestamo(Integer idPrestamo) {
        String sql = "SELECT * FROM comprobante_prestamo WHERE id_prestamo = ?";
        List<ComprobantePrestamoDTO> list = jdbcTemplate.query(sql, new RowMapper<ComprobantePrestamoDTO>() {
            @Override
            public ComprobantePrestamoDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                ComprobantePrestamoDTO dto = new ComprobantePrestamoDTO();
                dto.setNumeroComprobante(rs.getString("numero_comprobante"));
                dto.setNombreLector(rs.getString("nombre_lector"));
                dto.setDocumentoLector(rs.getString("documento_lector"));
                dto.setTituloLibro(rs.getString("titulo_libro"));
                dto.setCodigoEjemplar(rs.getString("codigo_ejemplar"));
                dto.setNombreBibliotecario(rs.getString("nombre_bibliotecario"));
                
                Timestamp fp = rs.getTimestamp("fecha_prestamo");
                dto.setFechaPrestamo(fp != null ? SDF.format(fp) : null);
                Timestamp fl = rs.getTimestamp("fecha_limite");
                dto.setFechaLimite(fl != null ? SDF.format(fl) : null);
                Timestamp fe = rs.getTimestamp("fecha_emision");
                dto.setFechaEmision(fe != null ? SDF.format(fe) : null);
                
                return dto;
            }
        }, idPrestamo);

        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * RowMapper reutilizable para sp_listar_prestamos_activos
     */
    private class PrestamoRowMapper implements RowMapper<PrestamoDTO> {
        @Override
        public PrestamoDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            PrestamoDTO dto = new PrestamoDTO();
            dto.setIdPrestamo(rs.getInt("id_prestamo"));
            dto.setTitulo(rs.getString("titulo"));
            dto.setCodigoEjemplar(rs.getString("codigo_ejemplar"));
            dto.setLector(rs.getString("lector"));
            dto.setBibliotecario(rs.getString("bibliotecario"));
            dto.setEstado(rs.getString("estado"));

            Timestamp fp = rs.getTimestamp("fecha_prestamo");
            dto.setFechaPrestamo(fp != null ? SDF.format(fp) : null);
            Timestamp fl = rs.getTimestamp("fecha_limite");
            dto.setFechaLimite(fl != null ? SDF.format(fl) : null);

            return dto;
        }
    }
}
