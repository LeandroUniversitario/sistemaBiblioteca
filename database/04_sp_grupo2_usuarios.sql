-- =========================================================
-- Sistema de Gestión de Biblioteca Universitaria
-- Script 4 (Grupo 2): Stored Procedures - Usuario / Lector /
--                      Bibliotecario / Administrador
--
-- RECORDATORIO phpMyAdmin: cambia el Delimiter a  $$  antes de
-- ejecutar este bloque, y vuélvelo a  ;  al terminar.
-- =========================================================

USE biblioteca_db;

DELIMITER $$

-- =========================================================
-- sp_registrar_lector
-- Inserta en 'usuario' y 'lector' dentro de UNA transacción.
-- Validaciones:
--  - Formato básico de correo.
--  - Un 'estudiante' debe tener id_carrera; otros tipos no lo
--    requieren (puede ser NULL).
--  - Duplicados de email / documento_identidad / codigo_universitario.
--  - id_carrera inexistente (FK).
-- =========================================================
CREATE PROCEDURE sp_registrar_lector (
    IN  p_nombre               VARCHAR(100),
    IN  p_apellido             VARCHAR(100),
    IN  p_email                VARCHAR(150),
    IN  p_password_hash        VARCHAR(255),
    IN  p_documento_identidad  VARCHAR(20),
    IN  p_telefono             VARCHAR(20),
    IN  p_codigo_universitario VARCHAR(20),
    IN  p_id_carrera           INT,   -- puede ser NULL (docente/externo/personal_administrativo)
    IN  p_tipo_lector          VARCHAR(20),
    OUT p_id_usuario           INT
)
BEGIN
    DECLARE v_id_estado_activo INT;

    -- ---- Validaciones de negocio (fuera del bloque transaccional) ----
    IF p_tipo_lector NOT IN ('estudiante', 'docente', 'personal_administrativo', 'externo') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'tipo_lector inválido. Use: estudiante, docente, personal_administrativo o externo.';
    END IF;

    IF p_tipo_lector = 'estudiante' AND p_id_carrera IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un lector de tipo estudiante debe tener una carrera asignada.';
    END IF;

    IF p_email IS NULL OR p_email NOT LIKE '%_@__%.__%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato del correo electrónico no es válido.';
    END IF;

    IF p_password_hash IS NULL OR p_password_hash = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se recibió la contraseña cifrada.';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' OR p_apellido IS NULL OR TRIM(p_apellido) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido.';
    END IF;
    SET p_nombre = TRIM(p_nombre);
    SET p_apellido = TRIM(p_apellido);
    SET p_email = TRIM(p_email);

    SELECT id_estado INTO v_id_estado_activo
    FROM estado WHERE entidad = 'usuario' AND codigo = 'activo' LIMIT 1;

    IF v_id_estado_activo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontró el estado "activo" en el catálogo (configuración corrupta).';
    END IF;

    -- ---- Bloque transaccional (el HANDLER solo vive aquí adentro) ----
    BEGIN
        DECLARE v_texto_error VARCHAR(255) DEFAULT '';

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            ROLLBACK;
            IF v_texto_error LIKE '%email%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo ya está registrado.';
            ELSEIF v_texto_error LIKE '%documento_identidad%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El documento de identidad ya está registrado.';
            ELSEIF v_texto_error LIKE '%codigo_universitario%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El código universitario ya está registrado.';
            ELSEIF v_texto_error LIKE '%fk_lector_carrera%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La carrera indicada no existe.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        START TRANSACTION;

            INSERT INTO usuario (nombre, apellido, email, password_hash, rol, documento_identidad, telefono, id_estado)
            VALUES (p_nombre, p_apellido, p_email, p_password_hash, 'lector', p_documento_identidad, p_telefono, v_id_estado_activo);

            SET p_id_usuario = LAST_INSERT_ID();

            INSERT INTO lector (id_usuario, codigo_universitario, id_carrera, tipo_lector)
            VALUES (p_id_usuario, p_codigo_universitario, p_id_carrera, p_tipo_lector);

        COMMIT;
    END;
END$$


-- =========================================================
-- sp_registrar_bibliotecario
-- =========================================================
CREATE PROCEDURE sp_registrar_bibliotecario (
    IN  p_nombre              VARCHAR(100),
    IN  p_apellido            VARCHAR(100),
    IN  p_email               VARCHAR(150),
    IN  p_password_hash       VARCHAR(255),
    IN  p_documento_identidad VARCHAR(20),
    IN  p_telefono            VARCHAR(20),
    OUT p_id_usuario          INT,
    OUT p_codigo_bibliotecario VARCHAR(10)
)
BEGIN
    DECLARE v_id_estado_activo INT;

    IF p_email IS NULL OR p_email NOT LIKE '%_@__%.__%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato del correo electrónico no es válido.';
    END IF;

    IF p_password_hash IS NULL OR p_password_hash = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se recibió la contraseña cifrada.';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' OR p_apellido IS NULL OR TRIM(p_apellido) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido.';
    END IF;
    SET p_nombre = TRIM(p_nombre);
    SET p_apellido = TRIM(p_apellido);
    SET p_email = TRIM(p_email);

    SELECT id_estado INTO v_id_estado_activo
    FROM estado WHERE entidad = 'usuario' AND codigo = 'activo' LIMIT 1;

    IF v_id_estado_activo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontró el estado "activo" en el catálogo (configuración corrupta).';
    END IF;

    BEGIN
        DECLARE v_texto_error VARCHAR(255) DEFAULT '';

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            ROLLBACK;
            IF v_texto_error LIKE '%email%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo ya está registrado.';
            ELSEIF v_texto_error LIKE '%documento_identidad%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El documento de identidad ya está registrado.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        START TRANSACTION;

            INSERT INTO usuario (nombre, apellido, email, password_hash, rol, documento_identidad, telefono, id_estado)
            VALUES (p_nombre, p_apellido, p_email, p_password_hash, 'bibliotecario', p_documento_identidad, p_telefono, v_id_estado_activo);

            SET p_id_usuario = LAST_INSERT_ID();
            SET p_codigo_bibliotecario = CONCAT('B', LPAD(p_id_usuario, 3, '0'));

            INSERT INTO bibliotecario (id_usuario, codigo_bibliotecario)
            VALUES (p_id_usuario, p_codigo_bibliotecario);

        COMMIT;
    END;
END$$


-- =========================================================
-- sp_registrar_administrador
-- =========================================================
CREATE PROCEDURE sp_registrar_administrador (
    IN  p_nombre              VARCHAR(100),
    IN  p_apellido            VARCHAR(100),
    IN  p_email               VARCHAR(150),
    IN  p_password_hash       VARCHAR(255),
    IN  p_documento_identidad VARCHAR(20),
    IN  p_telefono            VARCHAR(20),
    OUT p_id_usuario           INT,
    OUT p_codigo_administrador VARCHAR(10)
)
BEGIN
    DECLARE v_id_estado_activo INT;

    IF p_email IS NULL OR p_email NOT LIKE '%_@__%.__%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El formato del correo electrónico no es válido.';
    END IF;

    IF p_password_hash IS NULL OR p_password_hash = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se recibió la contraseña cifrada.';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' OR p_apellido IS NULL OR TRIM(p_apellido) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido.';
    END IF;
    SET p_nombre = TRIM(p_nombre);
    SET p_apellido = TRIM(p_apellido);
    SET p_email = TRIM(p_email);

    SELECT id_estado INTO v_id_estado_activo
    FROM estado WHERE entidad = 'usuario' AND codigo = 'activo' LIMIT 1;

    IF v_id_estado_activo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontró el estado "activo" en el catálogo (configuración corrupta).';
    END IF;

    BEGIN
        DECLARE v_texto_error VARCHAR(255) DEFAULT '';

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            ROLLBACK;
            IF v_texto_error LIKE '%email%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo ya está registrado.';
            ELSEIF v_texto_error LIKE '%documento_identidad%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El documento de identidad ya está registrado.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        START TRANSACTION;

            INSERT INTO usuario (nombre, apellido, email, password_hash, rol, documento_identidad, telefono, id_estado)
            VALUES (p_nombre, p_apellido, p_email, p_password_hash, 'administrador', p_documento_identidad, p_telefono, v_id_estado_activo);

            SET p_id_usuario = LAST_INSERT_ID();
            SET p_codigo_administrador = CONCAT('A', LPAD(p_id_usuario, 3, '0'));

            INSERT INTO administrador (id_usuario, codigo_administrador)
            VALUES (p_id_usuario, p_codigo_administrador);

        COMMIT;
    END;
END$$


-- =========================================================
-- sp_login_usuario
-- Solo CONSULTA los datos necesarios para que Java verifique la
-- contraseña con BCrypt (MySQL no hace la verificación: no tiene
-- una función BCrypt nativa segura, ver discusión previa).
-- Si el correo no existe, p_id_usuario queda en NULL -- Java
-- debe interpretar eso como "usuario no encontrado".
-- =========================================================
CREATE PROCEDURE sp_login_usuario (
    IN  p_email            VARCHAR(150),
    OUT p_id_usuario       INT,
    OUT p_password_hash    VARCHAR(255),
    OUT p_rol              VARCHAR(20),
    OUT p_nombre_completo  VARCHAR(201),
    OUT p_estado_codigo    VARCHAR(30)
)
BEGIN
    SET p_id_usuario      = NULL;
    SET p_password_hash   = NULL;
    SET p_rol             = NULL;
    SET p_nombre_completo = NULL;
    SET p_estado_codigo   = NULL;

    SELECT u.id_usuario, u.password_hash, u.rol,
           CONCAT(u.nombre, ' ', u.apellido), e.codigo
    INTO p_id_usuario, p_password_hash, p_rol, p_nombre_completo, p_estado_codigo
    FROM usuario u
    INNER JOIN estado e ON e.id_estado = u.id_estado
    WHERE u.email = p_email
    LIMIT 1;

    -- Nota: si no hay coincidencia, todas las variables OUT quedan
    -- en NULL de forma silenciosa (comportamiento estándar de
    -- SELECT...INTO sin filas). Java debe verificar p_id_usuario IS NULL.
END$$


-- =========================================================
-- sp_actualizar_lector
-- No permite editar email ni documento_identidad (decisión de
-- alcance: son datos de identidad fijados en el registro).
-- =========================================================
CREATE PROCEDURE sp_actualizar_lector (
    IN p_id_usuario           INT,
    IN p_nombre               VARCHAR(100),
    IN p_apellido             VARCHAR(100),
    IN p_telefono             VARCHAR(20),
    IN p_codigo_universitario VARCHAR(20),
    IN p_id_carrera           INT,
    IN p_tipo_lector          VARCHAR(20)
)
BEGIN
    IF p_tipo_lector NOT IN ('estudiante', 'docente', 'personal_administrativo', 'externo') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'tipo_lector inválido. Use: estudiante, docente, personal_administrativo o externo.';
    END IF;

    IF p_tipo_lector = 'estudiante' AND p_id_carrera IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un lector de tipo estudiante debe tener una carrera asignada.';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' OR p_apellido IS NULL OR TRIM(p_apellido) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido.';
    END IF;
    
    SET p_nombre = TRIM(p_nombre);
    SET p_apellido = TRIM(p_apellido);

    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usuario = p_id_usuario AND rol = 'lector') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lector indicado no existe.';
    END IF;

    BEGIN
        DECLARE v_texto_error VARCHAR(255) DEFAULT '';

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            ROLLBACK;
            IF v_texto_error LIKE '%codigo_universitario%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El código universitario ya está registrado para otro lector.';
            ELSEIF v_texto_error LIKE '%fk_lector_carrera%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La carrera indicada no existe.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        START TRANSACTION;

            UPDATE usuario
            SET nombre = p_nombre, apellido = p_apellido, telefono = p_telefono
            WHERE id_usuario = p_id_usuario;

            UPDATE lector
            SET codigo_universitario = p_codigo_universitario,
                id_carrera           = p_id_carrera,
                tipo_lector          = p_tipo_lector
            WHERE id_usuario = p_id_usuario;

        COMMIT;
    END;
END$$


-- =========================================================
-- sp_actualizar_bibliotecario / sp_actualizar_administrador
-- Solo tocan los campos comunes de 'usuario': el código
-- (codigo_bibliotecario / codigo_administrador) es autogenerado
-- y no editable.
-- =========================================================
CREATE PROCEDURE sp_actualizar_bibliotecario (
    IN p_id_usuario INT,
    IN p_nombre     VARCHAR(100),
    IN p_apellido   VARCHAR(100),
    IN p_telefono   VARCHAR(20)
)
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' OR p_apellido IS NULL OR TRIM(p_apellido) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido.';
    END IF;
    SET p_nombre = TRIM(p_nombre);
    SET p_apellido = TRIM(p_apellido);

    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usuario = p_id_usuario AND rol = 'bibliotecario') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El bibliotecario indicado no existe.';
    END IF;

    UPDATE usuario
    SET nombre = p_nombre, apellido = p_apellido, telefono = p_telefono
    WHERE id_usuario = p_id_usuario AND rol = 'bibliotecario';
END$$

CREATE PROCEDURE sp_actualizar_administrador (
    IN p_id_usuario INT,
    IN p_nombre     VARCHAR(100),
    IN p_apellido   VARCHAR(100),
    IN p_telefono   VARCHAR(20)
)
BEGIN
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' OR p_apellido IS NULL OR TRIM(p_apellido) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido.';
    END IF;
    SET p_nombre = TRIM(p_nombre);
    SET p_apellido = TRIM(p_apellido);

    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usuario = p_id_usuario AND rol = 'administrador') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El administrador indicado no existe.';
    END IF;

    UPDATE usuario
    SET nombre = p_nombre, apellido = p_apellido, telefono = p_telefono
    WHERE id_usuario = p_id_usuario AND rol = 'administrador';
END$$


-- =========================================================
-- sp_desactivar_usuario / sp_activar_usuario
-- Baja lógica genérica (aplica a cualquier rol). NO se hace
-- DELETE físico de usuario: preserva la trazabilidad histórica
-- con Prestamo, Comprobante_*, parametro_sistema, etc.
-- =========================================================
CREATE PROCEDURE sp_desactivar_usuario (
    IN p_id_usuario INT
)
BEGIN
    DECLARE v_id_estado_inactivo INT;

    SELECT id_estado INTO v_id_estado_inactivo
    FROM estado WHERE entidad = 'usuario' AND codigo = 'inactivo' LIMIT 1;

    IF v_id_estado_inactivo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontró el estado "inactivo" en el catálogo (configuración corrupta).';
    END IF;

    UPDATE usuario SET id_estado = v_id_estado_inactivo WHERE id_usuario = p_id_usuario;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario indicado no existe.';
    END IF;
END$$

CREATE PROCEDURE sp_activar_usuario (
    IN p_id_usuario INT
)
BEGIN
    DECLARE v_id_estado_activo INT;

    SELECT id_estado INTO v_id_estado_activo
    FROM estado WHERE entidad = 'usuario' AND codigo = 'activo' LIMIT 1;

    IF v_id_estado_activo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontró el estado "activo" en el catálogo (configuración corrupta).';
    END IF;

    UPDATE usuario SET id_estado = v_id_estado_activo WHERE id_usuario = p_id_usuario;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El usuario indicado no existe.';
    END IF;
END$$


-- =========================================================
-- Listados y consultas
-- =========================================================
CREATE PROCEDURE sp_listar_lectores ()
BEGIN
    SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.documento_identidad,
           u.telefono, e.codigo AS estado,
           l.codigo_universitario, l.tipo_lector,
           c.nombre_carrera, f.nombre_facultad
    FROM usuario u
    INNER JOIN lector l   ON l.id_usuario = u.id_usuario
    INNER JOIN estado e   ON e.id_estado = u.id_estado
    LEFT JOIN  carrera c  ON c.id_carrera = l.id_carrera
    LEFT JOIN  facultad f ON f.id_facultad = c.id_facultad
    ORDER BY u.apellido, u.nombre;
END$$

CREATE PROCEDURE sp_obtener_lector_por_id (
    IN p_id_usuario INT
)
BEGIN
    SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.documento_identidad,
           u.telefono, e.codigo AS estado,
           l.codigo_universitario, l.tipo_lector,
           l.id_carrera, c.nombre_carrera, f.nombre_facultad
    FROM usuario u
    INNER JOIN lector l   ON l.id_usuario = u.id_usuario
    INNER JOIN estado e   ON e.id_estado = u.id_estado
    LEFT JOIN  carrera c  ON c.id_carrera = l.id_carrera
    LEFT JOIN  facultad f ON f.id_facultad = c.id_facultad
    WHERE u.id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_listar_bibliotecarios ()
BEGIN
    SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.documento_identidad,
           u.telefono, e.codigo AS estado, b.codigo_bibliotecario
    FROM usuario u
    INNER JOIN bibliotecario b ON b.id_usuario = u.id_usuario
    INNER JOIN estado e ON e.id_estado = u.id_estado
    ORDER BY u.apellido, u.nombre;
END$$

CREATE PROCEDURE sp_listar_administradores ()
BEGIN
    SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.documento_identidad,
           u.telefono, e.codigo AS estado, a.codigo_administrador
    FROM usuario u
    INNER JOIN administrador a ON a.id_usuario = u.id_usuario
    INNER JOIN estado e ON e.id_estado = u.id_estado
    ORDER BY u.apellido, u.nombre;
END$$

CREATE PROCEDURE sp_obtener_bibliotecario_por_id (
    IN p_id_usuario INT
)
BEGIN
    SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.documento_identidad,
           u.telefono, e.codigo AS estado, b.codigo_bibliotecario
    FROM usuario u
    INNER JOIN bibliotecario b ON b.id_usuario = u.id_usuario
    INNER JOIN estado e ON e.id_estado = u.id_estado
    WHERE u.id_usuario = p_id_usuario;
END$$

CREATE PROCEDURE sp_obtener_administrador_por_id (
    IN p_id_usuario INT
)
BEGIN
    SELECT u.id_usuario, u.nombre, u.apellido, u.email, u.documento_identidad,
           u.telefono, e.codigo AS estado, a.codigo_administrador
    FROM usuario u
    INNER JOIN administrador a ON a.id_usuario = u.id_usuario
    INNER JOIN estado e ON e.id_estado = u.id_estado
    WHERE u.id_usuario = p_id_usuario;
END$$

DELIMITER ;
