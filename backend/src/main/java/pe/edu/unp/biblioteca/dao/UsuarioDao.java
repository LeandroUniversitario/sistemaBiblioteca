package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.RegistroUsuarioDTO;

import java.util.Map;

@Repository
public class UsuarioDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public Map<String, Object> registrarAdministrador(RegistroUsuarioDTO dto, String hashedPassword) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_registrar_administrador");

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
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_registrar_bibliotecario");

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
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_registrar_lector");

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
}
