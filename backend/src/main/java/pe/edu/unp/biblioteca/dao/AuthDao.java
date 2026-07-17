package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public class AuthDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public Map<String, Object> loginUser(String email) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_login_usuario");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_email", email);

        return jdbcCall.execute(in);
    }

    public Map<String, Object> restablecerPassword(String email, String documento, String nuevoHash) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_restablecer_password");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_email", email)
                .addValue("p_documento", documento)
                .addValue("p_nuevo_hash", nuevoHash);

        return jdbcCall.execute(in);
    }
}
