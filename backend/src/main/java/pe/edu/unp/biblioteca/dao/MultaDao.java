package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.ComprobantePagoMultaDTO;
import pe.edu.unp.biblioteca.dto.MultaDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

@Repository
public class MultaDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final SimpleDateFormat SDF = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    /**
     * Llama a sp_pagar_multa.
     * Retorna un Map con la clave OUT: p_numero_comprobante
     */
    public Map<String, Object> pagarMulta(Integer idMulta, Integer idBibliotecario) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_pagar_multa");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_multa", idMulta)
                .addValue("p_id_bibliotecario", idBibliotecario);

        return jdbcCall.execute(in);
    }

    /**
     * Llama a sp_listar_multas_pendientes.
     */
    public List<MultaDTO> listarMultasPendientes() {
        return jdbcTemplate.query("CALL sp_listar_multas_pendientes()", new RowMapper<MultaDTO>() {
            @Override
            public MultaDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                MultaDTO dto = new MultaDTO();
                dto.setIdMulta(rs.getInt("id_multa"));
                dto.setMonto(rs.getBigDecimal("monto"));
                dto.setIdPrestamo(rs.getInt("id_prestamo"));
                dto.setTitulo(rs.getString("titulo"));
                dto.setLector(rs.getString("lector"));
                dto.setDocumentoIdentidad(rs.getString("documento_identidad"));
                dto.setEstado("pendiente");

                Timestamp fg = rs.getTimestamp("fecha_generacion");
                dto.setFechaGeneracion(fg != null ? SDF.format(fg) : null);

                return dto;
            }
        });
    }

    /**
     * Llama a sp_listar_multas_por_lector.
     */
    public List<MultaDTO> listarMultasPorLector(Integer idLector) {
        return jdbcTemplate.query("CALL sp_listar_multas_por_lector(?)", new RowMapper<MultaDTO>() {
            @Override
            public MultaDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                MultaDTO dto = new MultaDTO();
                dto.setIdMulta(rs.getInt("id_multa"));
                dto.setMonto(rs.getBigDecimal("monto"));
                dto.setIdPrestamo(rs.getInt("id_prestamo"));
                dto.setTitulo(rs.getString("titulo"));
                dto.setEstado(rs.getString("estado"));

                Timestamp fg = rs.getTimestamp("fecha_generacion");
                dto.setFechaGeneracion(fg != null ? SDF.format(fg) : null);
                Timestamp fp = rs.getTimestamp("fecha_pago");
                dto.setFechaPago(fp != null ? SDF.format(fp) : null);

                return dto;
            }
        }, idLector);
    }

    /**
     * Llama a sp_obtener_multa_por_id.
     */
    public MultaDTO obtenerPorId(Integer idMulta) {
        List<MultaDTO> list = jdbcTemplate.query("CALL sp_obtener_multa_por_id(?)", new RowMapper<MultaDTO>() {
            @Override
            public MultaDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                MultaDTO dto = new MultaDTO();
                dto.setIdMulta(rs.getInt("id_multa"));
                dto.setIdPrestamo(rs.getInt("id_prestamo"));
                dto.setMonto(rs.getBigDecimal("monto"));
                dto.setEstado(rs.getString("estado"));

                Timestamp fg = rs.getTimestamp("fecha_generacion");
                dto.setFechaGeneracion(fg != null ? SDF.format(fg) : null);
                Timestamp fp = rs.getTimestamp("fecha_pago");
                dto.setFechaPago(fp != null ? SDF.format(fp) : null);

                return dto;
            }
        }, idMulta);

        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Consulta directa a la tabla comprobante_pago_multa
     */
    public ComprobantePagoMultaDTO obtenerComprobantePorMulta(Integer idMulta) {
        String sql = "SELECT * FROM comprobante_pago_multa WHERE id_multa = ?";
        List<ComprobantePagoMultaDTO> list = jdbcTemplate.query(sql, new RowMapper<ComprobantePagoMultaDTO>() {
            @Override
            public ComprobantePagoMultaDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                ComprobantePagoMultaDTO dto = new ComprobantePagoMultaDTO();
                dto.setNumeroComprobante(rs.getString("numero_comprobante"));
                dto.setNombreLector(rs.getString("nombre_lector"));
                dto.setDocumentoLector(rs.getString("documento_lector"));
                dto.setConcepto(rs.getString("concepto"));
                dto.setMonto(rs.getBigDecimal("monto"));
                dto.setNombreBibliotecario(rs.getString("nombre_bibliotecario"));

                Timestamp fp = rs.getTimestamp("fecha_pago");
                dto.setFechaPago(fp != null ? SDF.format(fp) : null);
                Timestamp fe = rs.getTimestamp("fecha_emision");
                dto.setFechaEmision(fe != null ? SDF.format(fe) : null);

                return dto;
            }
        }, idMulta);

        return list.isEmpty() ? null : list.get(0);
    }
}
