package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.PrestamoDao;
import pe.edu.unp.biblioteca.dto.ComprobantePrestamoDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.PrestamoDTO;
import pe.edu.unp.biblioteca.dto.RegistroPrestamoDTO;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PrestamoService {

    @Autowired
    private PrestamoDao prestamoDao;

    /**
     * Lista préstamos activos/vencidos.
     * Primero ejecuta el mantenimiento de vencidos.
     */
    public List<PrestamoDTO> listarPrestamosActivos() {
        prestamoDao.actualizarPrestamosVencidos();
        return prestamoDao.listarPrestamosActivos();
    }

    /**
     * Registra un nuevo préstamo.
     */
    public GenericResponseDTO registrarPrestamo(RegistroPrestamoDTO dto) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            Map<String, Object> result = prestamoDao.registrarPrestamo(
                    dto.getIdEjemplar(), dto.getIdLector(), dto.getIdBibliotecario());

            Integer idPrestamo = (Integer) result.get("p_id_prestamo");
            String comprobante = (String) result.get("p_numero_comprobante");

            Map<String, Object> data = new HashMap<>();
            data.put("idPrestamo", idPrestamo);
            data.put("comprobante", comprobante);

            response.setSuccess(true);
            response.setMessage("Préstamo registrado exitosamente. Comprobante: " + comprobante);
            response.setData(data);
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(extraerMensajeError(e));
        }
        return response;
    }

    /**
     * Registra la devolución de un préstamo.
     */
    public GenericResponseDTO registrarDevolucion(Integer idPrestamo) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            Map<String, Object> result = prestamoDao.registrarDevolucion(idPrestamo);

            Integer diasRetraso = (Integer) result.get("p_dias_retraso");
            BigDecimal montoMulta = (BigDecimal) result.get("p_monto_multa");

            // Normalizar a 0 si es null
            if (diasRetraso == null) diasRetraso = 0;
            if (montoMulta == null) montoMulta = BigDecimal.ZERO;

            Map<String, Object> data = new HashMap<>();
            data.put("diasRetraso", diasRetraso);
            data.put("montoMulta", montoMulta);

            String mensaje;
            if (diasRetraso > 0) {
                mensaje = String.format("Devolución registrada. Se generó una multa de S/ %.2f por %d día(s) de retraso.",
                        montoMulta, diasRetraso);
            } else {
                mensaje = "Devolución registrada exitosamente. Sin retraso.";
            }

            response.setSuccess(true);
            response.setMessage(mensaje);
            response.setData(data);
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(extraerMensajeError(e));
        }
        return response;
    }

    /**
     * Obtiene los datos del comprobante generado.
     */
    public ComprobantePrestamoDTO obtenerComprobante(Integer idPrestamo) {
        return prestamoDao.obtenerComprobantePorPrestamo(idPrestamo);
    }

    /**
     * Extrae el mensaje de error legible de las excepciones SIGNAL de MySQL.
     */
    private String extraerMensajeError(Exception e) {
        String msg = e.getMessage();
        // Los SIGNAL de MySQL a veces se envuelven en mensajes genéricos de Spring
        if (msg != null && msg.contains(";")) {
            // Buscar la parte después del último ":"
            String[] parts = msg.split(";");
            for (String part : parts) {
                part = part.trim();
                if (part.startsWith("El ") || part.startsWith("La ") || part.startsWith("Este ")
                        || part.startsWith("No ") || part.startsWith("el ")) {
                    return part;
                }
            }
        }
        return msg != null ? msg : "Error desconocido al procesar la operación.";
    }
}
