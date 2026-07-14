package pe.edu.unp.biblioteca.dto;

public class RegistroPrestamoDTO {
    private Integer idEjemplar;
    private Integer idLector;
    private Integer idBibliotecario;

    public Integer getIdEjemplar() { return idEjemplar; }
    public void setIdEjemplar(Integer idEjemplar) { this.idEjemplar = idEjemplar; }

    public Integer getIdLector() { return idLector; }
    public void setIdLector(Integer idLector) { this.idLector = idLector; }

    public Integer getIdBibliotecario() { return idBibliotecario; }
    public void setIdBibliotecario(Integer idBibliotecario) { this.idBibliotecario = idBibliotecario; }
}
