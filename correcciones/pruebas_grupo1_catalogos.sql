-- =========================================================
-- Sistema de Gestión de Biblioteca Universitaria
-- Script de PRUEBAS para el Grupo 1: Facultad, Carrera, Categoria, Autor
--
-- Cómo usar este script en phpMyAdmin:
--   1. Pégalo en la pestaña SQL (NO hace falta cambiar el Delimiter
--      aquí, porque no estamos creando procedimientos, solo llamándolos).
--   2. Ejecuta el script COMPLETO de una sola vez.
--   3. Los bloques marcados "-- Error esperado" van a mostrar un
--      mensaje de error en rojo — eso es correcto, es justamente
--      lo que estamos probando. phpMyAdmin sigue ejecutando el resto.
--   4. Cada CALL con parámetros OUT va seguido de un SELECT para
--      que veas el resultado (@variable) en pantalla.
-- =========================================================

USE biblioteca_db;

-- =========================================================
-- FACULTAD
-- =========================================================

-- Caso OK 1: Insertar Facultad de Ingeniería
CALL sp_insertar_facultad('Facultad de Ingeniería', @id_fac1, @cod_fac1);
SELECT @id_fac1 AS id_facultad, @cod_fac1 AS codigo_facultad;  -- esperado: 1, 'F001'

-- Caso OK 2: Insertar Facultad de Ciencias Económicas
CALL sp_insertar_facultad('Facultad de Ciencias Económicas', @id_fac2, @cod_fac2);
SELECT @id_fac2 AS id_facultad, @cod_fac2 AS codigo_facultad;  -- esperado: 2, 'F002'

-- Error esperado: nombre vacío
CALL sp_insertar_facultad('', @id_err, @cod_err);
-- -> 'Debe ingresar el nombre de la facultad.'

-- Error esperado: nombre duplicado
CALL sp_insertar_facultad('Facultad de Ingeniería', @id_err, @cod_err);
-- -> 'Ya existe una facultad registrada con ese nombre.'

-- Caso OK: actualizar correctamente
CALL sp_actualizar_facultad(@id_fac2, 'Facultad de Ciencias Económicas y Empresariales');
SELECT * FROM facultad WHERE id_facultad = @id_fac2;

-- Error esperado: actualizar un id que no existe
CALL sp_actualizar_facultad(9999, 'Facultad Fantasma');
-- -> 'La facultad indicada no existe.'

-- Error esperado: actualizar con nombre vacío
CALL sp_actualizar_facultad(@id_fac1, '');
-- -> 'Debe ingresar el nombre de la facultad.'

-- Error esperado: eliminar un id que no existe
CALL sp_eliminar_facultad(9999);
-- -> 'La facultad indicada no existe.'

-- Listar y obtener (verificación visual)
CALL sp_listar_facultades();
CALL sp_obtener_facultad_por_id(@id_fac1);


-- =========================================================
-- CARRERA
-- =========================================================

-- Caso OK 1 y 2: dos carreras bajo Facultad de Ingeniería
CALL sp_insertar_carrera('Ingeniería Informática', @id_fac1, @id_car1, @cod_car1);
SELECT @id_car1 AS id_carrera, @cod_car1 AS codigo_carrera;  -- esperado: 'C001'

CALL sp_insertar_carrera('Ingeniería Civil', @id_fac1, @id_car2, @cod_car2);
SELECT @id_car2 AS id_carrera, @cod_car2 AS codigo_carrera;  -- esperado: 'C002'

-- Error esperado: nombre vacío
CALL sp_insertar_carrera('', @id_fac1, @id_err, @cod_err);
-- -> 'Debe ingresar el nombre de la carrera.'

-- Error esperado: facultad inexistente (dispara el handler FK 1452)
CALL sp_insertar_carrera('Ingeniería Ambiental', 9999, @id_err, @cod_err);
-- -> 'La facultad indicada no existe.'

-- Error esperado: carrera duplicada para la misma facultad
CALL sp_insertar_carrera('Ingeniería Informática', @id_fac1, @id_err, @cod_err);
-- -> 'Esa carrera ya existe registrada para la facultad indicada.'

-- Caso OK: actualizar correctamente
CALL sp_actualizar_carrera(@id_car2, 'Ingeniería Civil y Ambiental', @id_fac1);
SELECT * FROM carrera WHERE id_carrera = @id_car2;

-- Error esperado: actualizar un id que no existe
CALL sp_actualizar_carrera(9999, 'Carrera Fantasma', @id_fac1);
-- -> 'La carrera indicada no existe.'

-- Error esperado: actualizar apuntando a una facultad inexistente
CALL sp_actualizar_carrera(@id_car1, 'Ingeniería Informática', 9999);
-- -> 'La facultad indicada no existe.'

-- Error esperado: nombre vacío
CALL sp_actualizar_carrera(@id_car1, '', @id_fac1);
-- -> 'Debe ingresar el nombre de la carrera.'

-- Error esperado: eliminar un id que no existe
CALL sp_eliminar_carrera(9999);
-- -> 'La carrera indicada no existe.'

-- Listar y obtener
CALL sp_listar_carreras();
CALL sp_listar_carreras_por_facultad(@id_fac1);
CALL sp_obtener_carrera_por_id(@id_car1);


-- =========================================================
-- CATEGORIA
-- =========================================================

CALL sp_insertar_categoria('Ciencias de la Computación',
    'Algoritmos, bases de datos y programación.', @id_cat1, @cod_cat1);
SELECT @id_cat1 AS id_categoria, @cod_cat1 AS codigo_categoria;  -- esperado: 'CAT001'

CALL sp_insertar_categoria('Matemática',
    'Cálculo, álgebra y estadística.', @id_cat2, @cod_cat2);
SELECT @id_cat2 AS id_categoria, @cod_cat2 AS codigo_categoria;  -- esperado: 'CAT002'

-- Error esperado: nombre vacío
CALL sp_insertar_categoria('', 'Sin nombre', @id_err, @cod_err);
-- -> 'Debe ingresar el nombre de la categoría.'

-- Error esperado: nombre duplicado
CALL sp_insertar_categoria('Matemática', 'Otra descripción', @id_err, @cod_err);
-- -> 'Ya existe una categoría registrada con ese nombre.'

-- Caso OK: actualizar correctamente
CALL sp_actualizar_categoria(@id_cat2, 'Matemática y Estadística', 'Actualizado.');
SELECT * FROM categoria WHERE id_categoria = @id_cat2;

-- Error esperado: actualizar un id que no existe
CALL sp_actualizar_categoria(9999, 'Fantasma', 'x');
-- -> 'La categoría indicada no existe.'

-- Error esperado: nombre vacío
CALL sp_actualizar_categoria(@id_cat1, '', 'x');
-- -> 'Debe ingresar el nombre de la categoría.'

-- Error esperado: eliminar un id que no existe
CALL sp_eliminar_categoria(9999);
-- -> 'La categoría indicada no existe.'

CALL sp_listar_categorias();
CALL sp_obtener_categoria_por_id(@id_cat1);


-- =========================================================
-- AUTOR
-- =========================================================

CALL sp_insertar_autor('Robert', 'Martin', 'Estadounidense', @id_aut1);
SELECT @id_aut1 AS id_autor;

CALL sp_insertar_autor('Gabriel', 'García Márquez', 'Colombiana', @id_aut2);
SELECT @id_aut2 AS id_autor;

-- Error esperado: apellido vacío
CALL sp_insertar_autor('Anónimo', '', 'Peruana', @id_err);
-- -> 'Debe ingresar nombre y apellido del autor.'

-- Caso OK: actualizar correctamente
CALL sp_actualizar_autor(@id_aut1, 'Robert C.', 'Martin', 'Estadounidense');
SELECT * FROM autor WHERE id_autor = @id_aut1;

-- Error esperado: actualizar un id que no existe
CALL sp_actualizar_autor(9999, 'X', 'Y', 'Z');
-- -> 'El autor indicado no existe.'

-- Error esperado: nombre vacío
CALL sp_actualizar_autor(@id_aut2, '', 'García Márquez', 'Colombiana');
-- -> 'Debe ingresar nombre y apellido del autor.'

-- Error esperado: eliminar un id que no existe
CALL sp_eliminar_autor(9999);
-- -> 'El autor indicado no existe.'

CALL sp_listar_autores();
CALL sp_buscar_autores_por_apellido('Mart');
CALL sp_obtener_autor_por_id(@id_aut1);


-- =========================================================
-- ERROR 1451 (FK: no se puede borrar un padre con hijos)
-- Usamos una facultad y carrera TEMPORALES solo para esta prueba,
-- así no tocamos los datos reales que acabamos de crear arriba
-- (los vas a necesitar para probar Lector en el Grupo 2).
-- =========================================================

CALL sp_insertar_facultad('Facultad Temporal de Prueba', @id_fac_temp, @cod_fac_temp);
CALL sp_insertar_carrera('Carrera Temporal de Prueba', @id_fac_temp, @id_car_temp, @cod_car_temp);

-- Error esperado: NO debería poder eliminarse (tiene 1 carrera asociada)
CALL sp_eliminar_facultad(@id_fac_temp);
-- -> 'No se puede eliminar: la facultad tiene carreras asociadas.'

-- Ahora eliminamos primero la carrera hija (sin problema, no tiene lectores)
CALL sp_eliminar_carrera(@id_car_temp);

-- Y recién ahora sí se puede eliminar la facultad (ya no tiene hijos)
CALL sp_eliminar_facultad(@id_fac_temp);

-- Verificación final: la facultad y carrera temporales ya no existen,
-- pero tus datos reales (Ingeniería, Ciencias Económicas, etc.) siguen ahí.
CALL sp_listar_facultades();
CALL sp_listar_carreras();

-- =========================================================
-- Nota: el error 1451 para Categoria y Autor (intentar borrar una
-- categoría o autor que ya tiene libros asociados) todavía no se
-- puede probar, porque la tabla Libro se crea recién en un grupo
-- posterior de Stored Procedures. Lo probaremos ahí.
-- =========================================================
