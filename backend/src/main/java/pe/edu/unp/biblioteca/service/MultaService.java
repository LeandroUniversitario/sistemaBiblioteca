package pe.edu.unp.biblioteca.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.unp.biblioteca.dao.MultaDao;
import pe.edu.unp.biblioteca.dto.ComprobantePagoMultaDTO;
import pe.edu.unp.biblioteca.dto.GenericResponseDTO;
import pe.edu.unp.biblioteca.dto.MultaDTO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MultaService {

    @Autowired
    private MultaDao multaDao;

    public List<MultaDTO> listarMultasPendientes() {
        return multaDao.listarMultasPendientes();
    }

    public List<MultaDTO> listarMultasPorLector(Integer idLector) {
        return multaDao.listarMultasPorLector(idLector);
    }

    public GenericResponseDTO pagarMulta(Integer idMulta, Integer idBibliotecario) {
        GenericResponseDTO response = new GenericResponseDTO();
        try {
            Map<String, Object> result = multaDao.pagarMulta(idMulta, idBibliotecario);

            String comprobante = (String) result.get("p_numero_comprobante");

            Map<String, Object> data = new HashMap<>();
            data.put("idMulta", idMulta);
            data.put("comprobante", comprobante);

            response.setSuccess(true);
            response.setMessage("Multa pagada exitosamente. Comprobante: " + comprobante);
            response.setData(data);
        } catch (Exception e) {
            response.setSuccess(false);
            response.setMessage(extraerMensajeError(e));
        }
        return response;
    }

    public ComprobantePagoMultaDTO obtenerComprobante(Integer idMulta) {
        return multaDao.obtenerComprobantePorMulta(idMulta);
    }

    private String extraerMensajeError(Exception e) {
        String msg = e.getMessage();
        if (msg != null && msg.contains(";")) {
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
