package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.EmpresaDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class EmpresaDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * Llama a sp_obtener_empresa.
     */
    public EmpresaDTO obtenerEmpresa() {
        List<EmpresaDTO> list = jdbcTemplate.query("CALL sp_obtener_empresa()", new RowMapper<EmpresaDTO>() {
            @Override
            public EmpresaDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                EmpresaDTO dto = new EmpresaDTO();
                dto.setIdEmpresa(rs.getInt("id_empresa"));
                dto.setRazonSocial(rs.getString("razon_social"));
                dto.setRuc(rs.getString("ruc"));
                dto.setDireccion(rs.getString("direccion"));
                dto.setTelefonoContacto(rs.getString("telefono_contacto"));
                dto.setLogoUrl(rs.getString("logo_url"));
                return dto;
            }
        });
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Llama a sp_actualizar_empresa.
     */
    public void actualizarEmpresa(EmpresaDTO dto) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_empresa");

        MapSqlParameterSource in = new MapSqlParameterSource()
                .addValue("p_id_empresa", dto.getIdEmpresa())
                .addValue("p_razon_social", dto.getRazonSocial())
                .addValue("p_ruc", dto.getRuc())
                .addValue("p_direccion", dto.getDireccion())
                .addValue("p_telefono_contacto", dto.getTelefonoContacto())
                .addValue("p_logo_url", dto.getLogoUrl());

        jdbcCall.execute(in);
    }
}
