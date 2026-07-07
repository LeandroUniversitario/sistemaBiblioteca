-- =========================================================
-- Sistema de Gestión de Biblioteca Universitaria
-- Script 2 (Grupo 1): Stored Procedures - Catálogos base
-- Tablas cubiertas: facultad, carrera, categoria, autor
--
-- RECORDATORIO phpMyAdmin: antes de ejecutar este bloque en la
-- pestaña SQL, cambia el campo "Delimiter" (debajo del cuadro
-- de texto) a  $$  y vuélvelo a  ;  al terminar.
-- =========================================================

USE biblioteca_db;

DELIMITER $$

-- =========================================================
-- FACULTAD
-- =========================================================

CREATE PROCEDURE sp_insertar_facultad (
    IN  p_nombre_facultad VARCHAR(100),
    OUT p_id_facultad     INT,
    OUT p_codigo_facultad VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062  -- duplicado (nombre_facultad UNIQUE)
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe una facultad registrada con ese nombre.';
    END;

    IF TRIM(p_nombre_facultad) = '' OR p_nombre_facultad IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar el nombre de la facultad.';
    END IF;

    INSERT INTO facultad (nombre_facultad) VALUES (p_nombre_facultad);

    SET p_id_facultad = LAST_INSERT_ID();
    SET p_codigo_facultad = CONCAT('F', LPAD(p_id_facultad, 3, '0'));

    UPDATE facultad
    SET codigo_facultad = p_codigo_facultad
    WHERE id_facultad = p_id_facultad;
END$$

CREATE PROCEDURE sp_actualizar_facultad (
    IN p_id_facultad     INT,
    IN p_nombre_facultad  VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe otra facultad registrada con ese nombre.';
    END;

    IF NOT EXISTS (SELECT 1 FROM facultad WHERE id_facultad = p_id_facultad) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La facultad indicada no existe.';
    END IF;

    IF TRIM(p_nombre_facultad) = '' OR p_nombre_facultad IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar el nombre de la facultad.';
    END IF;

    UPDATE facultad
    SET nombre_facultad = p_nombre_facultad
    WHERE id_facultad = p_id_facultad;
END$$

CREATE PROCEDURE sp_eliminar_facultad (
    IN p_id_facultad INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1451  -- FK: tiene carreras asociadas
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar: la facultad tiene carreras asociadas.';
    END;

    IF NOT EXISTS (SELECT 1 FROM facultad WHERE id_facultad = p_id_facultad) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La facultad indicada no existe.';
    END IF;

    DELETE FROM facultad WHERE id_facultad = p_id_facultad;
END$$

CREATE PROCEDURE sp_listar_facultades ()
BEGIN
    SELECT id_facultad, codigo_facultad, nombre_facultad
    FROM facultad
    ORDER BY nombre_facultad;
END$$

CREATE PROCEDURE sp_obtener_facultad_por_id (
    IN p_id_facultad INT
)
BEGIN
    SELECT id_facultad, codigo_facultad, nombre_facultad
    FROM facultad
    WHERE id_facultad = p_id_facultad;
END$$


-- =========================================================
-- CARRERA
-- =========================================================

CREATE PROCEDURE sp_insertar_carrera (
    IN  p_nombre_carrera VARCHAR(100),
    IN  p_id_facultad    INT,
    OUT p_id_carrera     INT,
    OUT p_codigo_carrera VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Esa carrera ya existe registrada para la facultad indicada.';
    END;

    DECLARE EXIT HANDLER FOR 1452  -- FK: id_facultad no existe
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La facultad indicada no existe.';
    END;

    IF TRIM(p_nombre_carrera) = '' OR p_nombre_carrera IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar el nombre de la carrera.';
    END IF;

    INSERT INTO carrera (nombre_carrera, id_facultad)
    VALUES (p_nombre_carrera, p_id_facultad);

    SET p_id_carrera = LAST_INSERT_ID();
    SET p_codigo_carrera = CONCAT('C', LPAD(p_id_carrera, 3, '0'));

    UPDATE carrera
    SET codigo_carrera = p_codigo_carrera
    WHERE id_carrera = p_id_carrera;
END$$

CREATE PROCEDURE sp_actualizar_carrera (
    IN p_id_carrera    INT,
    IN p_nombre_carrera VARCHAR(100),
    IN p_id_facultad   INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Esa carrera ya existe registrada para la facultad indicada.';
    END;

    DECLARE EXIT HANDLER FOR 1452  -- FK: id_facultad no existe
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La facultad indicada no existe.';
    END;

    IF NOT EXISTS (SELECT 1 FROM carrera WHERE id_carrera = p_id_carrera) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La carrera indicada no existe.';
    END IF;

    IF TRIM(p_nombre_carrera) = '' OR p_nombre_carrera IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar el nombre de la carrera.';
    END IF;

    UPDATE carrera
    SET nombre_carrera = p_nombre_carrera,
        id_facultad    = p_id_facultad
    WHERE id_carrera = p_id_carrera;
END$$

CREATE PROCEDURE sp_eliminar_carrera (
    IN p_id_carrera INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1451  -- FK: tiene lectores asociados
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar: la carrera tiene lectores asociados.';
    END;

    IF NOT EXISTS (SELECT 1 FROM carrera WHERE id_carrera = p_id_carrera) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La carrera indicada no existe.';
    END IF;

    DELETE FROM carrera WHERE id_carrera = p_id_carrera;
END$$

CREATE PROCEDURE sp_listar_carreras ()
BEGIN
    -- JOIN para mostrar el nombre de la facultad, no solo su id
    SELECT c.id_carrera, c.codigo_carrera, c.nombre_carrera,
           f.id_facultad, f.nombre_facultad
    FROM carrera c
    INNER JOIN facultad f ON f.id_facultad = c.id_facultad
    ORDER BY f.nombre_facultad, c.nombre_carrera;
END$$

CREATE PROCEDURE sp_listar_carreras_por_facultad (
    IN p_id_facultad INT
)
BEGIN
    SELECT id_carrera, codigo_carrera, nombre_carrera
    FROM carrera
    WHERE id_facultad = p_id_facultad
    ORDER BY nombre_carrera;
END$$
CREATE PROCEDURE sp_obtener_carrera_por_id (
    IN p_id_carrera INT
)
BEGIN
    SELECT c.id_carrera, c.codigo_carrera, c.nombre_carrera,
           f.id_facultad, f.nombre_facultad
    FROM carrera c
    INNER JOIN facultad f ON f.id_facultad = c.id_facultad
    WHERE c.id_carrera = p_id_carrera;
END$$

-- =========================================================
-- CATEGORIA
-- =========================================================

CREATE PROCEDURE sp_insertar_categoria (
    IN  p_nombre_categoria VARCHAR(80),
    IN  p_descripcion      VARCHAR(255),
    OUT p_id_categoria     INT,
    OUT p_codigo_categoria VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe una categoría registrada con ese nombre.';
    END;

    IF TRIM(p_nombre_categoria) = '' OR p_nombre_categoria IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar el nombre de la categoría.';
    END IF;

    INSERT INTO categoria (nombre_categoria, descripcion)
    VALUES (p_nombre_categoria, p_descripcion);

    SET p_id_categoria = LAST_INSERT_ID();
    SET p_codigo_categoria = CONCAT('CAT', LPAD(p_id_categoria, 3, '0'));

    UPDATE categoria
    SET codigo_categoria = p_codigo_categoria
    WHERE id_categoria = p_id_categoria;
END$$

CREATE PROCEDURE sp_actualizar_categoria (
    IN p_id_categoria     INT,
    IN p_nombre_categoria VARCHAR(80),
    IN p_descripcion      VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR 1062
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe otra categoría registrada con ese nombre.';
    END;

    IF NOT EXISTS (SELECT 1 FROM categoria WHERE id_categoria = p_id_categoria) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría indicada no existe.';
    END IF;

    IF TRIM(p_nombre_categoria) = '' OR p_nombre_categoria IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar el nombre de la categoría.';
    END IF;

    UPDATE categoria
    SET nombre_categoria = p_nombre_categoria,
        descripcion      = p_descripcion
    WHERE id_categoria = p_id_categoria;
END$$

CREATE PROCEDURE sp_eliminar_categoria (
    IN p_id_categoria INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1451  -- FK: tiene libros asociados
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar: la categoría tiene libros asociados.';
    END;

    IF NOT EXISTS (SELECT 1 FROM categoria WHERE id_categoria = p_id_categoria) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría indicada no existe.';
    END IF;

    DELETE FROM categoria WHERE id_categoria = p_id_categoria;
END$$

CREATE PROCEDURE sp_listar_categorias ()
BEGIN
    SELECT id_categoria, codigo_categoria, nombre_categoria, descripcion
    FROM categoria
    ORDER BY nombre_categoria;
END$$

CREATE PROCEDURE sp_obtener_categoria_por_id (
    IN p_id_categoria INT
)
BEGIN
    SELECT id_categoria, codigo_categoria, nombre_categoria, descripcion
    FROM categoria
    WHERE id_categoria = p_id_categoria;
END$$

-- =========================================================
-- AUTOR
-- =========================================================

CREATE PROCEDURE sp_insertar_autor (
    IN  p_nombre       VARCHAR(100),
    IN  p_apellido     VARCHAR(100),
    IN  p_nacionalidad VARCHAR(60),
    OUT p_id_autor     INT
)
BEGIN
    IF TRIM(p_nombre) = '' OR p_nombre IS NULL OR TRIM(p_apellido) = '' OR p_apellido IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido del autor.';
    END IF;

    INSERT INTO autor (nombre, apellido, nacionalidad)
    VALUES (p_nombre, p_apellido, p_nacionalidad);

    SET p_id_autor = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_actualizar_autor (
    IN p_id_autor     INT,
    IN p_nombre       VARCHAR(100),
    IN p_apellido     VARCHAR(100),
    IN p_nacionalidad VARCHAR(60)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM autor WHERE id_autor = p_id_autor) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El autor indicado no existe.';
    END IF;

    IF TRIM(p_nombre) = '' OR p_nombre IS NULL OR TRIM(p_apellido) = '' OR p_apellido IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Debe ingresar nombre y apellido del autor.';
    END IF;

    UPDATE autor
    SET nombre       = p_nombre,
        apellido     = p_apellido,
        nacionalidad = p_nacionalidad
    WHERE id_autor = p_id_autor;
END$$

CREATE PROCEDURE sp_eliminar_autor (
    IN p_id_autor INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1451  -- FK: tiene libros asociados (libro_autor)
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar: el autor tiene libros asociados.';
    END;

    IF NOT EXISTS (SELECT 1 FROM autor WHERE id_autor = p_id_autor) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El autor indicado no existe.';
    END IF;

    DELETE FROM autor WHERE id_autor = p_id_autor;
END$$

CREATE PROCEDURE sp_listar_autores ()
BEGIN
    SELECT id_autor, nombre, apellido, nacionalidad
    FROM autor
    ORDER BY apellido, nombre;
END$$

CREATE PROCEDURE sp_buscar_autores_por_apellido (
    IN p_apellido VARCHAR(100)
)
BEGIN
    -- Búsqueda parcial (RF-05); usa el índice idx_autor_apellido
    SELECT id_autor, nombre, apellido, nacionalidad
    FROM autor
    WHERE apellido LIKE CONCAT(p_apellido, '%')
    ORDER BY apellido, nombre;
END$$

CREATE PROCEDURE sp_obtener_autor_por_id (
    IN p_id_autor INT
)
BEGIN
    SELECT id_autor, nombre, apellido, nacionalidad
    FROM autor
    WHERE id_autor = p_id_autor;
END$$

DELIMITER ;

