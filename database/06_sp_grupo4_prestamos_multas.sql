-- =========================================================
-- Sistema de Gestión de Biblioteca Universitaria
-- Script 6 (Grupo 4): Stored Procedures - Prestamo / Multa
-- Tablas cubiertas: prestamo, multa, comprobante_prestamo,
--                    comprobante_pago_multa
--
-- RECORDATORIO phpMyAdmin: cambia el Delimiter a  $$  antes de
-- ejecutar este bloque, y vuélvelo a  ;  al terminar.
--
-- DEPENDE DE: parametro_sistema. Si todavía no configuraste
-- 'dias_prestamo_default' y 'monto_multa_por_dia' desde el
-- módulo de Administración, este script usa valores de
-- respaldo (7 días, S/ 0.50 por día) para no romperse.
-- =========================================================

USE biblioteca_db;

DELIMITER $$

-- =========================================================
-- PRESTAMO
-- =========================================================

CREATE PROCEDURE sp_registrar_prestamo (
    IN  p_id_ejemplar      INT,
    IN  p_id_lector        INT,
    IN  p_id_bibliotecario INT,
    OUT p_id_prestamo      INT,
    OUT p_numero_comprobante VARCHAR(20)
)
BEGIN
    DECLARE v_id_estado_ejemplar_disponible INT;
    DECLARE v_id_estado_ejemplar_prestado    INT;
    DECLARE v_id_estado_prestamo_activo      INT;
    DECLARE v_estado_actual_ejemplar         VARCHAR(30);
    DECLARE v_lector_activo                  VARCHAR(30);
    DECLARE v_bibliotecario_activo           VARCHAR(30);
    DECLARE v_dias_prestamo                  INT;
    DECLARE v_fecha_limite                   DATETIME;
    DECLARE v_max_prestamos                  INT;
    DECLARE v_prestamos_actuales             INT;
    DECLARE v_tiene_multas                   INT;
    DECLARE v_texto_error                    VARCHAR(255) DEFAULT '';

    -- Validación: el ejemplar debe existir y estar 'disponible'
    SELECT es.codigo INTO v_estado_actual_ejemplar
    FROM ejemplar ej INNER JOIN estado es ON es.id_estado = ej.id_estado
    WHERE ej.id_ejemplar = p_id_ejemplar;

    IF v_estado_actual_ejemplar IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar indicado no existe.';
    END IF;

    IF v_estado_actual_ejemplar <> 'disponible' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El ejemplar no está disponible para préstamo (estado actual distinto de "disponible").';
    END IF;

    -- Validación: el lector debe existir y su usuario debe estar activo
    SELECT es.codigo INTO v_lector_activo
    FROM lector l
    INNER JOIN usuario u ON u.id_usuario = l.id_usuario
    INNER JOIN estado es ON es.id_estado = u.id_estado
    WHERE l.id_usuario = p_id_lector;

    IF v_lector_activo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lector indicado no existe.';
    END IF;

    IF v_lector_activo <> 'activo' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lector indicado no está activo.';
    END IF;

    -- Validación: el bibliotecario debe existir y su usuario debe estar activo
    SELECT es.codigo INTO v_bibliotecario_activo
    FROM bibliotecario b
    INNER JOIN usuario u ON u.id_usuario = b.id_usuario
    INNER JOIN estado es ON es.id_estado = u.id_estado
    WHERE b.id_usuario = p_id_bibliotecario;

    IF v_bibliotecario_activo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bibliotecario indicado no existe.';
    END IF;

    IF v_bibliotecario_activo <> 'activo' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bibliotecario indicado no está activo.';
    END IF;

    -- Validación: el lector no debe tener multas pendientes
    SELECT COUNT(*) INTO v_tiene_multas
    FROM multa m
    INNER JOIN prestamo pr ON pr.id_prestamo = m.id_prestamo
    INNER JOIN estado e ON e.id_estado = m.id_estado
    WHERE pr.id_lector = p_id_lector AND e.entidad = 'multa' AND e.codigo = 'pendiente';

    IF v_tiene_multas > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lector tiene multas pendientes de pago. No puede solicitar préstamos.';
    END IF;

    -- Validación: el lector no debe exceder el límite de préstamos simultáneos
    SELECT IFNULL(
        (SELECT valor FROM parametro_sistema WHERE nombre_parametro = 'max_prestamos_por_lector'),
        '3'
    ) INTO v_max_prestamos;

    SELECT COUNT(*) INTO v_prestamos_actuales
    FROM prestamo pr
    INNER JOIN estado e ON e.id_estado = pr.id_estado
    WHERE pr.id_lector = p_id_lector AND e.entidad = 'prestamo' AND e.codigo IN ('activo', 'vencido');

    IF v_prestamos_actuales >= v_max_prestamos THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lector ha alcanzado el límite máximo de préstamos activos simultáneos.';
    END IF;

    -- Parámetro de negocio: días de préstamo (con respaldo por si no está configurado)
    SELECT IFNULL(
        (SELECT valor FROM parametro_sistema WHERE nombre_parametro = 'dias_prestamo_default'),
        '7'
    ) INTO v_dias_prestamo;

    SET v_fecha_limite = DATE_ADD(NOW(), INTERVAL CAST(v_dias_prestamo AS UNSIGNED) DAY);

    -- IDs de estado que vamos a necesitar dentro de la transacción
    SELECT id_estado INTO v_id_estado_ejemplar_disponible FROM estado WHERE entidad = 'ejemplar' AND codigo = 'disponible' LIMIT 1;
    SELECT id_estado INTO v_id_estado_ejemplar_prestado    FROM estado WHERE entidad = 'ejemplar' AND codigo = 'prestado'   LIMIT 1;
    SELECT id_estado INTO v_id_estado_prestamo_activo      FROM estado WHERE entidad = 'prestamo' AND codigo = 'activo'    LIMIT 1;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
        END;

        START TRANSACTION;

            INSERT INTO prestamo (id_ejemplar, id_lector, id_bibliotecario, fecha_limite, id_estado)
            VALUES (p_id_ejemplar, p_id_lector, p_id_bibliotecario, v_fecha_limite, v_id_estado_prestamo_activo);

            SET p_id_prestamo = LAST_INSERT_ID();

            UPDATE ejemplar
            SET id_estado = v_id_estado_ejemplar_prestado
            WHERE id_ejemplar = p_id_ejemplar;

            SET p_numero_comprobante = CONCAT('PRE-', LPAD(p_id_prestamo, 6, '0'));

            INSERT INTO comprobante_prestamo
                (numero_comprobante, id_prestamo, nombre_lector, documento_lector,
                 titulo_libro, codigo_ejemplar, nombre_bibliotecario, fecha_prestamo, fecha_limite)
            SELECT
                p_numero_comprobante,
                p_id_prestamo,
                CONCAT(ul.nombre, ' ', ul.apellido),
                ul.documento_identidad,
                lib.titulo,
                ej.codigo_ejemplar,
                CONCAT(ub.nombre, ' ', ub.apellido),
                NOW(),
                v_fecha_limite
            FROM ejemplar ej
            INNER JOIN libro lib ON lib.id_libro = ej.id_libro
            INNER JOIN usuario ul ON ul.id_usuario = p_id_lector
            INNER JOIN usuario ub ON ub.id_usuario = p_id_bibliotecario
            WHERE ej.id_ejemplar = p_id_ejemplar;

        COMMIT;
    END;
END$$


CREATE PROCEDURE sp_registrar_devolucion (
    IN  p_id_prestamo   INT,
    OUT p_dias_retraso  INT,
    OUT p_monto_multa   DECIMAL(6,2)
)
BEGIN
    DECLARE v_id_ejemplar                 INT;
    DECLARE v_fecha_limite                DATETIME;
    DECLARE v_estado_prestamo_actual      VARCHAR(30);
    DECLARE v_id_estado_prestamo_devuelto INT;
    DECLARE v_id_estado_ejemplar_disp     INT;
    DECLARE v_id_estado_multa_pendiente   INT;
    DECLARE v_monto_por_dia               DECIMAL(6,2);
    DECLARE v_texto_error                 VARCHAR(255) DEFAULT '';

    SELECT p.id_ejemplar, p.fecha_limite, es.codigo
    INTO v_id_ejemplar, v_fecha_limite, v_estado_prestamo_actual
    FROM prestamo p
    INNER JOIN estado es ON es.id_estado = p.id_estado
    WHERE p.id_prestamo = p_id_prestamo;

    IF v_id_ejemplar IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El préstamo indicado no existe.';
    END IF;

    IF v_estado_prestamo_actual NOT IN ('activo', 'vencido') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este préstamo ya fue devuelto anteriormente.';
    END IF;

    SET p_dias_retraso = GREATEST(DATEDIFF(NOW(), v_fecha_limite), 0);

    SELECT IFNULL(
        (SELECT valor FROM parametro_sistema WHERE nombre_parametro = 'monto_multa_por_dia'),
        '0.50'
    ) INTO v_monto_por_dia;

    SET p_monto_multa = p_dias_retraso * v_monto_por_dia;

    SELECT id_estado INTO v_id_estado_prestamo_devuelto FROM estado WHERE entidad = 'prestamo' AND codigo = 'devuelto'   LIMIT 1;
    SELECT id_estado INTO v_id_estado_ejemplar_disp     FROM estado WHERE entidad = 'ejemplar' AND codigo = 'disponible' LIMIT 1;
    SELECT id_estado INTO v_id_estado_multa_pendiente   FROM estado WHERE entidad = 'multa'    AND codigo = 'pendiente'  LIMIT 1;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
        END;

        START TRANSACTION;

            UPDATE prestamo
            SET fecha_devolucion = NOW(), id_estado = v_id_estado_prestamo_devuelto
            WHERE id_prestamo = p_id_prestamo;

            UPDATE ejemplar
            SET id_estado = v_id_estado_ejemplar_disp
            WHERE id_ejemplar = v_id_ejemplar;

            IF p_dias_retraso > 0 THEN
                INSERT INTO multa (id_prestamo, monto, id_estado)
                VALUES (p_id_prestamo, p_monto_multa, v_id_estado_multa_pendiente);
            END IF;

        COMMIT;
    END;
END$$


CREATE PROCEDURE sp_actualizar_prestamos_vencidos ()
BEGIN
    -- Procedimiento de mantenimiento: pasa a 'vencido' cualquier préstamo
    -- 'activo' cuya fecha_limite ya pasó y todavía no fue devuelto.
    -- Pensado para ejecutarse al cargar el dashboard del bibliotecario,
    -- o mediante un EVENT programado de MySQL (opcional, fuera de alcance).
    DECLARE v_id_estado_activo  INT;
    DECLARE v_id_estado_vencido INT;

    SELECT id_estado INTO v_id_estado_activo  FROM estado WHERE entidad = 'prestamo' AND codigo = 'activo'  LIMIT 1;
    SELECT id_estado INTO v_id_estado_vencido FROM estado WHERE entidad = 'prestamo' AND codigo = 'vencido' LIMIT 1;

    UPDATE prestamo
    SET id_estado = v_id_estado_vencido
    WHERE id_estado = v_id_estado_activo
      AND fecha_limite < NOW();
END$$


CREATE PROCEDURE sp_listar_prestamos_activos ()
BEGIN
    SELECT pr.id_prestamo, lib.titulo, ej.codigo_ejemplar,
           CONCAT(ul.nombre, ' ', ul.apellido) AS lector,
           CONCAT(ub.nombre, ' ', ub.apellido) AS bibliotecario,
           pr.fecha_prestamo, pr.fecha_limite, es.codigo AS estado
    FROM prestamo pr
    INNER JOIN ejemplar ej ON ej.id_ejemplar = pr.id_ejemplar
    INNER JOIN libro lib   ON lib.id_libro = ej.id_libro
    INNER JOIN usuario ul  ON ul.id_usuario = pr.id_lector
    INNER JOIN usuario ub  ON ub.id_usuario = pr.id_bibliotecario
    INNER JOIN estado es   ON es.id_estado = pr.id_estado
    WHERE es.entidad = 'prestamo' AND es.codigo IN ('activo', 'vencido')
    ORDER BY pr.fecha_limite ASC;
END$$

CREATE PROCEDURE sp_listar_prestamos_por_lector (
    IN p_id_lector INT
)
BEGIN
    SELECT pr.id_prestamo, lib.titulo, ej.codigo_ejemplar,
           pr.fecha_prestamo, pr.fecha_limite, pr.fecha_devolucion,
           es.codigo AS estado
    FROM prestamo pr
    INNER JOIN ejemplar ej ON ej.id_ejemplar = pr.id_ejemplar
    INNER JOIN libro lib   ON lib.id_libro = ej.id_libro
    INNER JOIN estado es   ON es.id_estado = pr.id_estado
    WHERE pr.id_lector = p_id_lector
    ORDER BY pr.fecha_prestamo DESC;
END$$

CREATE PROCEDURE sp_obtener_prestamo_por_id (
    IN p_id_prestamo INT
)
BEGIN
    SELECT pr.id_prestamo, pr.id_ejemplar, lib.titulo, ej.codigo_ejemplar,
           pr.id_lector, CONCAT(ul.nombre, ' ', ul.apellido) AS lector,
           pr.id_bibliotecario, CONCAT(ub.nombre, ' ', ub.apellido) AS bibliotecario,
           pr.fecha_prestamo, pr.fecha_limite, pr.fecha_devolucion,
           es.codigo AS estado
    FROM prestamo pr
    INNER JOIN ejemplar ej ON ej.id_ejemplar = pr.id_ejemplar
    INNER JOIN libro lib   ON lib.id_libro = ej.id_libro
    INNER JOIN usuario ul  ON ul.id_usuario = pr.id_lector
    INNER JOIN usuario ub  ON ub.id_usuario = pr.id_bibliotecario
    INNER JOIN estado es   ON es.id_estado = pr.id_estado
    WHERE pr.id_prestamo = p_id_prestamo;
END$$


-- =========================================================
-- MULTA
-- =========================================================

CREATE PROCEDURE sp_pagar_multa (
    IN  p_id_multa          INT,
    IN  p_id_bibliotecario  INT,
    OUT p_numero_comprobante VARCHAR(20)
)
BEGIN
    DECLARE v_estado_multa_actual       VARCHAR(30);
    DECLARE v_id_estado_multa_pagada    INT;
    DECLARE v_texto_error               VARCHAR(255) DEFAULT '';

    SELECT es.codigo INTO v_estado_multa_actual
    FROM multa m INNER JOIN estado es ON es.id_estado = m.id_estado
    WHERE m.id_multa = p_id_multa;

    IF v_estado_multa_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La multa indicada no existe.';
    END IF;

    IF v_estado_multa_actual <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta multa ya fue pagada anteriormente.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM bibliotecario b
        INNER JOIN usuario u ON u.id_usuario = b.id_usuario
        INNER JOIN estado es ON es.id_estado = u.id_estado
        WHERE b.id_usuario = p_id_bibliotecario AND es.codigo = 'activo'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bibliotecario indicado no existe o no está activo.';
    END IF;

    SELECT id_estado INTO v_id_estado_multa_pagada FROM estado WHERE entidad = 'multa' AND codigo = 'pagada' LIMIT 1;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
        END;

        START TRANSACTION;

            UPDATE multa
            SET id_estado = v_id_estado_multa_pagada, fecha_pago = NOW()
            WHERE id_multa = p_id_multa;

            SET p_numero_comprobante = CONCAT('MUL-', LPAD(p_id_multa, 6, '0'));

            INSERT INTO comprobante_pago_multa
                (numero_comprobante, id_multa, nombre_lector, documento_lector,
                 concepto, monto, nombre_bibliotecario, fecha_pago)
            SELECT
                p_numero_comprobante,
                p_id_multa,
                CONCAT(ul.nombre, ' ', ul.apellido),
                ul.documento_identidad,
                CONCAT('Multa por retraso - Préstamo #', pr.id_prestamo, ' (', lib.titulo, ')'),
                m.monto,
                CONCAT(ub.nombre, ' ', ub.apellido),
                NOW()
            FROM multa m
            INNER JOIN prestamo pr ON pr.id_prestamo = m.id_prestamo
            INNER JOIN ejemplar ej ON ej.id_ejemplar = pr.id_ejemplar
            INNER JOIN libro lib   ON lib.id_libro = ej.id_libro
            INNER JOIN usuario ul  ON ul.id_usuario = pr.id_lector
            INNER JOIN usuario ub  ON ub.id_usuario = p_id_bibliotecario
            WHERE m.id_multa = p_id_multa;

        COMMIT;
    END;
END$$


CREATE PROCEDURE sp_listar_multas_pendientes ()
BEGIN
    SELECT m.id_multa, m.monto, m.fecha_generacion,
           pr.id_prestamo, lib.titulo,
           CONCAT(ul.nombre, ' ', ul.apellido) AS lector, ul.documento_identidad
    FROM multa m
    INNER JOIN estado es    ON es.id_estado = m.id_estado
    INNER JOIN prestamo pr  ON pr.id_prestamo = m.id_prestamo
    INNER JOIN ejemplar ej  ON ej.id_ejemplar = pr.id_ejemplar
    INNER JOIN libro lib    ON lib.id_libro = ej.id_libro
    INNER JOIN usuario ul   ON ul.id_usuario = pr.id_lector
    WHERE es.entidad = 'multa' AND es.codigo = 'pendiente'
    ORDER BY m.fecha_generacion ASC;
END$$

CREATE PROCEDURE sp_listar_multas_por_lector (
    IN p_id_lector INT
)
BEGIN
    SELECT m.id_multa, m.monto, m.fecha_generacion, m.fecha_pago,
           pr.id_prestamo, lib.titulo, es.codigo AS estado
    FROM multa m
    INNER JOIN estado es   ON es.id_estado = m.id_estado
    INNER JOIN prestamo pr ON pr.id_prestamo = m.id_prestamo
    INNER JOIN ejemplar ej ON ej.id_ejemplar = pr.id_ejemplar
    INNER JOIN libro lib   ON lib.id_libro = ej.id_libro
    WHERE pr.id_lector = p_id_lector
    ORDER BY m.fecha_generacion DESC;
END$$

CREATE PROCEDURE sp_obtener_multa_por_id (
    IN p_id_multa INT
)
BEGIN
    SELECT m.id_multa, m.id_prestamo, m.monto, m.fecha_generacion,
           m.fecha_pago, es.codigo AS estado
    FROM multa m
    INNER JOIN estado es ON es.id_estado = m.id_estado
    WHERE m.id_multa = p_id_multa;
END$$

DELIMITER ;
