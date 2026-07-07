package pe.edu.unp.biblioteca.dto;

public class CarreraDTO {
    private Integer idCarrera;
    private String codigoCarrera;
    private String nombreCarrera;
    private Integer idFacultad;
    private String nombreFacultad;

    public CarreraDTO() {}

    public Integer getIdCarrera() { return idCarrera; }
    public void setIdCarrera(Integer idCarrera) { this.idCarrera = idCarrera; }

    public String getCodigoCarrera() { return codigoCarrera; }
    public void setCodigoCarrera(String codigoCarrera) { this.codigoCarrera = codigoCarrera; }

    public String getNombreCarrera() { return nombreCarrera; }
    public void setNombreCarrera(String nombreCarrera) { this.nombreCarrera = nombreCarrera; }

    public Integer getIdFacultad() { return idFacultad; }
    public void setIdFacultad(Integer idFacultad) { this.idFacultad = idFacultad; }

    public String getNombreFacultad() { return nombreFacultad; }
    public void setNombreFacultad(String nombreFacultad) { this.nombreFacultad = nombreFacultad; }
}
