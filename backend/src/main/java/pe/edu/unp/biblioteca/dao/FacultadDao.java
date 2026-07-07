package pe.edu.unp.biblioteca.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.FacultadDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Repository
public class FacultadDao {

    private final JdbcTemplate jdbcTemplate;

    public FacultadDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public FacultadDTO insertar(FacultadDTO facultad) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_insertar_facultad");

        SqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_nombre_facultad", facultad.getNombreFacultad());

        Map<String, Object> out = jdbcCall.execute(in);

        facultad.setIdFacultad((Integer) out.get("p_id_facultad"));
        facultad.setCodigoFacultad((String) out.get("p_codigo_facultad"));

        return facultad;
    }

    public void actualizar(FacultadDTO facultad) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_facultad");

        SqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_facultad", facultad.getIdFacultad())
                .addValue("p_nombre_facultad", facultad.getNombreFacultad());

        jdbcCall.execute(in);
    }

    public void eliminar(Integer idFacultad) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_eliminar_facultad");

        SqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_facultad", idFacultad);

        jdbcCall.execute(in);
    }

    @SuppressWarnings("unchecked")
    public List<FacultadDTO> listarTodas() {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_listar_facultades")
                .returningResultSet("rs", new FacultadRowMapper());

        Map<String, Object> out = jdbcCall.execute();
        return (List<FacultadDTO>) out.get("rs");
    }

    @SuppressWarnings("unchecked")
    public FacultadDTO obtenerPorId(Integer idFacultad) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_obtener_facultad_por_id")
                .returningResultSet("rs", new FacultadRowMapper());

        SqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_facultad", idFacultad);

        Map<String, Object> out = jdbcCall.execute(in);
        List<FacultadDTO> result = (List<FacultadDTO>) out.get("rs");

        if (result != null && !result.isEmpty()) {
            return result.get(0);
        }
        return null;
    }

    private static class FacultadRowMapper implements RowMapper<FacultadDTO> {
        @Override
        public FacultadDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new FacultadDTO(
                    rs.getInt("id_facultad"),
                    rs.getString("codigo_facultad"),
                    rs.getString("nombre_facultad")
            );
        }
    }
}
