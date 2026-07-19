USE sistemabiblioteca;

DELIMITER $$

-- =========================================================
-- Sistema de Gestión de Biblioteca Universitaria
-- Script de Pruebas: Stored Procedure para insertar préstamos
-- con fechas simuladas para probar la lógica de multas.
-- =========================================================

DROP PROCEDURE IF EXISTS sp_insertar_prestamo_test$$
CREATE PROCEDURE sp_insertar_prestamo_test (
    IN p_id_ejemplar INT,
    IN p_id_lector INT,
    IN p_id_bibliotecario INT,
    IN p_fecha_prestamo DATETIME,
    OUT p_id_prestamo INT
)
BEGIN
    DECLARE v_dias_prestamo INT;
    DECLARE v_fecha_limite DATETIME;
    DECLARE v_id_estado_prestamo_activo INT;
    DECLARE v_id_estado_ejemplar_prestado INT;

    -- Obtener la cantidad de días por defecto
    SELECT CAST(valor AS SIGNED) INTO v_dias_prestamo 
    FROM parametro_sistema 
    WHERE nombre_parametro = 'dias_prestamo_default' 
    LIMIT 1;
    
    -- Si no hay parámetro, por defecto 7
    IF v_dias_prestamo IS NULL THEN
        SET v_dias_prestamo = 7;
    END IF;

    -- Calcular la fecha límite sumando los días a la fecha de préstamo de prueba
    SET v_fecha_limite = DATE_ADD(p_fecha_prestamo, INTERVAL v_dias_prestamo DAY);

    -- Obtener IDs de estados
    SELECT id_estado INTO v_id_estado_prestamo_activo FROM estado WHERE entidad = 'prestamo' AND codigo = 'activo' LIMIT 1;
    SELECT id_estado INTO v_id_estado_ejemplar_prestado FROM estado WHERE entidad = 'ejemplar' AND codigo = 'prestado' LIMIT 1;

    START TRANSACTION;
        -- Insertar el préstamo simulando una fecha en el pasado
        INSERT INTO prestamo (id_ejemplar, id_lector, id_bibliotecario, fecha_prestamo, fecha_limite, id_estado)
        VALUES (p_id_ejemplar, p_id_lector, p_id_bibliotecario, p_fecha_prestamo, v_fecha_limite, v_id_estado_prestamo_activo);
        
        SET p_id_prestamo = LAST_INSERT_ID();

        -- Actualizar el ejemplar
        UPDATE ejemplar
        SET id_estado = v_id_estado_ejemplar_prestado
        WHERE id_ejemplar = p_id_ejemplar;
    COMMIT;
END$$

DELIMITER ;
