package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.EjemplarDTO;

import java.util.List;
import java.util.Map;

@Repository
public class EjemplarDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void insertarEjemplar(EjemplarDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_insertar_ejemplar");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_libro", dto.getIdLibro())
                .addValue("p_codigo_ejemplar", dto.getCodigoEjemplar())
                .addValue("p_ubicacion", dto.getUbicacion());

        Map<String, Object> out = jdbcCall.execute(in);
        if (out.containsKey("p_id_ejemplar")) {
            dto.setIdEjemplar((Integer) out.get("p_id_ejemplar"));
        }
    }

    public void actualizarEjemplar(EjemplarDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_ejemplar");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_ejemplar", dto.getIdEjemplar())
                .addValue("p_codigo_ejemplar", dto.getCodigoEjemplar())
                .addValue("p_ubicacion", dto.getUbicacion());

        jdbcCall.execute(in);
    }

    public void cambiarEstadoEjemplar(Integer idEjemplar, String codigoEstado) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_cambiar_estado_ejemplar");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_ejemplar", idEjemplar)
                .addValue("p_codigo_estado", codigoEstado);

        jdbcCall.execute(in);
    }

    public void eliminarEjemplar(Integer idEjemplar) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_eliminar_ejemplar");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_ejemplar", idEjemplar);

        jdbcCall.execute(in);
    }

    public List<EjemplarDTO> listarEjemplaresPorLibro(Integer idLibro) {
        return jdbcTemplate.query("CALL sp_listar_ejemplares_por_libro(?)", (rs, rowNum) -> {
            EjemplarDTO dto = new EjemplarDTO();
            dto.setIdEjemplar(rs.getInt("id_ejemplar"));
            dto.setCodigoEjemplar(rs.getString("codigo_ejemplar"));
            dto.setUbicacion(rs.getString("ubicacion"));
            dto.setEstado(rs.getString("estado"));
            return dto;
        }, idLibro);
    }

    public List<EjemplarDTO> listarEjemplaresDisponibles() {
        return jdbcTemplate.query("CALL sp_listar_ejemplares_disponibles()", (rs, rowNum) -> {
            EjemplarDTO dto = new EjemplarDTO();
            dto.setIdEjemplar(rs.getInt("id_ejemplar"));
            dto.setCodigoEjemplar(rs.getString("codigo_ejemplar"));
            dto.setUbicacion(rs.getString("ubicacion"));
            dto.setIdLibro(rs.getInt("id_libro"));
            dto.setTituloLibro(rs.getString("titulo"));
            return dto;
        });
    }
}
