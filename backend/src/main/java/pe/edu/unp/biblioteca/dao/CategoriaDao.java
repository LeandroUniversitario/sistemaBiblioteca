package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.CategoriaDTO;

import java.util.List;
import java.util.Map;

@Repository
public class CategoriaDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<CategoriaDTO> listarCategorias() {
        return jdbcTemplate.query("CALL sp_listar_categorias()", (rs, rowNum) -> {
            CategoriaDTO dto = new CategoriaDTO();
            dto.setIdCategoria(rs.getInt("id_categoria"));
            dto.setCodigoCategoria(rs.getString("codigo_categoria"));
            dto.setNombreCategoria(rs.getString("nombre_categoria"));
            dto.setDescripcion(rs.getString("descripcion"));
            return dto;
        });
    }

    public CategoriaDTO obtenerPorId(Integer idCategoria) {
        List<CategoriaDTO> list = jdbcTemplate.query("CALL sp_obtener_categoria_por_id(?)", (rs, rowNum) -> {
            CategoriaDTO dto = new CategoriaDTO();
            dto.setIdCategoria(rs.getInt("id_categoria"));
            dto.setCodigoCategoria(rs.getString("codigo_categoria"));
            dto.setNombreCategoria(rs.getString("nombre_categoria"));
            dto.setDescripcion(rs.getString("descripcion"));
            return dto;
        }, idCategoria);

        return list.isEmpty() ? null : list.get(0);
    }

    public void insertarCategoria(CategoriaDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_insertar_categoria");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_nombre_categoria", dto.getNombreCategoria())
                .addValue("p_descripcion", dto.getDescripcion());

        Map<String, Object> out = jdbcCall.execute(in);

        if (out.containsKey("p_id_categoria")) {
            dto.setIdCategoria((Integer) out.get("p_id_categoria"));
        }
        if (out.containsKey("p_codigo_categoria")) {
            dto.setCodigoCategoria((String) out.get("p_codigo_categoria"));
        }
    }

    public void actualizarCategoria(CategoriaDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_categoria");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_categoria", dto.getIdCategoria())
                .addValue("p_nombre_categoria", dto.getNombreCategoria())
                .addValue("p_descripcion", dto.getDescripcion());

        jdbcCall.execute(in);
    }

    public void eliminarCategoria(Integer idCategoria) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_eliminar_categoria");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_categoria", idCategoria);

        jdbcCall.execute(in);
    }
}
