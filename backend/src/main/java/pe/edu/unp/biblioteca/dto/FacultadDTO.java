package pe.edu.unp.biblioteca.dto;

public class FacultadDTO {
    private Integer idFacultad;
    private String codigoFacultad;
    private String nombreFacultad;

    public FacultadDTO() {
    }

    public FacultadDTO(Integer idFacultad, String codigoFacultad, String nombreFacultad) {
        this.idFacultad = idFacultad;
        this.codigoFacultad = codigoFacultad;
        this.nombreFacultad = nombreFacultad;
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
}
