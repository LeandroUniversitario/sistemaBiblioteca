package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.RegistroUsuarioDTO;
import pe.edu.unp.biblioteca.dto.UsuarioListDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Repository
public class UsuarioDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public Map<String, Object> registrarAdministrador(RegistroUsuarioDTO dto, String hashedPassword) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_registrar_administrador");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_email", dto.getEmail())
                .addValue("p_password_hash", hashedPassword)
                .addValue("p_documento_identidad", dto.getDocumentoIdentidad())
                .addValue("p_telefono", dto.getTelefono());
        return jdbcCall.execute(in);
    }

    public Map<String, Object> registrarBibliotecario(RegistroUsuarioDTO dto, String hashedPassword) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_registrar_bibliotecario");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_email", dto.getEmail())
                .addValue("p_password_hash", hashedPassword)
                .addValue("p_documento_identidad", dto.getDocumentoIdentidad())
                .addValue("p_telefono", dto.getTelefono());
        return jdbcCall.execute(in);
    }

    public Map<String, Object> registrarLector(RegistroUsuarioDTO dto, String hashedPassword) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_registrar_lector");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_email", dto.getEmail())
                .addValue("p_password_hash", hashedPassword)
                .addValue("p_documento_identidad", dto.getDocumentoIdentidad())
                .addValue("p_telefono", dto.getTelefono())
                .addValue("p_codigo_universitario", dto.getCodigoUniversitario())
                .addValue("p_id_carrera", dto.getIdCarrera())
                .addValue("p_tipo_lector", dto.getTipoLector());
        return jdbcCall.execute(in);
    }

    public List<UsuarioListDTO> listarTodos() {
        String sql = "SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.documento_identidad, u.telefono, u.rol, e.codigo as estado " +
                     "FROM usuario u INNER JOIN estado e ON u.id_estado = e.id_estado " +
                     "ORDER BY u.id_usuario DESC";
        return jdbcTemplate.query(sql, new RowMapper<UsuarioListDTO>() {
            @Override
            public UsuarioListDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                UsuarioListDTO dto = new UsuarioListDTO();
                dto.setIdUsuario(rs.getInt("id_usuario"));
                dto.setNombre(rs.getString("nombre"));
                dto.setApellido(rs.getString("apellido"));
                dto.setEmail(rs.getString("email"));
                dto.setDocumentoIdentidad(rs.getString("documento_identidad"));
                dto.setTelefono(rs.getString("telefono"));
                dto.setRol(rs.getString("rol"));
                dto.setEstado(rs.getString("estado"));
                return dto;
            }
        });
    }

    public UsuarioListDTO obtenerPorId(Integer idUsuario, String rol) {
        String spName = "";
        if ("lector".equalsIgnoreCase(rol)) spName = "sp_obtener_lector_por_id";
        else if ("bibliotecario".equalsIgnoreCase(rol)) spName = "sp_obtener_bibliotecario_por_id";
        else if ("administrador".equalsIgnoreCase(rol)) spName = "sp_obtener_administrador_por_id";

        if (spName.isEmpty()) return null;

        List<UsuarioListDTO> list = jdbcTemplate.query("CALL " + spName + "(?)", new RowMapper<UsuarioListDTO>() {
            @Override
            public UsuarioListDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                UsuarioListDTO dto = new UsuarioListDTO();
                dto.setIdUsuario(rs.getInt("id_usuario"));
                dto.setNombre(rs.getString("nombre"));
                dto.setApellido(rs.getString("apellido"));
                dto.setEmail(rs.getString("email"));
                dto.setDocumentoIdentidad(rs.getString("documento_identidad"));
                dto.setTelefono(rs.getString("telefono"));
                dto.setEstado(rs.getString("estado"));
                dto.setRol(rol.toLowerCase());
                
                if ("lector".equalsIgnoreCase(rol)) {
                    dto.setCodigo(rs.getString("codigo_universitario"));
                    dto.setTipoLector(rs.getString("tipo_lector"));
                    dto.setIdCarrera(rs.getInt("id_carrera"));
                    dto.setNombreCarrera(rs.getString("nombre_carrera"));
                    dto.setNombreFacultad(rs.getString("nombre_facultad"));
                } else if ("bibliotecario".equalsIgnoreCase(rol)) {
                    dto.setCodigo(rs.getString("codigo_bibliotecario"));
                } else if ("administrador".equalsIgnoreCase(rol)) {
                    dto.setCodigo(rs.getString("codigo_administrador"));
                }
                return dto;
            }
        }, idUsuario);

        return list.isEmpty() ? null : list.get(0);
    }

    public void actualizarLector(RegistroUsuarioDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_actualizar_lector");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_usuario", dto.getIdUsuario())
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_telefono", dto.getTelefono())
                .addValue("p_codigo_universitario", dto.getCodigoUniversitario())
                .addValue("p_id_carrera", dto.getIdCarrera())
                .addValue("p_tipo_lector", dto.getTipoLector());
        jdbcCall.execute(in);
    }

    public void actualizarBibliotecario(RegistroUsuarioDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_actualizar_bibliotecario");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_usuario", dto.getIdUsuario())
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_telefono", dto.getTelefono());
        jdbcCall.execute(in);
    }

    public void actualizarAdministrador(RegistroUsuarioDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_actualizar_administrador");
        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_usuario", dto.getIdUsuario())
                .addValue("p_nombre", dto.getNombre())
                .addValue("p_apellido", dto.getApellido())
                .addValue("p_telefono", dto.getTelefono());
        jdbcCall.execute(in);
    }

    public void cambiarEstado(Integer idUsuario, String accion) {
        String sp = "activar".equalsIgnoreCase(accion) ? "sp_activar_usuario" : "sp_desactivar_usuario";
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName(sp);
        MapSqlParameterSource in = new MapSqlParameterSource().addValue("p_id_usuario", idUsuario);
        jdbcCall.execute(in);
    }
}
