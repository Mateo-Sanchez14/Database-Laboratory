-- Año: 2024
-- Grupo Nro:06
-- Integrantes: Grellet Martinoia, Alejandro // Sanchez Mateo 
-- Tema: AGROSA
-- Nombre del Esquema (LBD02024G06AGROSA)
-- Plataforma Windows 10 // Docker Buildx (Docker Inc., v0.9.1) :
-- Motor y Versión: MySQL SServer 8.0.36
-- GitHub Repositorio: LBD2024G06
-- GitHub Usuario: AlejandroGrellet // Mateo-Sanchez14
DROP SCHEMA IF EXISTS `LBD2024G06AGROSA`;

CREATE SCHEMA IF NOT EXISTS `LBD2024G06AGROSA` DEFAULT CHARACTER SET utf8;

USE `LBD2024G06AGROSA`;

CREATE TABLE IF NOT EXISTS `USUARIOS` (
  `idUSUARIO` INT(11) NOT NULL AUTO_INCREMENT,
  `usuario` VARCHAR(30) NOT NULL,
  `password` VARCHAR(30) NOT NULL,
  `tipoUsuario` ENUM('Administrador', 'Secretario') DEFAULT 'Secretario' NOT NULL,
  `estado` CHAR(1) NOT NULL DEFAULT 'A',
  PRIMARY KEY (`idUSUARIOS`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `RUBROS` (
  `idRUBRO` INT(11) NOT NULL AUTO_INCREMENT,
  `rubro` VARCHAR(45) NOT NULL,
  `tipoRubro` ENUM('Egreso', 'Ingreso') NOT NULL,
  `estado` CHAR(1) NOT NULL,
  PRIMARY KEY (`idRUBROS`),
  CONSTRAINT Check_Estado_Rubros CHECK (`estado` = 'A' OR `estado`= 'B') ) -- A = ACtivo, B = Baja
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `MOVIMIENTOS` (
  `idRUBRO` INT(11) NOT NULL,
  `idMOVIMIENTO` INT(11) NOT NULL AUTO_INCREMENT,
  `tipoMovimiento` CHAR(1) NOT NULL,
  `fecha` DATE NOT NULL,
  `monto` DECIMAL NOT NULL,
  `detalle` VARCHAR(80) NULL DEFAULT NULL,
  `estado` CHAR(1) NOT NULL DEFAULT 'I',
  PRIMARY KEY (`idMOVIMIENTOS`, `idRUBROS`),
  INDEX `FECHA_MOVIMIENTOS` (`fecha` ASC) VISIBLE,
  INDEX `fk_MOVIMIENTOS_RUBROS_idx` (`idRUBROS` ASC) VISIBLE,
  CONSTRAINT Check_Montos CHECK (`tipoMovimiento`= 'E' AND `monto` <=0 OR `tipoMovimiento`= 'I' AND `monto` >=0 ),
  CONSTRAINT Check_Estado_Movs CHECK (`estado` = 'P' OR `estado`= 'C'), -- P = Pendiente, C = Cargado
  CONSTRAINT `fk_MOVIMIENTOS_RUBROS`
    FOREIGN KEY (`idRUBRO`)
    REFERENCES `RUBROS` (`idRUBRO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
  
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `EMPLEADOS` (
  `idEMPLEADO` INT(11) NOT NULL AUTO_INCREMENT,
  `cuil` BIGINT(11) UNSIGNED NOT NULL,
  `nombres` VARCHAR(30) NOT NULL,
  `apellidos` VARCHAR(30) NOT NULL,
  `estado` CHAR(1) NOT NULL DEFAULT 'A',
  CONSTRAINT Empleados_CUIL_Len CHECK (CHAR_LENGTH(CAST(`cuil` AS CHAR)) = 11),
  CONSTRAINT Check_Estado_Empleados CHECK (`estado` = 'A' OR `estado`= 'B'), -- A = ACtivo, B = Baja
  PRIMARY KEY (`idEMPLEADO`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- Added table PROPIETARIOS

CREATE TABLE IF NOT EXISTS `PROPIETARIOS` (
  `cuil` BIGINT(11) UNSIGNED NOT NULL,
  `cuil` BIGINT(11) UNSIGNED NOT NULL,
  `nombres` VARCHAR(30) NOT NULL,
  `apellidos` VARCHAR(30) NOT NULL,
  `estado` CHAR(1) NOT NULL DEFAULT 'A',
  CONSTRAINT Propietarios_CUIL_Len CHECK (CHAR_LENGTH(CAST(`cuil` AS CHAR)) = 11),
  CONSTRAINT Check_Estado_Propietarios CHECK (`estado` = 'A' OR `estado`= 'B'), -- A = ACtivo, B = Baja
  PRIMARY KEY (`cuil`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- Updated table FINCAS

CREATE TABLE IF NOT EXISTS `FINCAS` (
  `idFINCA` INT(11) NOT NULL AUTO_INCREMENT,
  `cuilPROPIETARIO` BIGINT(11) UNSIGNED NOT NULL,
  `nombreFinca` VARCHAR(45) NOT NULL,
  `latitud` FLOAT(11) NULL DEFAULT NULL,
  `longitud` FLOAT(11) NULL DEFAULT NULL,
  CONSTRAINT `fk_PROPIETARIOS`
    FOREIGN KEY (`cuilPROPIETARIO`)
    REFERENCES `LBD2024G06AGROSA`.`PROPIETARIOS` (`cuil`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  PRIMARY KEY (`idFINCA`),
  UNIQUE INDEX `ubicacion_UNIQUE` (`latitud`, `longitud` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- Updated table PARTES 

CREATE TABLE IF NOT EXISTS `PARTES` (
  `idPARTE` INT(11) NOT NULL AUTO_INCREMENT,
  `idENCARGADO` INT(11) NOT NULL,
  `idFINCA` INT(11) NOT NULL,
  `fechaParte` DATE NOT NULL,
  `estado` CHAR(1) NOT NULL DEFAULT 'P',
  `superficie` FLOAT(11) NOT NULL,
  PRIMARY KEY (`idPARTE`),
  INDEX `FECHA_PARTES` (`fechaParte` ASC) VISIBLE,
  INDEX `idENCARGADO` (`idENCARGADO` ASC) VISIBLE,
  INDEX `idFINCA` (`idFINCA` ASC) VISIBLE,
  CONSTRAINT Check_Estado_Partes CHECK (`estado` = 'P' OR `estado`= 'C'), -- P = Pendiente, C = Cargado
  CONSTRAINT `fk_PARTES_EMPLEADOS1`
    FOREIGN KEY (`idENCARGADO`)
    REFERENCES `EMPLEADOS` (`idEMPLEADO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_PARTES_FINCAS1`
    FOREIGN KEY (`idFINCA`)
    REFERENCES `FINCAS` (`idFINCA`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `LINEAS_PARTES` (
  `idPARTE` INT(11) NOT NULL,
  `idEMPLEADO` INT(11) NOT NULL,
  `rol` CHAR(1) NULL DEFAULT NULL,
  PRIMARY KEY (`idPARTE`, `idEMPLEADO`),
  INDEX `fk_PARTES_has_EMPLEADOS_EMPLEADOS1_idx` (`idEMPLEADO` ASC) VISIBLE,
  INDEX `fk_PARTES_has_EMPLEADOS_PARTES1_idx` (`idPARTE` ASC) VISIBLE,
  CONSTRAINT `fk_PARTES_has_EMPLEADOS_PARTES1`
    FOREIGN KEY (`idPARTE`)
    REFERENCES `PARTES` (`idPARTE`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_PARTES_has_EMPLEADOS_EMPLEADOS1`
    FOREIGN KEY (`idEMPLEADO`)
    REFERENCES `EMPLEADOS` (`idEMPLEADO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

-- Update with new Tables 

CREATE TABLE IF NOT EXISTS `VEHICULOS` (
  `idVEHICULO` INT(11) NOT NULL,
  `patente` VARCHAR(11) NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `modelo` VARCHAR(45) NOT NULL,
  `funcion` VARCHAR(45) NULL DEFAULT NULL,
  CONSTRAINT `Patente_Check` CHECK (
    `patente` REGEXP '^[A-Z]{3} [0-9]{3}$' OR 
    `patente` REGEXP '^[A-Z]{2} [0-9]{3} [A-Z]{2}$'
  ),
  PRIMARY KEY (`idVEHICULO`, `patente`),
  INDEX `idx_patente` (`patente`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `VEHICULOS_POR_PARTES` (
  `idVEHICULO` INT(11) NOT NULL,
  `patente` VARCHAR (11) NOT NULL,
  `idPARTE` INT(11) NOT NULL,
  PRIMARY KEY (`idVEHICULO`, `patente`, `idPARTE`),
  CONSTRAINT `fk_VEHICULOS_POR_PARTES1`
    FOREIGN KEY (`idVEHICULO`)
    REFERENCES `VEHICULOS` (`idVEHICULO`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_VEHICULOS_POR_PARTES2`
    FOREIGN KEY (`patente`)
    REFERENCES `VEHICULOS` (`patente`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_VEHICULOS_POR_PARTES3`
    FOREIGN KEY (`idPARTE`)
    REFERENCES `PARTES` (`idPARTE`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- Populate all the Tables with at least 20 rows each


START TRANSACTION ;
-- Populate the table USUARIOS
-- Insert sample data into the USUARIOS table
INSERT INTO `USUARIOS` (`usuario`, `password`, `tipoUsuario`, `estado`)
VALUES ('JohnDoe', 'password1', 'Administrador', 1),
       ('JaneDoe', 'password2', 'Secretario', 1),
       ('AliceSmith', 'password3', 'Secretario', 0),
       ('BobJohnson', 'password4', 'Administrador', 1),
       ('EmilyBrown', 'password5', 'Secretario', 1);

-- Populate the table RUBROS

INSERT INTO `RUBROS` (`rubro`, `tipoRubro`, `estado`)
VALUES ('Venta', 'Ingreso', 'A'),
       ('Empleados', 'Egreso', 'A'),
       ('Insumos', 'Egreso', 'A'),
       ('Maquinaria', 'Egreso', 'A'),
       ('Impuestos', 'Egreso', 'A'),
       ('Servicios', 'Ingreso', 'A'),
       ('Arriendo', 'Egreso', 'A');
       

-- Populate the table MOVIMIENTOS
INSERT INTO `MOVIMIENTOS` (`idMOVIMIENTOS`, `tipoMovimiento`, `fecha`, `monto`, `detalle`, `estado`,
                                              `idRUBROS`)
VALUES (1, 'I', '2024-01-01', 1000, 'Venta de Trigo', 'P', 1),
       (2, 'E', '2024-01-01', -500, 'Pago de Sueldos', 'P', 2),
       (3, 'E', '2024-01-01', -200, 'Compra de Semillas', 'P', 3),
       (4, 'E', '2024-01-01', -300, 'Compra de Fertilizantes', 'P', 3),
       (5, 'E', '2024-01-01', -400, 'Compra de Herbicidas', 'P', 3),
       (6, 'E', '2024-01-01', -500, 'Compra de Maquinaria', 'P', 4),
       (7, 'E', '2024-01-01', -600, 'Pago de Impuestos', 'P', 5),
       (8, 'I', '2024-01-01', 700, 'Venta de Servicios', 'C', 6),
       (9, 'E', '2024-01-01', -800, 'Pago de Arriendo', 'C', 7),
       (10, 'I', '2024-01-01', 900, 'Venta de Trigo', 'C', 1),
       (11, 'E', '2024-01-01', -1000, 'Pago de Sueldos', 'C', 2),
       (12, 'E', '2024-01-01', -1100, 'Compra de Semillas', 'P', 3),
       (13, 'E', '2024-01-01', -1200, 'Compra de Fertilizantes', 'P', 3),
       (14, 'E', '2024-01-01', -1300, 'Compra de Herbicidas', 'P', 3),
       (15, 'E', '2024-01-01', -1400, 'Compra de Maquinaria', 'P', 4),
       (16, 'E', '2024-01-01', -1500, 'Pago de Impuestos', 'P', 5),
       (17, 'I', '2024-01-01', 1600, 'Venta de Servicios', 'P', 6),
       (18, 'E', '2024-01-01', -1700, 'Pago de Arriendo', 'P', 7),
       (19, 'I', '2024-01-01', 1800, 'Venta de Trigo', 'P', 1),
       (20, 'E', '2024-01-01', -1900, 'Pago de Sueldos', 'C', 2);

-- Populate the table EMPLEADOS
INSERT INTO `EMPLEADOS` (`idEMPLEADO`, `cuil`, `nombres`, `apellidos`, `estado`)
VALUES (1, 12345678912, 'Juan', 'Perez', 'A'),
       (2, 98765432113, 'Maria', 'Gomez', 'A'),
       (3, 45678912314, 'Pedro', 'Rodriguez', 'A'),
       (4, 32165498715, 'Ana', 'Martinez', 'A'),
       (5, 65498732116, 'Carlos', 'Lopez', 'A'),
       (6, 78912345617, 'Laura', 'Garcia', 'A'),
       (7, 65432198718, 'Diego', 'Fernandez', 'A'),
       (8, 32198765419, 'Silvia', 'Alvarez', 'A'),
       (9, 98732165410, 'Jorge', 'Diaz', 'A'),
       (10, 45612378921, 'Marta', 'Benitez', 'A'),
       (11, 78965432122, 'Ricardo', 'Sosa', 'A'),
       (12, 65478932120, 'Florencia', 'Torres', 'A'),
       (13, 32178965423, 'Roberto', 'Paz', 'A'),
       (14, 98712365424, 'Cecilia', 'Vera', 'A'),
       (15, 45632178925, 'Esteban', 'Rios', 'A'),
       (16, 78965412326, 'Carolina', 'Mendez', 'A'),
       (17, 65412378927, 'Federico', 'Luna', 'A'),
       (18, 32165478928, 'Gabriela', 'Aguirre', 'A'),
       (19, 98765412329, 'Ezequiel', 'Gimenez', 'A'),
       (20, 45698732130, 'Valeria', 'Peralta', 'A'),
       (21, 11223344556, 'Sofia', 'Hernandez', 'A'),
	   (22, 66778899001, 'Lucas', 'Santos', 'A'),
       (23, 33445566778, 'Andrea', 'Castillo', 'A'), 
       (24, 88990011223, 'Marcos', 'Reyes', 'A'),
       (25, 22334455667, 'Elena', 'Ortiz', 'A'),
       (26, 55667788990, 'Alberto', 'Pardo', 'A'),
       (27, 99887766554, 'Gisela', 'Morales', 'A'),
       (28, 44332211001, 'Ivan', 'Navarro', 'A'),
       (29, 11235813213, 'Martina', 'Campos', 'A'),
       (30, 31415926535, 'Adrian', 'Rivera', 'A');

-- Populate the table PROPIETARIOS
INSERT INTO `PROPIETARIOS` (`cuil`, `nombres`, `apellidos`)
VALUES (27123456789, 'Liliana', 'Gomez'),
       (27234567891, 'Norma', 'Garcia'),
       (20123456789, 'Ricardo José', 'Suarez'),
       (27345678912, 'Marta', 'Ruiz'),
       (27456789123, 'Lucía', 'Benitez'),
       (20234567892, 'Pedro', 'Suarez'),
       (27567891234, 'Mónica', 'Ramirez'),
       (20345678912, 'Carlos', 'Sanchez'),
       (20456789123, 'Oscar', 'Gomez'),
       (20567891234, 'José', 'Martinez'),
       (20678912345, 'Víctor Manuel', 'Ramirez'),
       (20789123456, 'Miguel', 'Ruiz Torres'),
       (20891234567, 'Carlos', 'Medina Paz'),
       (27678912345, 'Silvia', 'Torres'),
       (20357159123, 'Ramón', 'Lopez Rios Vega'),
       (27789123456, 'Natalia', 'Mendez'),
       (20159357456, 'Víctor', 'Luna'),
       (20753951789, 'Roberto', 'Sanchez Aguirre'),
       (20951753123, 'Ezequiel', 'Peralta'),
       (27891234567, 'Valeria', 'Gimenez');

-- Populate the table FINCAS
INSERT INTO `FINCAS` (`idFINCA`, `nombreFinca`, `latitud`, `longitud`, `cuilPROPIETARIO`)
VALUES (1, 'La Estancia', -34.23722, -51.281592, 27891234567),
       (2, 'El Descanso', -34.6321722, -18.381592, 20951753123),
       (3, 'La Esperanza', -33.603722, -28.381592, 20753951789),
       (4, 'La Fortuna', -34.60312, -38.381592, 20159357456),
       (5, 'La Victoria', -34.63722, -58.381392, 27789123456),
       (6, 'La Paz', -34.223722, -52.381392, 20357159123),
       (7, 'La Libertad', -34.6413722, -12.381392, 27678912345),
       (8, 'La Felicidad', -34.601722, -15.181392, 20891234567),
       (9, 'La Unión', -34.923722, -15.381392, 20789123456),
       (10, 'La Perseverancia', -34.231722, -15.681392, 20678912345),
       (11, 'La Justicia', -34.333722, -15.671392, 20567891234),
       (12, 'La Gloria', -34.60643722, -15.676392, 20456789123),
       (13, 'La Dicha', -34.606422, -15.676792, 20345678912),
       (14, 'La Prosperidad', -34.1233722, -15.676772, 27567891234),
       (15, 'La Alegría', -34.6643722, -15.6123772, 20234567892),
       (16, 'La Fe', -34.6023422, -15.613772, 27456789123),
       (17, 'La Tranquilidad', -34.623421, -16.613772, 27345678912),
       (18, 'La Armonía', -34.62131, -17.613772, 20123456789),
       (19, 'La Solidaridad', -24.603722, -18.613772, 27234567891),
       (20, 'La Caridad', -33.123722, -19.613772, 27123456789);

-- Populate the table PARTES
INSERT INTO `PARTES` (`idPARTE`, `fechaParte`, `estado`, `superficie`, `idENCARGADO`, `idFINCA`)
VALUES 
    (1, '2024-05-13', 'C', 100, 10, 1),
    (2, '2024-06-25', 'P', 200, 12, 4),
    (3, '2024-07-11', 'C', 300, 30, 9),
    (4, '2024-08-17', 'P', 400, 5, 15),
    (5, '2024-09-22', 'C', 500, 12, 3),
    (6, '2024-10-16', 'P', 600, 16, 18),
    (7, '2024-11-14', 'C', 700, 1, 6),
    (8, '2024-12-22', 'P', 800, 4, 5),
    (9, '2025-01-21', 'C', 900, 27, 2),
    (10, '2025-02-14', 'P', 1000, 3, 15),
    (11, '2025-03-29', 'C', 1100, 21, 11),
    (12, '2025-04-01', 'P', 1200, 1, 8),
    (13, '2025-05-08', 'C', 1300, 3, 3),
    (14, '2025-06-18', 'P', 1400, 2, 17),
    (15, '2025-07-07', 'C', 1500, 9, 10),
    (16, '2025-08-08', 'P', 1600, 7, 16),
    (17, '2025-09-15', 'C', 1700, 6, 13),
    (18, '2025-10-23', 'P', 1800, 6, 18),
    (19, '2025-11-26', 'C', 1900, 1, 19),
    (20, '2025-12-27', 'P', 2000, 25, 15),
    (21, '2024-05-15', 'C', 2100, 8, 11), 
    (22, '2024-06-27', 'P', 2200, 27, 15),
    (23, '2024-07-13', 'C', 2300, 13, 2),
    (24, '2024-08-19', 'P', 2400, 4, 3),
    (25, '2024-09-24', 'C', 2500, 4, 17),
    (26, '2024-10-18', 'P', 2600, 11, 6),
    (27, '2024-11-16', 'C', 2700, 5, 18),
    (28, '2024-12-24', 'P', 2800, 29, 4),
    (29, '2025-01-23', 'C', 2900, 28, 9),
    (30, '2025-02-16', 'P', 3000, 22, 7);

-- Populate the table LINEAS_PARTES
INSERT INTO `LINEAS_PARTES` (`idPARTE`, `idEMPLEADO`, `rol`)
VALUES 	(1, 15, 'E'),
		(1, 24, 'O'),
        (1, 8, 'O'),
        (1, 5, 'O'),
        (1, 25, 'O'),
        
        (2, 9, 'E'), 
        (2, 7, 'O'), 
        (2, 8, 'O'), 
        (2, 1, 'O'), 
        (2, 13, 'O'),
        
        (3, 15, 'E'), 
        (3, 4, 'O'), 
        (3, 7, 'O'),
        
        (4, 6, 'E'), 
        (4, 17, 'O'), 
        (4, 3, 'O'), 
        (4, 10, 'O'), 
        (4, 20, 'O'),
        
        (5, 13, 'E'), 
        (5, 25, 'O'), 
        (5, 16, 'O'), 
        (5, 4, 'O'), 
        (5, 15, 'O'),
        
        (6, 17, 'E'), 
        (6, 7, 'O'), 
        (6, 18, 'O'), 
        (6, 29, 'O'), 
        (6, 10, 'O'),
        
        (7, 2, 'E'), 
        (7, 17, 'O'), 
        (7, 3, 'O'), 
        (7, 5, 'O'), 
        (7, 7, 'O'),
        
        (8, 5, 'E'), 
        (8, 6, 'O'), 
        (8, 11, 'O'), 
        (8, 20, 'O'),
        
        (9, 28, 'E'), 
        (9, 3, 'O'), 
        (9, 14, 'O'), 
        (9, 27, 'O'), 
        
        (10, 4, 'E'), 
        (10, 9, 'O'), 
        (10, 21, 'O'),
        
        (11, 22, 'E'), 
        (11, 29, 'O'), 
        (11, 26, 'O'), 
        (11, 23, 'O'), 
        (11, 15, 'O'),
        
        (12, 2, 'E'), 
        (12, 21, 'O'), 
        (12, 20, 'O'),
        
        (13, 4, 'E'), 
        (13, 12, 'O'), 
        (13, 24, 'O'), 
        (13, 26, 'O'), 
        (13, 6, 'O'),
        
        (14, 3, 'E'), 
        (14, 10, 'O'),
        
        (15, 10, 'E'), 
        (15, 2, 'O'), 
        (15, 8, 'O'), 
        (15, 4, 'O'), 
        (15, 15, 'O'),
        
        (16, 8, 'E'), 
        (16, 9, 'O'), 
        (16, 19, 'O'), 
        (16, 20, 'O'),
        
        (17, 7, 'E'), 
        (17, 22, 'O'), 
        (17, 5, 'O'),
        
        (18, 8, 'E'), 
        (18, 30, 'O'), 
        (18, 9, 'O'), 
        (18, 20, 'O'), 
        (18, 11, 'O'),
        
        (19, 2, 'E'), 
        (19, 30, 'O'), 
        (19, 16, 'O'), 
        (19, 25, 'O'), 
        (19, 26, 'O'),
        
        (20, 26, 'E'), 
        (20, 7, 'O'), 
        (20, 21, 'O'),
        
        (21, 9, 'E'), 
		(21, 22, 'O'),
        
        (22, 27, 'E'), 
        (22, 30, 'O'),
        
        (23, 14, 'E'), 
        (23, 28, 'O'), 
        (23, 25, 'O'),
        
        (24, 5, 'E'), 
        (24, 7, 'O'), 
        (24, 28, 'O'), 
        (24, 29, 'O'), 
        
        (24, 6, 'O'),
        (25, 30, 'E'), 
        (25, 12, 'O'), 
        (25, 15, 'O'),
        
        (26, 12, 'E'), 
        (26, 7, 'O'), 
        (26, 28, 'O'), 
        (26, 9, 'O'), 
        (26, 1, 'O'),
        
        (27, 6, 'E'), 
        (27, 15, 'O'), 
        (27, 4, 'O'), 
        (27, 2, 'O'),
        
        (28, 30, 'E'), 
        (28, 17, 'O'), 
        (28, 16, 'O'), 
        (28, 12, 'O'),
        
        (29, 29, 'E'), 
        (29, 8, 'O'), 
        (29, 25, 'O'),
        
        (30, 23, 'E'), 
        (30, 15, 'O');
       
-- Populate the table VEHICULOS
INSERT INTO `VEHICULOS` (`idVEHICULO`, `patente`,`tipo`, `modelo`, `funcion`)
VALUES 	('1', 'STR 909', 'Tractor', 'John Deere 5075E', 'Labranza'),
		('2', 'AB 898 ZG', 'Camión', 'Isuzu NPR', 'Transporte de carga'),
		('3', 'RGB 041', 'Pickup', 'Ford F-150', 'Transporte ligero'),
		('4', 'LG 420 BT', 'Cosechadora', 'Case IH Axial-Flow 7150', 'Cosecha de granos'),
		('5', 'ARG 255', 'Remolque', 'Brent 678', 'Transporte de productos agrícolas');
        
-- Populate the table VEHICULOS_POR_PARTES
INSERT INTO `VEHICULOS_POR_PARTES` (`idVEHICULO`, `patente`, `idPARTE`)
VALUES 
    (1, 'STR 909', 1),
    (3, 'RGB 041', 1), 
    (2, 'AB 898 ZG', 2), 
    (3, 'RGB 041', 2), 
    (3, 'RGB 041', 3), 
    (5, 'ARG 255', 3),
    (1, 'STR 909', 4),
    (4, 'LG 420 BT', 4),
    (1, 'STR 909', 5),
    (2, 'AB 898 ZG', 5), 
    (5, 'ARG 255', 5), 
	(1, 'STR 909', 6),
    (3, 'RGB 041', 6), 
    (2, 'AB 898 ZG', 7), 
    (3, 'RGB 041', 7), 
    (3, 'RGB 041', 8), 
    (5, 'ARG 255', 8),
    (1, 'STR 909', 9),
    (4, 'LG 420 BT', 9),
    (1, 'STR 909', 10),
    (2, 'AB 898 ZG', 10), 
    (5, 'LG 420 BT', 10), 
    (1, 'STR 909', 11),
    (3, 'RGB 041', 11), 
    (2, 'AB 898 ZG', 12), 
    (3, 'RGB 041', 12),
    (3, 'RGB 041', 13), 
    (5, 'ARG 255', 13),
    (1, 'STR 909', 14),
    (4, 'LG 420 BT', 14),
    (1, 'STR 909', 15),
    (2, 'AB 898 ZG', 15), 
    (5, 'ARG 255', 15), 
	(1, 'STR 909', 17),
    (3, 'RGB 041', 17), 
    (2, 'AB 898 ZG', 18), 
    (3, 'RGB 041', 18),
    (3, 'RGB 041', 19), 
    (5, 'ARG 255', 19),
    (1, 'STR 909', 20),
    (4, 'LG 420 BT', 20),
    (2, 'AB 898 ZG', 20), 
    (5, 'ARG 255', 20);
    
COMMIT ;


