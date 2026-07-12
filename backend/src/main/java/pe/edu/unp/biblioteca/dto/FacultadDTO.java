package pe.edu.unp.biblioteca.dto;

public class FacultadDTO {
    private Integer idFacultad;
    private String codigoFacultad;
    private String nombreFacultad;
    private String abreviatura;
    private String estado;

    public FacultadDTO() {
    }

    public FacultadDTO(Integer idFacultad, String codigoFacultad, String nombreFacultad, String abreviatura, String estado) {
        this.idFacultad = idFacultad;
        this.codigoFacultad = codigoFacultad;
        this.nombreFacultad = nombreFacultad;
        this.abreviatura = abreviatura;
        this.estado = estado;
    }

    public Integer getIdFacultad() {
        return idFacultad;
    }

    public void setIdFacultad(Integer idFacultad) {
        this.idFacultad = idFacultad;
    }

    public String getCodigoFacultad() {
        return codigoFacultad;
    }

    public void setCodigoFacultad(String codigoFacultad) {
        this.codigoFacultad = codigoFacultad;
    }

    public String getNombreFacultad() {
        return nombreFacultad;
    }

    public void setNombreFacultad(String nombreFacultad) {
        this.nombreFacultad = nombreFacultad;
    }

    public String getAbreviatura() {
        return abreviatura;
    }

    public void setAbreviatura(String abreviatura) {
        this.abreviatura = abreviatura;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}
