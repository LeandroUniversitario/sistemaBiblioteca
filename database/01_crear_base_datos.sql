-- =========================================================
-- Sistema de Gestión de Biblioteca Universitaria
-- Script 1 (v3): Creación de la Base de Datos y Tablas
-- Curso: Modelado de Datos
--
-- MOTOR: InnoDB EXPLÍCITO en TODAS las tablas.
-- Esto es indispensable para que phpMyAdmin pueda detectar y
-- DIBUJAR las relaciones automáticamente (pestaña "Diseñador" /
-- "Designer"). MyISAM no soporta FK reales: phpMyAdmin no
-- mostraría ninguna línea de relación si se usara ese motor.
--
-- CORRECCIONES aplicadas sobre el DBML recibido:
--  1. prestamo.id_bibliotecario ahora referencia
--     bibliotecario(id_usuario), no usuario(id_usuario) -- por
--     simetría con id_lector, y para que el esquema impida
--     asignar un lector o administrador como bibliotecario de
--     un préstamo.
--  2. lector.id_carrera pasa a ser NULL-able: un docente,
--     personal administrativo o lector externo no
--     necesariamente pertenece a una carrera (concepto propio
--     de estudiantes). La regla "solo estudiantes requieren
--     carrera" se valida en el Stored Procedure (Paso 7).
-- =========================================================


-- =========================================================
-- Tabla: estado (catálogo genérico)
-- =========================================================
CREATE TABLE estado (
    id_estado   INT AUTO_INCREMENT PRIMARY KEY,
    entidad     VARCHAR(30)  NOT NULL,
    codigo      VARCHAR(30)  NOT NULL,
    descripcion VARCHAR(100) NULL,

    UNIQUE KEY uq_estado_entidad_codigo (entidad, codigo)
) ENGINE = InnoDB;

INSERT INTO estado (entidad, codigo, descripcion) VALUES
    ('usuario',  'activo',    'Usuario habilitado para operar en el sistema'),
    ('usuario',  'inactivo',  'Usuario deshabilitado (baja lógica)'),
    ('libro',    'activo',    'Título disponible en el catálogo'),
    ('libro',    'baja',      'Título retirado del catálogo (baja lógica)'),
    ('ejemplar', 'disponible','Ejemplar listo para préstamo'),
    ('ejemplar', 'prestado',  'Ejemplar actualmente prestado'),
    ('ejemplar', 'dañado',    'Ejemplar dañado, no prestable'),
    ('ejemplar', 'baja',      'Ejemplar retirado definitivamente'),
    ('prestamo', 'activo',    'Préstamo vigente, no devuelto'),
    ('prestamo', 'devuelto',  'Préstamo devuelto dentro o fuera de fecha'),
    ('prestamo', 'vencido',   'Préstamo no devuelto y fuera de fecha límite'),
    ('multa',    'pendiente', 'Multa generada, aún no pagada'),
    ('multa',    'pagada',    'Multa pagada por el lector');

-- =========================================================
-- Tabla: facultad
-- codigo_facultad se autogenera con un TRIGGER (ver más abajo).
-- =========================================================
CREATE TABLE facultad (
    id_facultad     INT AUTO_INCREMENT PRIMARY KEY,
    codigo_facultad VARCHAR(10) NULL UNIQUE,
    nombre_facultad VARCHAR(100) NOT NULL UNIQUE
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: carrera
-- =========================================================
CREATE TABLE carrera (
    id_carrera     INT AUTO_INCREMENT PRIMARY KEY,
    codigo_carrera VARCHAR(10) NULL UNIQUE,
    nombre_carrera VARCHAR(100) NOT NULL,
    id_facultad    INT NOT NULL,

    CONSTRAINT fk_carrera_facultad
        FOREIGN KEY (id_facultad) REFERENCES facultad(id_facultad)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    UNIQUE KEY uq_carrera_nombre_facultad (nombre_carrera, id_facultad)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: usuario (superclase)
-- =========================================================
CREATE TABLE usuario (
    id_usuario          INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(100)  NOT NULL,
    apellido            VARCHAR(100)  NOT NULL,
    email               VARCHAR(150)  NOT NULL UNIQUE,
    password_hash       VARCHAR(255)  NOT NULL,
    rol                 ENUM('lector', 'bibliotecario', 'administrador') NOT NULL,
    documento_identidad VARCHAR(20)   NOT NULL UNIQUE,
    telefono            VARCHAR(20)   NULL,
    fecha_registro      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_estado           INT           NOT NULL,

    CONSTRAINT fk_usuario_estado
        FOREIGN KEY (id_estado) REFERENCES estado(id_estado),

    INDEX idx_usuario_rol (rol)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: lector (especialización 1:1 de usuario)
-- id_carrera es NULL-able (ver corrección al inicio del script).
-- =========================================================
CREATE TABLE lector (
    id_usuario           INT NOT NULL PRIMARY KEY,
    codigo_universitario VARCHAR(20) NOT NULL UNIQUE,
    id_carrera           INT NULL,
    tipo_lector          ENUM('estudiante', 'docente', 'personal_administrativo', 'externo') NOT NULL,

    CONSTRAINT fk_lector_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_lector_carrera
        FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: bibliotecario (especialización 1:1 de usuario)
-- codigo_bibliotecario se autogenera con un TRIGGER.
-- =========================================================
CREATE TABLE bibliotecario (
    id_usuario           INT NOT NULL PRIMARY KEY,
    codigo_bibliotecario VARCHAR(10) NULL UNIQUE,

    CONSTRAINT fk_bibliotecario_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: administrador (especialización 1:1 de usuario)
-- codigo_administrador se autogenera con un TRIGGER.
-- No participa en Prestamo: gestiona catálogo académico,
-- cuentas de usuario y parámetros del sistema.
-- =========================================================
CREATE TABLE administrador (
    id_usuario           INT NOT NULL PRIMARY KEY,
    codigo_administrador VARCHAR(10) NULL UNIQUE,

    CONSTRAINT fk_administrador_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: parametro_sistema
-- Configuración de negocio editable sin tocar código, con
-- trazabilidad de auditoría hacia el administrador que hizo el
-- último cambio.
-- =========================================================
CREATE TABLE parametro_sistema (
    id_parametro       INT AUTO_INCREMENT PRIMARY KEY,
    nombre_parametro   VARCHAR(60)  NOT NULL UNIQUE,
    valor              VARCHAR(30)  NOT NULL,
    descripcion        VARCHAR(200) NULL,
    id_administrador   INT          NOT NULL,
    fecha_modificacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_parametro_administrador
        FOREIGN KEY (id_administrador) REFERENCES administrador(id_usuario)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: categoria
-- codigo_categoria se autogenera con un TRIGGER.
-- =========================================================
CREATE TABLE categoria (
    id_categoria     INT AUTO_INCREMENT PRIMARY KEY,
    codigo_categoria VARCHAR(10) NULL UNIQUE,
    nombre_categoria VARCHAR(80)  NOT NULL UNIQUE,
    descripcion      VARCHAR(255) NULL
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: autor
-- =========================================================
CREATE TABLE autor (
    id_autor     INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(60)  NULL,

    INDEX idx_autor_apellido (apellido)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: libro
-- =========================================================
CREATE TABLE libro (
    id_libro         INT AUTO_INCREMENT PRIMARY KEY,
    titulo           VARCHAR(200) NOT NULL,
    isbn             VARCHAR(20)  NOT NULL UNIQUE,
    id_categoria     INT          NOT NULL,
    anio_publicacion YEAR         NULL,
    editorial        VARCHAR(100) NULL,
    id_estado        INT          NOT NULL,

    CONSTRAINT fk_libro_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_libro_estado
        FOREIGN KEY (id_estado) REFERENCES estado(id_estado),

    INDEX idx_libro_titulo (titulo)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla intermedia: libro_autor (resuelve relación N:M)
-- =========================================================
CREATE TABLE libro_autor (
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,

    PRIMARY KEY (id_libro, id_autor),

    CONSTRAINT fk_libroautor_libro
        FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
        ON DELETE CASCADE,

    CONSTRAINT fk_libroautor_autor
        FOREIGN KEY (id_autor) REFERENCES autor(id_autor)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: ejemplar
-- =========================================================
CREATE TABLE ejemplar (
    id_ejemplar     INT AUTO_INCREMENT PRIMARY KEY,
    id_libro        INT         NOT NULL,
    codigo_ejemplar VARCHAR(30) NOT NULL UNIQUE,
    id_estado       INT         NOT NULL,
    ubicacion       VARCHAR(50) NULL,

    CONSTRAINT fk_ejemplar_libro
        FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_ejemplar_estado
        FOREIGN KEY (id_estado) REFERENCES estado(id_estado),

    INDEX idx_ejemplar_estado (id_estado)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: prestamo
-- CORREGIDO: id_bibliotecario ahora referencia bibliotecario,
-- no usuario en general (ver nota de corrección al inicio).
-- =========================================================
CREATE TABLE prestamo (
    id_prestamo       INT AUTO_INCREMENT PRIMARY KEY,
    id_ejemplar       INT      NOT NULL,
    id_lector         INT      NOT NULL,
    id_bibliotecario  INT      NOT NULL,
    fecha_prestamo    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_limite      DATETIME NOT NULL,
    fecha_devolucion  DATETIME NULL,
    id_estado         INT      NOT NULL,

    CONSTRAINT fk_prestamo_ejemplar
        FOREIGN KEY (id_ejemplar) REFERENCES ejemplar(id_ejemplar),

    CONSTRAINT fk_prestamo_lector
        FOREIGN KEY (id_lector) REFERENCES lector(id_usuario),

    CONSTRAINT fk_prestamo_bibliotecario
        FOREIGN KEY (id_bibliotecario) REFERENCES bibliotecario(id_usuario),

    CONSTRAINT fk_prestamo_estado
        FOREIGN KEY (id_estado) REFERENCES estado(id_estado),

    INDEX idx_prestamo_estado (id_estado),
    INDEX idx_prestamo_lector (id_lector)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: multa
-- =========================================================
CREATE TABLE multa (
    id_multa         INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo      INT           NOT NULL UNIQUE,
    monto            DECIMAL(6,2)  NOT NULL,
    fecha_generacion DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_estado        INT           NOT NULL,
    fecha_pago       DATETIME      NULL,

    CONSTRAINT fk_multa_prestamo
        FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo),

    CONSTRAINT fk_multa_estado
        FOREIGN KEY (id_estado) REFERENCES estado(id_estado)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: comprobante_prestamo (snapshot)
-- =========================================================
CREATE TABLE comprobante_prestamo (
    id_comprobante       INT AUTO_INCREMENT PRIMARY KEY,
    numero_comprobante   VARCHAR(20)  NOT NULL UNIQUE,
    id_prestamo          INT          NOT NULL UNIQUE,
    nombre_lector        VARCHAR(200) NOT NULL,
    documento_lector     VARCHAR(20)  NOT NULL,
    titulo_libro         VARCHAR(200) NOT NULL,
    codigo_ejemplar      VARCHAR(30)  NOT NULL,
    nombre_bibliotecario VARCHAR(200) NOT NULL,
    fecha_prestamo       DATETIME     NOT NULL,
    fecha_limite         DATETIME     NOT NULL,
    fecha_emision        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_comprobanteprestamo_prestamo
        FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo)
) ENGINE = InnoDB;

-- =========================================================
-- Tabla: comprobante_pago_multa (snapshot)
-- =========================================================
CREATE TABLE comprobante_pago_multa (
    id_comprobante       INT AUTO_INCREMENT PRIMARY KEY,
    numero_comprobante   VARCHAR(20)  NOT NULL UNIQUE,
    id_multa             INT          NOT NULL UNIQUE,
    nombre_lector        VARCHAR(200) NOT NULL,
    documento_lector     VARCHAR(20)  NOT NULL,
    concepto             VARCHAR(255) NOT NULL,
    monto                DECIMAL(6,2) NOT NULL,
    nombre_bibliotecario VARCHAR(200) NOT NULL,
    fecha_pago           DATETIME     NOT NULL,
    fecha_emision        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_comprobantemulta_multa
        FOREIGN KEY (id_multa) REFERENCES multa(id_multa)
) ENGINE = InnoDB;



-- =========================================================
-- Verificación rápida: listar todas las tablas creadas
-- =========================================================
SHOW TABLES;
