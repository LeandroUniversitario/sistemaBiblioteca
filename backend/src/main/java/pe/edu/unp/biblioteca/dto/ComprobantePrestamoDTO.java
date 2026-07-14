package pe.edu.unp.biblioteca.dto;

public class ComprobantePrestamoDTO {
    private String numeroComprobante;
    private String nombreLector;
    private String documentoLector;
    private String tituloLibro;
    private String codigoEjemplar;
    private String nombreBibliotecario;
    private String fechaPrestamo;
    private String fechaLimite;
    private String fechaEmision;

    public String getNumeroComprobante() { return numeroComprobante; }
    public void setNumeroComprobante(String numeroComprobante) { this.numeroComprobante = numeroComprobante; }

    public String getNombreLector() { return nombreLector; }
    public void setNombreLector(String nombreLector) { this.nombreLector = nombreLector; }

    public String getDocumentoLector() { return documentoLector; }
    public void setDocumentoLector(String documentoLector) { this.documentoLector = documentoLector; }

    public String getTituloLibro() { return tituloLibro; }
    public void setTituloLibro(String tituloLibro) { this.tituloLibro = tituloLibro; }

    public String getCodigoEjemplar() { return codigoEjemplar; }
    public void setCodigoEjemplar(String codigoEjemplar) { this.codigoEjemplar = codigoEjemplar; }

    public String getNombreBibliotecario() { return nombreBibliotecario; }
    public void setNombreBibliotecario(String nombreBibliotecario) { this.nombreBibliotecario = nombreBibliotecario; }

    public String getFechaPrestamo() { return fechaPrestamo; }
    public void setFechaPrestamo(String fechaPrestamo) { this.fechaPrestamo = fechaPrestamo; }

    public String getFechaLimite() { return fechaLimite; }
    public void setFechaLimite(String fechaLimite) { this.fechaLimite = fechaLimite; }

    public String getFechaEmision() { return fechaEmision; }
    public void setFechaEmision(String fechaEmision) { this.fechaEmision = fechaEmision; }
}
