package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.CarreraDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import java.util.Map;

@Repository
public class CarreraDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<CarreraDTO> listarCarreras() {
        return jdbcTemplate.query(
                "CALL sp_listar_carreras()",
                new RowMapper<CarreraDTO>() {
                    @Override
                    public CarreraDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                        CarreraDTO dto = new CarreraDTO();
                        dto.setIdCarrera(rs.getInt("id_carrera"));
                        dto.setCodigoCarrera(rs.getString("codigo_carrera"));
                        dto.setNombreCarrera(rs.getString("nombre_carrera"));
                        dto.setIdFacultad(rs.getInt("id_facultad"));
                        dto.setNombreFacultad(rs.getString("nombre_facultad"));
                        return dto;
                    }
                }
        );
    }

    public CarreraDTO obtenerPorId(Integer id) {
        List<CarreraDTO> lista = jdbcTemplate.query(
                "CALL sp_obtener_carrera_por_id(?)",
                new RowMapper<CarreraDTO>() {
                    @Override
                    public CarreraDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
                        CarreraDTO dto = new CarreraDTO();
                        dto.setIdCarrera(rs.getInt("id_carrera"));
                        dto.setCodigoCarrera(rs.getString("codigo_carrera"));
                        dto.setNombreCarrera(rs.getString("nombre_carrera"));
                        dto.setIdFacultad(rs.getInt("id_facultad"));
                        dto.setNombreFacultad(rs.getString("nombre_facultad"));
                        return dto;
                    }
                },
                id
        );
        return lista.isEmpty() ? null : lista.get(0);
    }

    public Integer insertar(CarreraDTO carrera) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_insertar_carrera")
                .withoutProcedureColumnMetaDataAccess()
                .declareParameters(
                        new SqlParameter("p_nombre_carrera", Types.VARCHAR),
                        new SqlParameter("p_id_facultad", Types.INTEGER),
                        new SqlOutParameter("p_id_carrera", Types.INTEGER),
                        new SqlOutParameter("p_codigo_carrera", Types.VARCHAR)
                );

        MapSqlParameterSource in = new MapSqlParameterSource();
        in.addValue("p_nombre_carrera", carrera.getNombreCarrera());
        in.addValue("p_id_facultad", carrera.getIdFacultad());

        Map<String, Object> out = jdbcCall.execute(in);
        return (Integer) out.get("p_id_carrera");
    }

    public void actualizar(CarreraDTO carrera) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_actualizar_carrera")
                .withoutProcedureColumnMetaDataAccess()
                .declareParameters(
                        new SqlParameter("p_id_carrera", Types.INTEGER),
                        new SqlParameter("p_nombre_carrera", Types.VARCHAR),
                        new SqlParameter("p_id_facultad", Types.INTEGER)
                );

        MapSqlParameterSource in = new MapSqlParameterSource();
        in.addValue("p_id_carrera", carrera.getIdCarrera());
        in.addValue("p_nombre_carrera", carrera.getNombreCarrera());
        in.addValue("p_id_facultad", carrera.getIdFacultad());

        jdbcCall.execute(in);
    }

    public void eliminar(Integer id) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_eliminar_carrera")
                .withoutProcedureColumnMetaDataAccess()
                .declareParameters(
                        new SqlParameter("p_id_carrera", Types.INTEGER)
                );

        MapSqlParameterSource in = new MapSqlParameterSource();
        in.addValue("p_id_carrera", id);

        jdbcCall.execute(in);
    }
}
