package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.ParametroDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Repository
public class ParametroDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<ParametroDTO> listarParametros() {
        return jdbcTemplate.query("CALL sp_listar_parametros()", new RowMapper<ParametroDTO>() {
            @Override
            public ParametroDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                ParametroDTO dto = new ParametroDTO();
                dto.setIdParametro(rs.getInt("id_parametro"));
                dto.setNombreParametro(rs.getString("nombre_parametro"));
                dto.setValor(rs.getString("valor"));
                dto.setDescripcion(rs.getString("descripcion"));
                dto.setFechaModificacion(rs.getTimestamp("fecha_modificacion"));
                dto.setIdAdministrador(rs.getInt("id_administrador"));
                return dto;
            }
        });
    }

    public void actualizarParametro(ParametroDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_actualizar_parametro");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_parametro", dto.getIdParametro())
                .addValue("p_valor", dto.getValor())
                .addValue("p_descripcion", dto.getDescripcion())
                .addValue("p_id_administrador", dto.getIdAdministrador());
        jdbcCall.execute(in);
    }

    public Integer insertarParametro(ParametroDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_insertar_parametro");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_nombre_parametro", dto.getNombreParametro())
                .addValue("p_valor", dto.getValor())
                .addValue("p_descripcion", dto.getDescripcion())
                .addValue("p_id_administrador", dto.getIdAdministrador());
        
        Map<String, Object> out = jdbcCall.execute(in);
        if (out != null && out.get("p_id_parametro") != null) {
            return ((Number) out.get("p_id_parametro")).intValue();
        }
        return null;
    }
}
