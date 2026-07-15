package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.AutorDTO;
import pe.edu.unp.biblioteca.dto.LibroDTO;

import java.util.List;
import java.util.Map;

@Repository
public class LibroDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void insertarLibro(LibroDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_insertar_libro");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_titulo", dto.getTitulo())
                .addValue("p_isbn", dto.getIsbn())
                .addValue("p_id_categoria", dto.getIdCategoria())
                .addValue("p_anio_publicacion", dto.getAnioPublicacion())
                .addValue("p_editorial", dto.getEditorial());

        Map<String, Object> out = jdbcCall.execute(in);
        if (out.containsKey("p_id_libro")) {
            dto.setIdLibro((Integer) out.get("p_id_libro"));
        }
    }

    public void actualizarLibro(LibroDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_libro");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_libro", dto.getIdLibro())
                .addValue("p_titulo", dto.getTitulo())
                .addValue("p_isbn", dto.getIsbn())
                .addValue("p_id_categoria", dto.getIdCategoria())
                .addValue("p_anio_publicacion", dto.getAnioPublicacion())
                .addValue("p_editorial", dto.getEditorial());

        jdbcCall.execute(in);
    }

    public void darBajaLibro(Integer idLibro) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_dar_baja_libro");
        MapSqlParameterSource in = new MapSqlParameterSource().addValue("p_id_libro", idLibro);
        jdbcCall.execute(in);
    }

    public void reactivarLibro(Integer idLibro) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_reactivar_libro");
        MapSqlParameterSource in = new MapSqlParameterSource().addValue("p_id_libro", idLibro);
        jdbcCall.execute(in);
    }

    public List<LibroDTO> listarLibros() {
        return jdbcTemplate.query("CALL sp_listar_libros()", (rs, rowNum) -> {
            LibroDTO dto = new LibroDTO();
            dto.setIdLibro(rs.getInt("id_libro"));
            dto.setTitulo(rs.getString("titulo"));
            dto.setIsbn(rs.getString("isbn"));
            dto.setAnioPublicacion(rs.getInt("anio_publicacion"));
            dto.setEditorial(rs.getString("editorial"));
            dto.setNombreCategoria(rs.getString("nombre_categoria"));
            dto.setEstado(rs.getString("estado"));
            dto.setAutores(rs.getString("autores"));
            dto.setTotalEjemplares(rs.getInt("total_ejemplares"));
            dto.setEjemplaresDisponibles(rs.getInt("ejemplares_disponibles"));
            return dto;
        });
    }

    public LibroDTO obtenerPorId(Integer idLibro) {
        List<LibroDTO> list = jdbcTemplate.query("CALL sp_obtener_libro_por_id(?)", (rs, rowNum) -> {
            LibroDTO dto = new LibroDTO();
            dto.setIdLibro(rs.getInt("id_libro"));
            dto.setTitulo(rs.getString("titulo"));
            dto.setIsbn(rs.getString("isbn"));
            dto.setAnioPublicacion(rs.getInt("anio_publicacion"));
            dto.setEditorial(rs.getString("editorial"));
            dto.setIdCategoria(rs.getInt("id_categoria"));
            dto.setNombreCategoria(rs.getString("nombre_categoria"));
            dto.setEstado(rs.getString("estado"));
            dto.setAutores(rs.getString("autores"));
            dto.setTotalEjemplares(rs.getInt("total_ejemplares"));
            dto.setEjemplaresDisponibles(rs.getInt("ejemplares_disponibles"));
            return dto;
        }, idLibro);
        return list.isEmpty() ? null : list.get(0);
    }

    public List<LibroDTO> buscarLibros(String termino) {
        return jdbcTemplate.query("CALL sp_buscar_libros(?)", (rs, rowNum) -> {
            LibroDTO dto = new LibroDTO();
            dto.setIdLibro(rs.getInt("id_libro"));
            dto.setTitulo(rs.getString("titulo"));
            dto.setIsbn(rs.getString("isbn"));
            dto.setNombreCategoria(rs.getString("nombre_categoria"));
            dto.setEstado(rs.getString("estado"));
            return dto;
        }, termino);
    }

    public void asignarAutorLibro(Integer idLibro, Integer idAutor) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_asignar_autor_libro");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_libro", idLibro)
                .addValue("p_id_autor", idAutor);
        jdbcCall.execute(in);
    }

    public void quitarAutorLibro(Integer idLibro, Integer idAutor) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_quitar_autor_libro");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_libro", idLibro)
                .addValue("p_id_autor", idAutor);
        jdbcCall.execute(in);
    }

    public List<AutorDTO> listarAutoresPorLibro(Integer idLibro) {
        return jdbcTemplate.query("CALL sp_listar_autores_por_libro(?)", (rs, rowNum) -> {
            AutorDTO dto = new AutorDTO();
            dto.setIdAutor(rs.getInt("id_autor"));
            dto.setNombre(rs.getString("nombre"));
            dto.setApellido(rs.getString("apellido"));
            dto.setNacionalidad(rs.getString("nacionalidad"));
            return dto;
        }, idLibro);
    }
    public List<LibroDTO> listarLibrosPorAutor(Integer idAutor) {
        return jdbcTemplate.query("CALL sp_listar_libros_por_autor(?)", (rs, rowNum) -> {
            LibroDTO dto = new LibroDTO();
            dto.setIdLibro(rs.getInt("id_libro"));
            dto.setTitulo(rs.getString("titulo"));
            dto.setIsbn(rs.getString("isbn"));
            return dto;
        }, idAutor);
    }
}
