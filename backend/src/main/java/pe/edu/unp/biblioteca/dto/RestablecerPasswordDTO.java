package pe.edu.unp.biblioteca.dto;

public class RestablecerPasswordDTO {
    private String email;
    private String documentoIdentidad;
    private String nuevaPassword;

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getDocumentoIdentidad() { return documentoIdentidad; }
    public void setDocumentoIdentidad(String documentoIdentidad) { this.documentoIdentidad = documentoIdentidad; }

    public String getNuevaPassword() { return nuevaPassword; }
    public void setNuevaPassword(String nuevaPassword) { this.nuevaPassword = nuevaPassword; }
}
