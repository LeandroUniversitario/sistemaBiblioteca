package pe.edu.unp.biblioteca.dto;

public class PrestamoDTO {
    private Integer idPrestamo;
    private Integer idEjemplar;
    private Integer idLector;
    private Integer idBibliotecario;
    private String titulo;
    private String codigoEjemplar;
    private String lector;
    private String bibliotecario;
    private String fechaPrestamo;
    private String fechaLimite;
    private String fechaDevolucion;
    private String estado;

    public Integer getIdPrestamo() { return idPrestamo; }
    public void setIdPrestamo(Integer idPrestamo) { this.idPrestamo = idPrestamo; }

    public Integer getIdEjemplar() { return idEjemplar; }
    public void setIdEjemplar(Integer idEjemplar) { this.idEjemplar = idEjemplar; }

    public Integer getIdLector() { return idLector; }
    public void setIdLector(Integer idLector) { this.idLector = idLector; }

    public Integer getIdBibliotecario() { return idBibliotecario; }
    public void setIdBibliotecario(Integer idBibliotecario) { this.idBibliotecario = idBibliotecario; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getCodigoEjemplar() { return codigoEjemplar; }
    public void setCodigoEjemplar(String codigoEjemplar) { this.codigoEjemplar = codigoEjemplar; }

    public String getLector() { return lector; }
    public void setLector(String lector) { this.lector = lector; }

    public String getBibliotecario() { return bibliotecario; }
    public void setBibliotecario(String bibliotecario) { this.bibliotecario = bibliotecario; }

    public String getFechaPrestamo() { return fechaPrestamo; }
    public void setFechaPrestamo(String fechaPrestamo) { this.fechaPrestamo = fechaPrestamo; }

    public String getFechaLimite() { return fechaLimite; }
    public void setFechaLimite(String fechaLimite) { this.fechaLimite = fechaLimite; }

    public String getFechaDevolucion() { return fechaDevolucion; }
    public void setFechaDevolucion(String fechaDevolucion) { this.fechaDevolucion = fechaDevolucion; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}
