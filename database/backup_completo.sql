-- MySQL dump 10.13  Distrib 9.3.0, for Win64 (x86_64)
--
-- Host: localhost    Database: sistemabiblioteca
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `administrador`
--

DROP TABLE IF EXISTS `administrador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `administrador` (
  `id_usuario` int NOT NULL,
  `codigo_administrador` varchar(10) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `codigo_administrador` (`codigo_administrador`),
  CONSTRAINT `fk_administrador_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administrador`
--

LOCK TABLES `administrador` WRITE;
/*!40000 ALTER TABLE `administrador` DISABLE KEYS */;
INSERT INTO `administrador` VALUES (1,'A001');
/*!40000 ALTER TABLE `administrador` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `autor`
--

DROP TABLE IF EXISTS `autor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `autor` (
  `id_autor` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_spanish_ci NOT NULL,
  `apellido` varchar(100) COLLATE utf8mb4_spanish_ci NOT NULL,
  `nacionalidad` varchar(60) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_autor`),
  KEY `idx_autor_apellido` (`apellido`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `autor`
--

LOCK TABLES `autor` WRITE;
/*!40000 ALTER TABLE `autor` DISABLE KEYS */;
INSERT INTO `autor` VALUES (1,'Robert','Martin','Estadounidense'),(2,'Gabriel','García Márquez','Colombiana'),(3,'Isaac','Asimov','Estadounidense'),(4,'Jane','Austen','Británica'),(5,'Mario','Vargas Llosa','Peruana'),(6,'José','Saramago','Portuguesa'),(7,'Isabel','Allende','Chilena'),(8,'Julio','Cortázar','Argentina'),(9,'Haruki','Murakami','Japonesa'),(10,'Laura','Esquivel','Mexicana');
/*!40000 ALTER TABLE `autor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bibliotecario`
--

DROP TABLE IF EXISTS `bibliotecario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bibliotecario` (
  `id_usuario` int NOT NULL,
  `codigo_bibliotecario` varchar(10) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `codigo_bibliotecario` (`codigo_bibliotecario`),
  CONSTRAINT `fk_bibliotecario_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bibliotecario`
--

LOCK TABLES `bibliotecario` WRITE;
/*!40000 ALTER TABLE `bibliotecario` DISABLE KEYS */;
INSERT INTO `bibliotecario` VALUES (2,'B002');
/*!40000 ALTER TABLE `bibliotecario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carrera`
--

DROP TABLE IF EXISTS `carrera`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carrera` (
  `id_carrera` int NOT NULL AUTO_INCREMENT,
  `codigo_carrera` varchar(10) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `nombre_carrera` varchar(100) COLLATE utf8mb4_spanish_ci NOT NULL,
  `id_facultad` int NOT NULL,
  PRIMARY KEY (`id_carrera`),
  UNIQUE KEY `uq_carrera_nombre_facultad` (`nombre_carrera`,`id_facultad`),
  UNIQUE KEY `codigo_carrera` (`codigo_carrera`),
  KEY `fk_carrera_facultad` (`id_facultad`),
  CONSTRAINT `fk_carrera_facultad` FOREIGN KEY (`id_facultad`) REFERENCES `facultad` (`id_facultad`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrera`
--

LOCK TABLES `carrera` WRITE;
/*!40000 ALTER TABLE `carrera` DISABLE KEYS */;
INSERT INTO `carrera` VALUES (1,'C001','Ingeniería Informática',1),(2,'C002','Ingeniería Civil',1),(3,'C003','Contabilidad',2),(4,'C004','Medicina Humana',3),(5,'C005','Derecho',4),(6,'C006','arquitectura',8),(7,'C007','Ingenieria de Sofware',1);
/*!40000 ALTER TABLE `carrera` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `codigo_categoria` varchar(10) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `nombre_categoria` varchar(80) COLLATE utf8mb4_spanish_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre_categoria` (`nombre_categoria`),
  UNIQUE KEY `codigo_categoria` (`codigo_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'CAT001','Ciencias de la Computación','Algoritmos, bases de datos y programación.'),(2,'CAT002','Matemática','Cálculo, álgebra y estadística.'),(3,'CAT003','Novela','Obras de ficción narrativa larga.'),(4,'CAT004','Ciencia Ficción','Narrativa especulativa basada en ciencia y tecnología.'),(5,'CAT005','Historia','Obras sobre hechos y procesos históricos.'),(6,'CAT006','Biografica','Libros que narran la vida de una persona.'),(7,'CAT007','Psicolog├¡a','Obras relacionadas al estudio de la mente y comportamiento humano.'),(8,'CAT008','Filosofia','Textos sobre reflexiones y sistemas de pensamiento.'),(9,'CAT009','comics y Novelas Graficas','Historias contadas a través de ilustraciones secuenciales.'),(10,'CAT010','Economia','Libros sobre sistemas de produccion, distribucion y finanzas.');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comprobante_pago_multa`
--

DROP TABLE IF EXISTS `comprobante_pago_multa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comprobante_pago_multa` (
  `id_comprobante` int NOT NULL AUTO_INCREMENT,
  `numero_comprobante` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `id_multa` int NOT NULL,
  `nombre_lector` varchar(200) COLLATE utf8mb4_spanish_ci NOT NULL,
  `documento_lector` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `concepto` varchar(255) COLLATE utf8mb4_spanish_ci NOT NULL,
  `monto` decimal(6,2) NOT NULL,
  `nombre_bibliotecario` varchar(200) COLLATE utf8mb4_spanish_ci NOT NULL,
  `fecha_pago` datetime NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_comprobante`),
  UNIQUE KEY `numero_comprobante` (`numero_comprobante`),
  UNIQUE KEY `id_multa` (`id_multa`),
  CONSTRAINT `fk_comprobantemulta_multa` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comprobante_pago_multa`
--

LOCK TABLES `comprobante_pago_multa` WRITE;
/*!40000 ALTER TABLE `comprobante_pago_multa` DISABLE KEYS */;
INSERT INTO `comprobante_pago_multa` VALUES (1,'MUL-000001',1,'lucano zurita','74631812','Multa por retraso - Préstamo #3 (Cien Años de Soledad)',2.50,'leandro peña avila','2026-07-14 23:37:10','2026-07-14 23:37:10'),(2,'MUL-000002',2,'lucano zurita','74631812','Multa por retraso - Préstamo #5 (Cien Años de Soledad)',646.50,'leandro peña avila','2026-07-19 14:17:51','2026-07-19 14:17:51');
/*!40000 ALTER TABLE `comprobante_pago_multa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comprobante_prestamo`
--

DROP TABLE IF EXISTS `comprobante_prestamo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comprobante_prestamo` (
  `id_comprobante` int NOT NULL AUTO_INCREMENT,
  `numero_comprobante` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `id_prestamo` int NOT NULL,
  `nombre_lector` varchar(200) COLLATE utf8mb4_spanish_ci NOT NULL,
  `documento_lector` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `titulo_libro` varchar(200) COLLATE utf8mb4_spanish_ci NOT NULL,
  `codigo_ejemplar` varchar(30) COLLATE utf8mb4_spanish_ci NOT NULL,
  `nombre_bibliotecario` varchar(200) COLLATE utf8mb4_spanish_ci NOT NULL,
  `fecha_prestamo` datetime NOT NULL,
  `fecha_limite` datetime NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_comprobante`),
  UNIQUE KEY `numero_comprobante` (`numero_comprobante`),
  UNIQUE KEY `id_prestamo` (`id_prestamo`),
  CONSTRAINT `fk_comprobanteprestamo_prestamo` FOREIGN KEY (`id_prestamo`) REFERENCES `prestamo` (`id_prestamo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comprobante_prestamo`
--

LOCK TABLES `comprobante_prestamo` WRITE;
/*!40000 ALTER TABLE `comprobante_prestamo` DISABLE KEYS */;
INSERT INTO `comprobante_prestamo` VALUES (1,'PRE-000001',1,'jeremy suarez','87654321','Cien Años de Soledad','EJ-001','leandro peña avila','2026-07-13 23:13:23','2026-07-20 23:13:23','2026-07-13 23:13:23'),(2,'PRE-000002',2,'German Avila','67676767','Cien Años de Soledad','EJ-001','leandro peña avila','2026-07-14 23:26:24','2026-07-21 23:26:24','2026-07-14 23:26:24'),(3,'PRE-000004',4,'German Avila','67676767','Clean Code: A Handbook of Agile Software Craftsmanship','EJ-002','leandro peña avila','2026-07-17 16:19:53','2026-07-19 16:19:53','2026-07-17 16:19:53');
/*!40000 ALTER TABLE `comprobante_prestamo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ejemplar`
--

DROP TABLE IF EXISTS `ejemplar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ejemplar` (
  `id_ejemplar` int NOT NULL AUTO_INCREMENT,
  `id_libro` int NOT NULL,
  `codigo_ejemplar` varchar(30) COLLATE utf8mb4_spanish_ci NOT NULL,
  `id_estado` int NOT NULL,
  `ubicacion` varchar(50) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_ejemplar`),
  UNIQUE KEY `codigo_ejemplar` (`codigo_ejemplar`),
  KEY `fk_ejemplar_libro` (`id_libro`),
  KEY `idx_ejemplar_estado` (`id_estado`),
  CONSTRAINT `fk_ejemplar_estado` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`),
  CONSTRAINT `fk_ejemplar_libro` FOREIGN KEY (`id_libro`) REFERENCES `libro` (`id_libro`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ejemplar`
--

LOCK TABLES `ejemplar` WRITE;
/*!40000 ALTER TABLE `ejemplar` DISABLE KEYS */;
INSERT INTO `ejemplar` VALUES (1,2,'EJ-001',5,'Estante A'),(3,1,'EJ-002',6,'Estante B'),(8,13,'OYP-001',5,'Estante B3'),(10,1,'CC-001-A',5,'Estante A1'),(11,1,'CC-002-A',5,'Estante A1'),(12,2,'CAS-001-A',5,'Estante B2'),(13,2,'CAS-002-A',5,'Estante B2'),(14,3,'FUN-001-A',5,'Estante C3'),(15,8,'CLP-001-A',5,'Estante B4'),(16,13,'OYP-001-A',5,'Estante B3'),(17,13,'OYP-002-A',5,'Estante B3'),(18,15,'ESC-001',5,'Estante D1'),(19,16,'CDE-001',5,'Estante D2'),(20,17,'RAY-001',5,'Estante D3'),(21,18,'TOK-001',5,'Estante D4'),(22,19,'CAPC-001',5,'Estante D5');
/*!40000 ALTER TABLE `ejemplar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empresa`
--

DROP TABLE IF EXISTS `empresa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empresa` (
  `id_empresa` int NOT NULL AUTO_INCREMENT,
  `razon_social` varchar(150) COLLATE utf8mb4_spanish_ci NOT NULL,
  `ruc` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `direccion` varchar(200) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `telefono_contacto` varchar(20) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `logo_url` varchar(255) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_empresa`),
  UNIQUE KEY `ruc` (`ruc`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empresa`
--

LOCK TABLES `empresa` WRITE;
/*!40000 ALTER TABLE `empresa` DISABLE KEYS */;
INSERT INTO `empresa` VALUES (1,'Universidad Nacional de Piura','20100000000','Campus Universitario, Piura','074-000000','');
/*!40000 ALTER TABLE `empresa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado`
--

DROP TABLE IF EXISTS `estado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estado` (
  `id_estado` int NOT NULL AUTO_INCREMENT,
  `entidad` varchar(30) COLLATE utf8mb4_spanish_ci NOT NULL,
  `codigo` varchar(30) COLLATE utf8mb4_spanish_ci NOT NULL,
  `descripcion` varchar(100) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id_estado`),
  UNIQUE KEY `uq_estado_entidad_codigo` (`entidad`,`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado`
--

LOCK TABLES `estado` WRITE;
/*!40000 ALTER TABLE `estado` DISABLE KEYS */;
INSERT INTO `estado` VALUES (1,'usuario','activo','Usuario habilitado para operar en el sistema'),(2,'usuario','inactivo','Usuario deshabilitado (baja lógica)'),(3,'libro','activo','Título disponible en el catálogo'),(4,'libro','baja','Título retirado del catálogo (baja lógica)'),(5,'ejemplar','disponible','Ejemplar listo para préstamo'),(6,'ejemplar','prestado','Ejemplar actualmente prestado'),(7,'ejemplar','dañado','Ejemplar dañado, no prestable'),(8,'ejemplar','baja','Ejemplar retirado definitivamente'),(9,'prestamo','activo','Préstamo vigente, no devuelto'),(10,'prestamo','devuelto','Préstamo devuelto dentro o fuera de fecha'),(11,'prestamo','vencido','Préstamo no devuelto y fuera de fecha límite'),(12,'multa','pendiente','Multa generada, aún no pagada'),(13,'multa','pagada','Multa pagada por el lector');
/*!40000 ALTER TABLE `estado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facultad`
--

DROP TABLE IF EXISTS `facultad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facultad` (
  `id_facultad` int NOT NULL AUTO_INCREMENT,
  `codigo_facultad` varchar(10) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `nombre_facultad` varchar(100) COLLATE utf8mb4_spanish_ci NOT NULL,
  PRIMARY KEY (`id_facultad`),
  UNIQUE KEY `nombre_facultad` (`nombre_facultad`),
  UNIQUE KEY `codigo_facultad` (`codigo_facultad`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facultad`
--

LOCK TABLES `facultad` WRITE;
/*!40000 ALTER TABLE `facultad` DISABLE KEYS */;
INSERT INTO `facultad` VALUES (1,'F001','Facultad de Ingeniería'),(2,'F002','Facultad de Ciencias Económicas'),(3,'F003','Facultad de Ciencias de la Salud'),(4,'F004','Facultad de Derecho y Ciencias Políticas'),(5,'F005','Facultad de Humanidades'),(8,'F008','Facultad de Arquitectura'),(9,'F009','facuPrueba');
/*!40000 ALTER TABLE `facultad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lector`
--

DROP TABLE IF EXISTS `lector`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lector` (
  `id_usuario` int NOT NULL,
  `codigo_universitario` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `id_carrera` int DEFAULT NULL,
  `tipo_lector` enum('estudiante','docente','personal_administrativo','externo') COLLATE utf8mb4_spanish_ci NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `codigo_universitario` (`codigo_universitario`),
  KEY `fk_lector_carrera` (`id_carrera`),
  CONSTRAINT `fk_lector_carrera` FOREIGN KEY (`id_carrera`) REFERENCES `carrera` (`id_carrera`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_lector_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lector`
--

LOCK TABLES `lector` WRITE;
/*!40000 ALTER TABLE `lector` DISABLE KEYS */;
INSERT INTO `lector` VALUES (3,'',NULL,'docente'),(5,'D001',NULL,'docente'),(6,'U001',1,'estudiante'),(7,'U002',4,'estudiante'),(9,'67676767',NULL,'externo');
/*!40000 ALTER TABLE `lector` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libro`
--

DROP TABLE IF EXISTS `libro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `libro` (
  `id_libro` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) COLLATE utf8mb4_spanish_ci NOT NULL,
  `isbn` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `id_categoria` int NOT NULL,
  `anio_publicacion` year DEFAULT NULL,
  `editorial` varchar(100) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `id_estado` int NOT NULL,
  PRIMARY KEY (`id_libro`),
  UNIQUE KEY `isbn` (`isbn`),
  KEY `fk_libro_categoria` (`id_categoria`),
  KEY `fk_libro_estado` (`id_estado`),
  KEY `idx_libro_titulo` (`titulo`),
  CONSTRAINT `fk_libro_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_libro_estado` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libro`
--

LOCK TABLES `libro` WRITE;
/*!40000 ALTER TABLE `libro` DISABLE KEYS */;
INSERT INTO `libro` VALUES (1,'Clean Code: A Handbook of Agile Software Craftsmanship','978-0132350884',1,2008,'Prentice Hall',3),(2,'Cien Años de Soledad','978-0307474728',3,1967,'Editorial Sudamericana',3),(3,'Fundación','978-8497599248',4,1951,'Gnome Press',3),(8,'La ciudad y los perros','978-6124262708',3,1963,'persas',3),(9,'libro puerab','33',4,2026,'myslam',4),(13,'Orgullo y prejuicio','9788491050513',3,0000,'T. Egerton',3),(15,'Ensayo sobre la ceguera','9788420442650',3,1995,'Alfaguara',3),(16,'La casa de los espíritus','9788401345914',3,1982,'Plaza & Janés',3),(17,'Rayuela','9788420442667',3,1963,'Sudamericana',3),(18,'Tokio blues','9788483835031',3,1987,'Tusquets',3),(19,'Como agua para chocolate','9788433973950',3,1989,'Anagrama',3);
/*!40000 ALTER TABLE `libro` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `libro_autor`
--

DROP TABLE IF EXISTS `libro_autor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `libro_autor` (
  `id_libro` int NOT NULL,
  `id_autor` int NOT NULL,
  PRIMARY KEY (`id_libro`,`id_autor`),
  KEY `fk_libroautor_autor` (`id_autor`),
  CONSTRAINT `fk_libroautor_autor` FOREIGN KEY (`id_autor`) REFERENCES `autor` (`id_autor`) ON DELETE CASCADE,
  CONSTRAINT `fk_libroautor_libro` FOREIGN KEY (`id_libro`) REFERENCES `libro` (`id_libro`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `libro_autor`
--

LOCK TABLES `libro_autor` WRITE;
/*!40000 ALTER TABLE `libro_autor` DISABLE KEYS */;
INSERT INTO `libro_autor` VALUES (1,1),(2,2),(9,2),(3,3),(13,4),(8,5),(15,6),(16,7),(17,8),(18,9),(19,10);
/*!40000 ALTER TABLE `libro_autor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `multa`
--

DROP TABLE IF EXISTS `multa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `multa` (
  `id_multa` int NOT NULL AUTO_INCREMENT,
  `id_prestamo` int NOT NULL,
  `monto` decimal(6,2) NOT NULL,
  `fecha_generacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_estado` int NOT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  PRIMARY KEY (`id_multa`),
  UNIQUE KEY `id_prestamo` (`id_prestamo`),
  KEY `fk_multa_estado` (`id_estado`),
  CONSTRAINT `fk_multa_estado` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`),
  CONSTRAINT `fk_multa_prestamo` FOREIGN KEY (`id_prestamo`) REFERENCES `prestamo` (`id_prestamo`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `multa`
--

LOCK TABLES `multa` WRITE;
/*!40000 ALTER TABLE `multa` DISABLE KEYS */;
INSERT INTO `multa` VALUES (1,3,2.50,'2026-07-14 23:35:51',13,'2026-07-14 23:37:10'),(2,5,646.50,'2026-07-19 14:17:19',13,'2026-07-19 14:17:51');
/*!40000 ALTER TABLE `multa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parametro_sistema`
--

DROP TABLE IF EXISTS `parametro_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parametro_sistema` (
  `id_parametro` int NOT NULL AUTO_INCREMENT,
  `nombre_parametro` varchar(60) COLLATE utf8mb4_spanish_ci NOT NULL,
  `valor` varchar(30) COLLATE utf8mb4_spanish_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `id_administrador` int NOT NULL,
  `fecha_modificacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_parametro`),
  UNIQUE KEY `nombre_parametro` (`nombre_parametro`),
  KEY `fk_parametro_administrador` (`id_administrador`),
  CONSTRAINT `fk_parametro_administrador` FOREIGN KEY (`id_administrador`) REFERENCES `administrador` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parametro_sistema`
--

LOCK TABLES `parametro_sistema` WRITE;
/*!40000 ALTER TABLE `parametro_sistema` DISABLE KEYS */;
INSERT INTO `parametro_sistema` VALUES (1,'dias_prestamo_default','2','Días de plazo por defecto para cualquier préstamo.',1,'2026-07-17 16:19:20'),(2,'monto_multa_por_dia','0.50','Monto en soles por cada día de retraso.',1,'2026-07-13 22:13:54'),(3,'max_prestamos_por_lector','3','Cantidad máxima de préstamos activos simultáneos permitidos por lector.',1,'2026-07-13 22:20:41');
/*!40000 ALTER TABLE `parametro_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prestamo`
--

DROP TABLE IF EXISTS `prestamo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prestamo` (
  `id_prestamo` int NOT NULL AUTO_INCREMENT,
  `id_ejemplar` int NOT NULL,
  `id_lector` int NOT NULL,
  `id_bibliotecario` int NOT NULL,
  `fecha_prestamo` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_limite` datetime NOT NULL,
  `fecha_devolucion` datetime DEFAULT NULL,
  `id_estado` int NOT NULL,
  PRIMARY KEY (`id_prestamo`),
  KEY `fk_prestamo_ejemplar` (`id_ejemplar`),
  KEY `fk_prestamo_bibliotecario` (`id_bibliotecario`),
  KEY `idx_prestamo_estado` (`id_estado`),
  KEY `idx_prestamo_lector` (`id_lector`),
  CONSTRAINT `fk_prestamo_bibliotecario` FOREIGN KEY (`id_bibliotecario`) REFERENCES `bibliotecario` (`id_usuario`),
  CONSTRAINT `fk_prestamo_ejemplar` FOREIGN KEY (`id_ejemplar`) REFERENCES `ejemplar` (`id_ejemplar`),
  CONSTRAINT `fk_prestamo_estado` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`),
  CONSTRAINT `fk_prestamo_lector` FOREIGN KEY (`id_lector`) REFERENCES `lector` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prestamo`
--

LOCK TABLES `prestamo` WRITE;
/*!40000 ALTER TABLE `prestamo` DISABLE KEYS */;
INSERT INTO `prestamo` VALUES (1,1,5,2,'2026-07-13 23:13:23','2026-07-20 23:13:23','2026-07-13 23:13:52',10),(2,1,9,2,'2026-07-14 23:26:24','2026-07-21 23:26:24','2026-07-14 23:26:50',10),(3,1,3,2,'2026-07-02 23:34:42','2026-07-09 23:34:42','2026-07-14 23:35:51',10),(4,3,9,2,'2026-07-17 16:19:53','2026-07-19 16:19:53',NULL,9),(5,1,3,2,'2023-01-01 10:00:00','2023-01-03 10:00:00','2026-07-19 14:17:19',10);
/*!40000 ALTER TABLE `prestamo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_spanish_ci NOT NULL,
  `apellido` varchar(100) COLLATE utf8mb4_spanish_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_spanish_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_spanish_ci NOT NULL,
  `rol` enum('lector','bibliotecario','administrador') COLLATE utf8mb4_spanish_ci NOT NULL,
  `documento_identidad` varchar(20) COLLATE utf8mb4_spanish_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_spanish_ci DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_estado` int NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `documento_identidad` (`documento_identidad`),
  KEY `fk_usuario_estado` (`id_estado`),
  KEY `idx_usuario_rol` (`rol`),
  CONSTRAINT `fk_usuario_estado` FOREIGN KEY (`id_estado`) REFERENCES `estado` (`id_estado`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'Carlos','Mendoza','admin@unp.edu.pe','$2a$10$IQvBwYNwMdDkM9Czcu4cC.GUS80B2sGwSk3e.3SoDYWqRTzgdyap6','administrador','60216266','987654321','2026-07-07 00:01:45',1),(2,'leandro','peña avila','rafa@unp.edu.pe','$2a$12$1UdETEBlwS2/YDh/OzpVC.gClLJjl/htA7Ee7EX527mUsXikupv62','bibliotecario','12345678','987654321','2026-07-07 00:30:26',1),(3,'lucano','zurita','luca@unp.edu.pe','$2a$12$JuSvuNC29keqnW5YLz0.O.LrMH7Z04LiRS8Tg4ig0UXsD5CuaYOgu','lector','74631812','999391983','2026-07-07 00:36:01',1),(5,'jeremy','suarez','jeremy@unp.edu.pe','$2a$12$49vXkHPebJgxUnldYFb3qOn0ftUiF9zCDxtmr7sbcqfOHWPr/bZ9a','lector','87654321','999888777','2026-07-07 00:38:21',1),(6,'sebastian','salazar','sebas@unp.edu.pe','$2a$12$.paOk0QHMXpLwua/vSP3Ku4D14SBUtPRKMf10R.IvVVvlAyEl.WAW','lector','12343223','987999777','2026-07-07 00:49:37',1),(7,'pedro','mendoza martinez','pedro@unp.edu.pe','$2a$12$4HYXBfgHt9o4hh4h2TMLAO5mQ28X3KK4h8XXJhK/HXKO2qZHss90G','lector','60246099','931567300','2026-07-07 18:12:51',1),(9,'German','Avila','german@unp.edu.pe','$2a$12$eEA8/.qpH5flcSz3.MCbu.OaNPz55iK.ByIYqMxs9IJJecb7cDddy','lector','67676767','902770133','2026-07-14 23:02:17',1);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'sistemabiblioteca'
--

--
-- Dumping routines for database 'sistemabiblioteca'
--
