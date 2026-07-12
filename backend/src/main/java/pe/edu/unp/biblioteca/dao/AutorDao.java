package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.AutorDTO;

import java.util.List;
import java.util.Map;

@Repository
public class AutorDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<AutorDTO> listarAutores() {
        return jdbcTemplate.query("CALL sp_listar_autores()", (rs, rowNum) -> {
            AutorDTO dto = new AutorDTO();
            dto.setIdAutor(rs.getInt("id_autor"));
            dto.setNombre(rs.getString("nombre"));
            dto.setApellido(rs.getString("apellido"));
            dto.setNacionalidad(rs.getString("nacionalidad"));
            return dto;
        });
    }

    public AutorDTO obtenerPorId(Integer idAutor) {
        List<AutorDTO> list = jdbcTemplate.query("CALL sp_obtener_autor_por_id(?)", (rs, rowNum) -> {
            AutorDTO dto = new AutorDTO();
            dto.setIdAutor(rs.getInt("id_autor"));
            dto.setNombre(rs.getString("nombre"));
            dto.setApellido(rs.getString("apellido"));
            dto.setNacionalidad(rs.getString("nacionalidad"));
            return dto;
        }, idAutor);

        return list.isEmpty() ? null : list.get(0);
    }

    public void insertarAutor(AutorDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_insertar_autor");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_nacionalidad", dto.getNacionalidad());

        Map<String, Object> out = jdbcCall.execute(in);

        if (out.containsKey("p_id_autor")) {
            dto.setIdAutor((Integer) out.get("p_id_autor"));
        }
    }

    public void actualizarAutor(AutorDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_autor");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_autor", dto.getIdAutor())
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_nacionalidad", dto.getNacionalidad());

        jdbcCall.execute(in);
    }

    public void eliminarAutor(Integer idAutor) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_eliminar_autor");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_autor", idAutor);

        jdbcCall.execute(in);
    }
}
