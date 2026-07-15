package pe.edu.unp.biblioteca.dto;

import java.math.BigDecimal;

public class ComprobantePagoMultaDTO {
    private String numeroComprobante;
    private String nombreLector;
    private String documentoLector;
    private String concepto;
    private BigDecimal monto;
    private String nombreBibliotecario;
    private String fechaPago;
    private String fechaEmision;

    public String getNumeroComprobante() { return numeroComprobante; }
    public void setNumeroComprobante(String numeroComprobante) { this.numeroComprobante = numeroComprobante; }

    public String getNombreLector() { return nombreLector; }
    public void setNombreLector(String nombreLector) { this.nombreLector = nombreLector; }

    public String getDocumentoLector() { return documentoLector; }
    public void setDocumentoLector(String documentoLector) { this.documentoLector = documentoLector; }

    public String getConcepto() { return concepto; }
    public void setConcepto(String concepto) { this.concepto = concepto; }

    public BigDecimal getMonto() { return monto; }
    public void setMonto(BigDecimal monto) { this.monto = monto; }

    public String getNombreBibliotecario() { return nombreBibliotecario; }
    public void setNombreBibliotecario(String nombreBibliotecario) { this.nombreBibliotecario = nombreBibliotecario; }

    public String getFechaPago() { return fechaPago; }
    public void setFechaPago(String fechaPago) { this.fechaPago = fechaPago; }

    public String getFechaEmision() { return fechaEmision; }
    public void setFechaEmision(String fechaEmision) { this.fechaEmision = fechaEmision; }
}
