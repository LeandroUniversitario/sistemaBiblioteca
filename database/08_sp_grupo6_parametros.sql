USE sistemabiblioteca;

DELIMITER $$

-- =========================================================
-- Procedimiento para listar todos los parámetros
-- =========================================================
DROP PROCEDURE IF EXISTS sp_listar_parametros$$
CREATE PROCEDURE sp_listar_parametros ()
BEGIN
    SELECT 
        id_parametro, 
        nombre_parametro, 
        valor, 
        descripcion, 
        fecha_modificacion, 
        id_administrador
    FROM parametro_sistema
    ORDER BY nombre_parametro ASC;
END$$

-- =========================================================
-- Procedimiento para actualizar un parámetro
-- =========================================================
DROP PROCEDURE IF EXISTS sp_actualizar_parametro$$
CREATE PROCEDURE sp_actualizar_parametro (
    IN p_id_parametro INT,
    IN p_valor VARCHAR(30),
    IN p_descripcion VARCHAR(200),
    IN p_id_administrador INT
)
BEGIN
    UPDATE parametro_sistema
    SET 
        valor = p_valor,
        descripcion = p_descripcion,
        id_administrador = p_id_administrador,
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_parametro = p_id_parametro;
END$$

-- =========================================================
-- Procedimiento para insertar un nuevo parámetro
-- =========================================================
DROP PROCEDURE IF EXISTS sp_insertar_parametro$$
CREATE PROCEDURE sp_insertar_parametro (
    IN p_nombre_parametro VARCHAR(60),
    IN p_valor VARCHAR(30),
    IN p_descripcion VARCHAR(200),
    IN p_id_administrador INT,
    OUT p_id_parametro INT
)
BEGIN
    -- Validar si ya existe el nombre
    IF EXISTS (SELECT 1 FROM parametro_sistema WHERE nombre_parametro = p_nombre_parametro) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un parámetro con ese nombre.';
    END IF;

    INSERT INTO parametro_sistema (
        nombre_parametro,
        valor,
        descripcion,
        id_administrador
    ) VALUES (
        p_nombre_parametro,
        p_valor,
        p_descripcion,
        p_id_administrador
    );
    
    SET p_id_parametro = LAST_INSERT_ID();
END$$

DELIMITER ;
