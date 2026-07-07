package pe.edu.unp.biblioteca.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import pe.edu.unp.biblioteca.dto.CarreraDTO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

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
}
