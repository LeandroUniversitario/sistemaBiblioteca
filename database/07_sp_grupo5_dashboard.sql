USE sistemabiblioteca;

DELIMITER $$

-- =========================================================
-- Procedimiento para obtener estadísticas del bibliotecario
-- =========================================================
DROP PROCEDURE IF EXISTS sp_dashboard_bibliotecario_stats$$
CREATE PROCEDURE sp_dashboard_bibliotecario_stats ()
BEGIN
    DECLARE v_ejemplares_disponibles INT;
    DECLARE v_titulos_disponibles INT;
    DECLARE v_prestamos_activos INT;
    DECLARE v_devoluciones_atrasadas INT;

    SELECT COUNT(*) INTO v_ejemplares_disponibles 
    FROM ejemplar ej 
    JOIN estado e ON ej.id_estado = e.id_estado 
    WHERE e.entidad='ejemplar' AND e.codigo='disponible';
    
    SELECT COUNT(DISTINCT ej.id_libro) INTO v_titulos_disponibles 
    FROM ejemplar ej 
    JOIN estado e ON ej.id_estado = e.id_estado 
    WHERE e.entidad='ejemplar' AND e.codigo='disponible';

    SELECT COUNT(*) INTO v_prestamos_activos 
    FROM prestamo p 
    JOIN estado e ON p.id_estado = e.id_estado 
    WHERE e.entidad='prestamo' AND e.codigo='activo';

    SELECT COUNT(*) INTO v_devoluciones_atrasadas 
    FROM prestamo p 
    JOIN estado e ON p.id_estado = e.id_estado 
    WHERE e.entidad='prestamo' AND e.codigo='activo' AND p.fecha_limite < NOW();

    SELECT 
        v_ejemplares_disponibles AS librosDisponibles, 
        v_titulos_disponibles AS titulosDisponibles,
        v_prestamos_activos AS prestamosActivos, 
        v_devoluciones_atrasadas AS devolucionesAtrasadas;
END$$

-- =========================================================
-- Procedimiento para obtener préstamos recientes
-- =========================================================
DROP PROCEDURE IF EXISTS sp_dashboard_prestamos_recientes$$
CREATE PROCEDURE sp_dashboard_prestamos_recientes ()
BEGIN
    SELECT 
        l.titulo AS titulo, 
        CONCAT(u.nombre, ' ', u.apellido) AS lector, 
        p.fecha_limite AS fechaLimite, 
        e.codigo AS estado 
    FROM prestamo p 
    JOIN ejemplar ej ON p.id_ejemplar = ej.id_ejemplar 
    JOIN libro l ON ej.id_libro = l.id_libro 
    JOIN usuario u ON p.id_lector = u.id_usuario 
    JOIN estado e ON p.id_estado = e.id_estado 
    ORDER BY p.fecha_prestamo DESC 
    LIMIT 5;
END$$

-- =========================================================
-- Procedimiento para obtener alertas de vencimiento
-- =========================================================
DROP PROCEDURE IF EXISTS sp_dashboard_alertas_vencimiento$$
CREATE PROCEDURE sp_dashboard_alertas_vencimiento ()
BEGIN
    SELECT 
        p.id_prestamo AS idPrestamo,
        l.titulo AS titulo, 
        CONCAT(u.nombre, ' ', u.apellido) AS lector, 
        p.fecha_limite AS fechaLimite, 
        e.codigo AS estado,
        DATEDIFF(p.fecha_limite, CURDATE()) AS diasRestantes
    FROM prestamo p 
    JOIN ejemplar ej ON p.id_ejemplar = ej.id_ejemplar 
    JOIN libro l ON ej.id_libro = l.id_libro 
    JOIN usuario u ON p.id_lector = u.id_usuario 
    JOIN estado e ON p.id_estado = e.id_estado 
    WHERE e.entidad = 'prestamo' 
      AND e.codigo = 'activo' 
      AND DATEDIFF(p.fecha_limite, CURDATE()) <= 2
    ORDER BY p.fecha_limite ASC;
END$$

DELIMITER ;
