-- =========================================================
-- Sistema de Gestión de Biblioteca Universitaria
-- Script 5 (Grupo 3): Stored Procedures - Libro / Libro_Autor /
--                      Ejemplar
--
-- RECORDATORIO phpMyAdmin: cambia el Delimiter a  $$  antes de
-- ejecutar este bloque, y vuélvelo a  ;  al terminar.
-- =========================================================

USE biblioteca_db;

DELIMITER $$

-- =========================================================
-- LIBRO
-- =========================================================

DROP PROCEDURE IF EXISTS sp_insertar_libro$$
CREATE PROCEDURE sp_insertar_libro (
    IN  p_titulo           VARCHAR(200),
    IN  p_isbn             VARCHAR(20),
    IN  p_id_categoria     INT,
    IN  p_anio_publicacion INT,
    IN  p_editorial        VARCHAR(100),
    OUT p_id_libro         INT
)
BEGIN
    DECLARE v_id_estado_activo INT;
    DECLARE v_texto_error VARCHAR(255) DEFAULT '';

    IF p_titulo IS NULL OR TRIM(p_titulo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe ingresar el título del libro.';
    END IF;
    SET p_titulo = TRIM(p_titulo);

    IF p_anio_publicacion IS NOT NULL AND p_anio_publicacion > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El año de publicación no puede ser mayor al año actual.';
    END IF;

    SELECT id_estado INTO v_id_estado_activo
    FROM estado WHERE entidad = 'libro' AND codigo = 'activo' LIMIT 1;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            IF v_texto_error LIKE '%isbn%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un libro registrado con ese ISBN.';
            ELSEIF v_texto_error LIKE '%fk_libro_categoria%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría indicada no existe.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        INSERT INTO libro (titulo, isbn, id_categoria, anio_publicacion, editorial, id_estado)
        VALUES (p_titulo, p_isbn, p_id_categoria, p_anio_publicacion, p_editorial, v_id_estado_activo);

        SET p_id_libro = LAST_INSERT_ID();
    END;
END$$

DROP PROCEDURE IF EXISTS sp_actualizar_libro$$
CREATE PROCEDURE sp_actualizar_libro (
    IN p_id_libro         INT,
    IN p_titulo           VARCHAR(200),
    IN p_isbn             VARCHAR(20),
    IN p_id_categoria     INT,
    IN p_anio_publicacion INT,
    IN p_editorial        VARCHAR(100)
)
BEGIN
    DECLARE v_texto_error VARCHAR(255) DEFAULT '';

    IF p_titulo IS NULL OR TRIM(p_titulo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe ingresar el título del libro.';
    END IF;
    SET p_titulo = TRIM(p_titulo);

    IF p_anio_publicacion IS NOT NULL AND p_anio_publicacion > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El año de publicación no puede ser mayor al año actual.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM libro WHERE id_libro = p_id_libro) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro indicado no existe.';
    END IF;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            IF v_texto_error LIKE '%isbn%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otro libro registrado con ese ISBN.';
            ELSEIF v_texto_error LIKE '%fk_libro_categoria%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría indicada no existe.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        UPDATE libro
        SET titulo = p_titulo, isbn = p_isbn, id_categoria = p_id_categoria,
            anio_publicacion = p_anio_publicacion, editorial = p_editorial
        WHERE id_libro = p_id_libro;
    END;
END$$

DROP PROCEDURE IF EXISTS sp_dar_baja_libro$$
CREATE PROCEDURE sp_dar_baja_libro (
    IN p_id_libro INT
)
BEGIN
    DECLARE v_id_estado_baja INT;

    IF NOT EXISTS (SELECT 1 FROM libro WHERE id_libro = p_id_libro) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro indicado no existe.';
    END IF;

    SELECT id_estado INTO v_id_estado_baja FROM estado WHERE entidad = 'libro' AND codigo = 'baja' LIMIT 1;
    UPDATE libro SET id_estado = v_id_estado_baja WHERE id_libro = p_id_libro;
END$$

DROP PROCEDURE IF EXISTS sp_reactivar_libro$$
CREATE PROCEDURE sp_reactivar_libro (
    IN p_id_libro INT
)
BEGIN
    DECLARE v_id_estado_activo INT;

    IF NOT EXISTS (SELECT 1 FROM libro WHERE id_libro = p_id_libro) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro indicado no existe.';
    END IF;

    SELECT id_estado INTO v_id_estado_activo FROM estado WHERE entidad = 'libro' AND codigo = 'activo' LIMIT 1;
    UPDATE libro SET id_estado = v_id_estado_activo WHERE id_libro = p_id_libro;
END$$

DROP PROCEDURE IF EXISTS sp_listar_libros$$
CREATE PROCEDURE sp_listar_libros ()
BEGIN
    SELECT l.id_libro, l.titulo, l.isbn, l.anio_publicacion, l.editorial,
           MAX(c.nombre_categoria) AS nombre_categoria, MAX(es.codigo) AS estado,
           GROUP_CONCAT(CONCAT(a.nombre, ' ', a.apellido) SEPARATOR ', ') AS autores,
           (SELECT COUNT(*) FROM ejemplar ej WHERE ej.id_libro = l.id_libro) AS total_ejemplares,
           (SELECT COUNT(*) FROM ejemplar ej
              INNER JOIN estado ee ON ee.id_estado = ej.id_estado
              WHERE ej.id_libro = l.id_libro AND ee.entidad = 'ejemplar' AND ee.codigo = 'disponible'
           ) AS ejemplares_disponibles
    FROM libro l
    INNER JOIN categoria c   ON c.id_categoria = l.id_categoria
    INNER JOIN estado es     ON es.id_estado = l.id_estado
    LEFT JOIN  libro_autor la ON la.id_libro = l.id_libro
    LEFT JOIN  autor a        ON a.id_autor = la.id_autor
    GROUP BY l.id_libro
    ORDER BY l.titulo;
END$$

DROP PROCEDURE IF EXISTS sp_obtener_libro_por_id$$
CREATE PROCEDURE sp_obtener_libro_por_id (
    IN p_id_libro INT
)
BEGIN
    SELECT l.id_libro, l.titulo, l.isbn, l.anio_publicacion, l.editorial,
           MAX(c.id_categoria) AS id_categoria, MAX(c.nombre_categoria) AS nombre_categoria, MAX(es.codigo) AS estado,
           GROUP_CONCAT(CONCAT(a.nombre, ' ', a.apellido) SEPARATOR ', ') AS autores,
           (SELECT COUNT(*) FROM ejemplar ej WHERE ej.id_libro = l.id_libro) AS total_ejemplares,
           (SELECT COUNT(*) FROM ejemplar ej
              INNER JOIN estado ee ON ee.id_estado = ej.id_estado
              WHERE ej.id_libro = l.id_libro AND ee.entidad = 'ejemplar' AND ee.codigo = 'disponible'
           ) AS ejemplares_disponibles
    FROM libro l
    INNER JOIN categoria c   ON c.id_categoria = l.id_categoria
    INNER JOIN estado es     ON es.id_estado = l.id_estado
    LEFT JOIN  libro_autor la ON la.id_libro = l.id_libro
    LEFT JOIN  autor a        ON a.id_autor = la.id_autor
    WHERE l.id_libro = p_id_libro
    GROUP BY l.id_libro;
END$$

DROP PROCEDURE IF EXISTS sp_buscar_libros$$
CREATE PROCEDURE sp_buscar_libros (
    IN p_termino VARCHAR(150)
)
BEGIN
    SET p_termino = TRIM(p_termino);

    -- Búsqueda por título, categoría o autor (RF-05). DISTINCT evita
    -- filas repetidas cuando un libro coincide por varios autores.
    SELECT DISTINCT l.id_libro, l.titulo, l.isbn, c.nombre_categoria, es.codigo AS estado
    FROM libro l
    INNER JOIN categoria c    ON c.id_categoria = l.id_categoria
    INNER JOIN estado es      ON es.id_estado = l.id_estado
    LEFT JOIN  libro_autor la ON la.id_libro = l.id_libro
    LEFT JOIN  autor a        ON a.id_autor = la.id_autor
    WHERE l.titulo LIKE CONCAT('%', p_termino, '%')
       OR c.nombre_categoria LIKE CONCAT('%', p_termino, '%')
       OR a.nombre LIKE CONCAT('%', p_termino, '%')
       OR a.apellido LIKE CONCAT('%', p_termino, '%')
    ORDER BY l.titulo;
END$$


-- =========================================================
-- LIBRO_AUTOR (tabla puente N:M)
-- =========================================================

DROP PROCEDURE IF EXISTS sp_asignar_autor_libro$$
CREATE PROCEDURE sp_asignar_autor_libro (
    IN p_id_libro INT,
    IN p_id_autor INT
)
BEGIN
    DECLARE v_texto_error VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
        IF v_texto_error LIKE '%PRIMARY%' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese autor ya está asignado a este libro.';
        ELSEIF v_texto_error LIKE '%fk_libroautor_libro%' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro indicado no existe.';
        ELSEIF v_texto_error LIKE '%fk_libroautor_autor%' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El autor indicado no existe.';
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
        END IF;
    END;

    INSERT INTO libro_autor (id_libro, id_autor) VALUES (p_id_libro, p_id_autor);
END$$

DROP PROCEDURE IF EXISTS sp_quitar_autor_libro$$
CREATE PROCEDURE sp_quitar_autor_libro (
    IN p_id_libro INT,
    IN p_id_autor INT
)
BEGIN
    DELETE FROM libro_autor WHERE id_libro = p_id_libro AND id_autor = p_id_autor;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esa asociación no existía.';
    END IF;
END$$

DROP PROCEDURE IF EXISTS sp_listar_autores_por_libro$$
CREATE PROCEDURE sp_listar_autores_por_libro (
    IN p_id_libro INT
)
BEGIN
    SELECT a.id_autor, a.nombre, a.apellido, a.nacionalidad
    FROM libro_autor la
    INNER JOIN autor a ON a.id_autor = la.id_autor
    WHERE la.id_libro = p_id_libro
    ORDER BY a.apellido, a.nombre;
END$$

DROP PROCEDURE IF EXISTS sp_listar_libros_por_autor$$
CREATE PROCEDURE sp_listar_libros_por_autor (
    IN p_id_autor INT
)
BEGIN
    SELECT l.id_libro, l.titulo, l.isbn
    FROM libro_autor la
    INNER JOIN libro l ON l.id_libro = la.id_libro
    WHERE la.id_autor = p_id_autor
    ORDER BY l.titulo;
END$$


-- =========================================================
-- EJEMPLAR
-- =========================================================

DROP PROCEDURE IF EXISTS sp_insertar_ejemplar$$
CREATE PROCEDURE sp_insertar_ejemplar (
    IN  p_id_libro        INT,
    IN  p_codigo_ejemplar VARCHAR(30),
    IN  p_ubicacion       VARCHAR(50),
    OUT p_id_ejemplar     INT
)
BEGIN
    DECLARE v_id_estado_disponible INT;
    DECLARE v_texto_error VARCHAR(255) DEFAULT '';

    IF p_codigo_ejemplar IS NULL OR TRIM(p_codigo_ejemplar) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe ingresar el código del ejemplar.';
    END IF;
    SET p_codigo_ejemplar = TRIM(p_codigo_ejemplar);

    SELECT id_estado INTO v_id_estado_disponible
    FROM estado WHERE entidad = 'ejemplar' AND codigo = 'disponible' LIMIT 1;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            IF v_texto_error LIKE '%codigo_ejemplar%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un ejemplar con ese código.';
            ELSEIF v_texto_error LIKE '%fk_ejemplar_libro%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro indicado no existe.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        INSERT INTO ejemplar (id_libro, codigo_ejemplar, id_estado, ubicacion)
        VALUES (p_id_libro, p_codigo_ejemplar, v_id_estado_disponible, p_ubicacion);

        SET p_id_ejemplar = LAST_INSERT_ID();
    END;
END$$

DROP PROCEDURE IF EXISTS sp_actualizar_ejemplar$$
CREATE PROCEDURE sp_actualizar_ejemplar (
    IN p_id_ejemplar     INT,
    IN p_codigo_ejemplar VARCHAR(30),
    IN p_ubicacion       VARCHAR(50)
)
BEGIN
    DECLARE v_texto_error VARCHAR(255) DEFAULT '';

    IF p_codigo_ejemplar IS NULL OR TRIM(p_codigo_ejemplar) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe ingresar el código del ejemplar.';
    END IF;
    SET p_codigo_ejemplar = TRIM(p_codigo_ejemplar);

    IF NOT EXISTS (SELECT 1 FROM ejemplar WHERE id_ejemplar = p_id_ejemplar) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar indicado no existe.';
    END IF;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_texto_error = MESSAGE_TEXT;
            IF v_texto_error LIKE '%codigo_ejemplar%' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otro ejemplar con ese código.';
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_texto_error;
            END IF;
        END;

        UPDATE ejemplar
        SET codigo_ejemplar = p_codigo_ejemplar, ubicacion = p_ubicacion
        WHERE id_ejemplar = p_id_ejemplar;
    END;
END$$

DROP PROCEDURE IF EXISTS sp_cambiar_estado_ejemplar$$
CREATE PROCEDURE sp_cambiar_estado_ejemplar (
    IN p_id_ejemplar  INT,
    IN p_codigo_estado VARCHAR(30)
)
BEGIN
    DECLARE v_id_estado INT;

    IF NOT EXISTS (SELECT 1 FROM ejemplar WHERE id_ejemplar = p_id_ejemplar) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ejemplar indicado no existe.';
    END IF;

    -- 'prestado' NUNCA se asigna manualmente: solo lo hace el SP de
    -- registrar préstamo (Grupo 4), como parte de esa transacción.
    IF p_codigo_estado NOT IN ('disponible', 'dañado', 'baja') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado no permitido manualmente. El estado "prestado" solo se asigna automáticamente al registrar un préstamo.';
    END IF;

    SELECT id_estado INTO v_id_estado
    FROM estado WHERE entidad = 'ejemplar' AND codigo = p_codigo_estado LIMIT 1;

    UPDATE ejemplar SET id_estado = v_id_estado WHERE id_ejemplar = p_id_ejemplar;
END$$

DROP PROCEDURE IF EXISTS sp_eliminar_ejemplar$$
CREATE PROCEDURE sp_eliminar_ejemplar (
    IN p_id_ejemplar INT
)
BEGIN
    DECLARE EXIT HANDLER FOR 1451  -- tiene préstamos históricos asociados
    BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar: el ejemplar tiene préstamos registrados. Use "dar de baja" en su lugar.';
    END;

    DELETE FROM ejemplar WHERE id_ejemplar = p_id_ejemplar;
END$$

DROP PROCEDURE IF EXISTS sp_listar_ejemplares_por_libro$$
CREATE PROCEDURE sp_listar_ejemplares_por_libro (
    IN p_id_libro INT
)
BEGIN
    SELECT ej.id_ejemplar, ej.codigo_ejemplar, ej.ubicacion, es.codigo AS estado
    FROM ejemplar ej
    INNER JOIN estado es ON es.id_estado = ej.id_estado
    WHERE ej.id_libro = p_id_libro
    ORDER BY ej.codigo_ejemplar;
END$$

DROP PROCEDURE IF EXISTS sp_listar_ejemplares_disponibles$$
CREATE PROCEDURE sp_listar_ejemplares_disponibles ()
BEGIN
    SELECT ej.id_ejemplar, ej.codigo_ejemplar, ej.ubicacion,
           l.id_libro, l.titulo
    FROM ejemplar ej
    INNER JOIN estado es ON es.id_estado = ej.id_estado
    INNER JOIN libro l   ON l.id_libro = ej.id_libro
    WHERE es.entidad = 'ejemplar' AND es.codigo = 'disponible'
    ORDER BY l.titulo, ej.codigo_ejemplar;
END$$

DELIMITER ;
