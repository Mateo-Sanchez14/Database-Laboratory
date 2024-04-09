-- Año: 2024
-- Grupo Nro:
-- Integrantes: Grellet Martinoia, Alejandro // Sanchez Mateo 
-- Tema: AGROSA
-- Nombre del Esquema (LBD02024G()AGROSA)
-- Plataforma Windows 10 // Docker Buildx (Docker Inc., v0.9.1) :
-- Motor y Versión: MySQL SServer 8.0.36
-- GitHub Repositorio: LBD2024G04
-- GitHub Usuario: AlejandroGrellet // Mateo-Sanchez14
CREATE SCHEMA IF NOT EXISTS `LBD2024G()AGROSA` DEFAULT CHARACTER SET utf8;

CREATE TABLE IF NOT EXISTS `LBD2024G()AGROSA`.`USUARIOS`
(
    `idUSUARIOS`  INT(11)                                                   NOT NULL AUTO_INCREMENT,
    `usuario`     VARCHAR(30)                                               NOT NULL,
    `password`    VARCHAR(30)                                               NOT NULL,
    `tipoUsuario` ENUM ('Administrador', 'Secretario') DEFAULT 'Secretario' NOT NULL,
    `estado`      BINARY(1)                                                 NOT NULL,
    PRIMARY KEY (`idUSUARIOS`),
    UNIQUE INDEX `idUsuario_UNIQUE` (`idUSUARIOS` ASC) VISIBLE
)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `LBD2024G()AGROSA`.`RUBROS`
(
    `idRUBROS`  INT(11)                    NOT NULL AUTO_INCREMENT,
    `rubro`     VARCHAR(45)                NOT NULL,
    `tipoRubro` ENUM ('Egreso', 'Ingreso') NOT NULL,
    `estado`    CHAR(1)                    NOT NULL,
    PRIMARY KEY (`idRUBROS`),
    UNIQUE INDEX `idRUBROS_UNIQUE` (`idRUBROS` ASC) VISIBLE
)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `LBD2024G()AGROSA`.`MOVIMIENTOS`
(
    `idMOVIMIENTOS`  INT(11)     NOT NULL,
    `tipoMovimiento` CHAR(1)     NOT NULL,
    `fecha`          DATE        NOT NULL,
    `monto`          DECIMAL     NOT NULL,
    `detalle`        VARCHAR(80) NULL DEFAULT NULL,
    `estado`         CHAR(1)     NOT NULL,
    `idRUBROS`       INT(11)     NOT NULL,
    PRIMARY KEY (`idMOVIMIENTOS`, `tipoMovimiento`, `idRUBROS`),
    UNIQUE INDEX `idMOVIMIENTOS_UNIQUE` (`idMOVIMIENTOS` ASC) VISIBLE,
    INDEX `fk_MOVIMIENTOS_RUBROS_idx` (`idRUBROS` ASC) VISIBLE,
    CONSTRAINT Check_Montos CHECK (`tipoMovimiento` = "E" AND `monto` <= 0 OR `tipoMovimiento` = "I" AND `monto` >= 0 ),
    CONSTRAINT `fk_MOVIMIENTOS_RUBROS`
        FOREIGN KEY (`idRUBROS`)
            REFERENCES `LBD2024G()AGROSA`.`RUBROS` (`idRUBROS`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `LBD2024G()AGROSA`.`EMPLEADOS`
(
    `idEMPLEADO` INT(11)          NOT NULL,
    `cuil`       INT(11) UNSIGNED NOT NULL,
    `nombres`    VARCHAR(30)      NOT NULL,
    `apellidos`  VARCHAR(30)      NOT NULL,
    `estado`     CHAR(1)          NOT NULL,
    PRIMARY KEY (`idEMPLEADO`),
    UNIQUE INDEX `idEMPLEADOS_UNIQUE` (`idEMPLEADO` ASC) VISIBLE
)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `LBD2024G()AGROSA`.`FINCAS`
(
    `idFINCA`         INT(11)     NOT NULL,
    `finca`           VARCHAR(45) NOT NULL,
    `responsable`     VARCHAR(45) NOT NULL,
    `cuilResoinsable` INT(11)     NOT NULL,
    `latitud`         FLOAT(11)   NULL DEFAULT NULL,
    `longitud`        FLOAT(11)   NULL DEFAULT NULL,
    PRIMARY KEY (`idFINCA`),
    UNIQUE INDEX `idFINCAS_UNIQUE` (`idFINCA` ASC) VISIBLE,
    UNIQUE INDEX `longitud_UNIQUE` (`longitud` ASC) VISIBLE,
    UNIQUE INDEX `latitud_UNIQUE` (`latitud` ASC) VISIBLE
)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `LBD2024G()AGROSA`.`PARTES`
(
    `idPARTE`     INT(11)   NOT NULL,
    `fechaParte`  DATE      NOT NULL,
    `estado`      CHAR(1)   NOT NULL,
    `superficie`  FLOAT(11) NOT NULL,
    `idENCARGADO` INT(11)   NOT NULL,
    `idFINCA`     INT(11)   NOT NULL,
    PRIMARY KEY (`idPARTE`),
    UNIQUE INDEX `idPARTES_UNIQUE` (`idPARTE` ASC) VISIBLE,
    INDEX `fk_PARTES_EMPLEADOS1_idx` (`idENCARGADO` ASC) VISIBLE,
    INDEX `fk_PARTES_FINCAS1_idx` (`idFINCA` ASC) VISIBLE,
    CONSTRAINT `fk_PARTES_EMPLEADOS1`
        FOREIGN KEY (`idENCARGADO`)
            REFERENCES `LBD2024G()AGROSA`.`EMPLEADOS` (`idEMPLEADO`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
    CONSTRAINT `fk_PARTES_FINCAS1`
        FOREIGN KEY (`idFINCA`)
            REFERENCES `LBD2024G()AGROSA`.`FINCAS` (`idFINCA`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS `LBD2024G()AGROSA`.`LINEAS_PARTES`
(
    `idPARTE`    INT(11) NOT NULL,
    `idEMPLEADO` INT(11) NOT NULL,
    `rol`        CHAR(1) NULL DEFAULT NULL,
    PRIMARY KEY (`idPARTE`, `idEMPLEADO`),
    INDEX `fk_PARTES_has_EMPLEADOS_EMPLEADOS1_idx` (`idEMPLEADO` ASC) VISIBLE,
    INDEX `fk_PARTES_has_EMPLEADOS_PARTES1_idx` (`idPARTE` ASC) VISIBLE,
    CONSTRAINT `fk_PARTES_has_EMPLEADOS_PARTES1`
        FOREIGN KEY (`idPARTE`)
            REFERENCES `LBD2024G()AGROSA`.`PARTES` (`idPARTE`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
    CONSTRAINT `fk_PARTES_has_EMPLEADOS_EMPLEADOS1`
        FOREIGN KEY (`idEMPLEADO`)
            REFERENCES `LBD2024G()AGROSA`.`EMPLEADOS` (`idEMPLEADO`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB
    DEFAULT CHARACTER SET = utf8;


-- Populate all the Tables with at least 20 rows each


START TRANSACTION ;
-- Populate the table USUARIOS
-- Insert sample data into the USUARIOS table
INSERT INTO `LBD2024G()AGROSA`.`USUARIOS` (`usuario`, `password`, `tipoUsuario`, `estado`)
VALUES ('JohnDoe', 'password1', 'Administrador', 1),
       ('JaneDoe', 'password2', 'Secretario', 1),
       ('AliceSmith', 'password3', 'Secretario', 0),
       ('BobJohnson', 'password4', 'Administrador', 1),
       ('EmilyBrown', 'password5', 'Secretario', 1);

-- Populate the table RUBROS

INSERT INTO `LBD2024G()AGROSA`.`RUBROS` (`rubro`, `tipoRubro`, `estado`)
VALUES ('Venta', 'Ingreso', 'A'),
       ('Empleados', 'Egreso', 'A'),
       ('Insumos', 'Egreso', 'A'),
       ('Maquinaria', 'Egreso', 'A'),
       ('Impuestos', 'Egreso', 'A'),
       ('Servicios', 'Ingreso', 'A'),
       ('Arriendo', 'Egreso', 'A');

-- Populate the table MOVIMIENTOS
INSERT INTO `LBD2024G()AGROSA`.`MOVIMIENTOS` (`idMOVIMIENTOS`, `tipoMovimiento`, `fecha`, `monto`, `detalle`, `estado`,
                                              `idRUBROS`)
VALUES (1, 'I', '2024-01-01', 1000, 'Venta de Trigo', 'A', 1),
       (2, 'E', '2024-01-01', -500, 'Pago de Sueldos', 'A', 2),
       (3, 'E', '2024-01-01', -200, 'Compra de Semillas', 'A', 3),
       (4, 'E', '2024-01-01', -300, 'Compra de Fertilizantes', 'A', 3),
       (5, 'E', '2024-01-01', -400, 'Compra de Herbicidas', 'A', 3),
       (6, 'E', '2024-01-01', -500, 'Compra de Maquinaria', 'A', 4),
       (7, 'E', '2024-01-01', -600, 'Pago de Impuestos', 'A', 5),
       (8, 'I', '2024-01-01', 700, 'Venta de Servicios', 'A', 6),
       (9, 'E', '2024-01-01', -800, 'Pago de Arriendo', 'A', 7),
       (10, 'I', '2024-01-01', 900, 'Venta de Trigo', 'A', 1),
       (11, 'E', '2024-01-01', -1000, 'Pago de Sueldos', 'A', 2),
       (12, 'E', '2024-01-01', -1100, 'Compra de Semillas', 'A', 3),
       (13, 'E', '2024-01-01', -1200, 'Compra de Fertilizantes', 'A', 3),
       (14, 'E', '2024-01-01', -1300, 'Compra de Herbicidas', 'A', 3),
       (15, 'E', '2024-01-01', -1400, 'Compra de Maquinaria', 'A', 4),
       (16, 'E', '2024-01-01', -1500, 'Pago de Impuestos', 'A', 5),
       (17, 'I', '2024-01-01', 1600, 'Venta de Servicios', 'A', 6),
       (18, 'E', '2024-01-01', -1700, 'Pago de Arriendo', 'A', 7),
       (19, 'I', '2024-01-01', 1800, 'Venta de Trigo', 'A', 1),
       (20, 'E', '2024-01-01', -1900, 'Pago de Sueldos', 'A', 2);

-- Populate the table EMPLEADOS
INSERT INTO `LBD2024G()AGROSA`.`EMPLEADOS` (`idEMPLEADO`, `cuil`, `nombres`, `apellidos`, `estado`)
VALUES (1, 123456789, 'Juan', 'Perez', 'A'),
       (2, 987654321, 'Maria', 'Gomez', 'A'),
       (3, 456789123, 'Pedro', 'Rodriguez', 'A'),
       (4, 321654987, 'Ana', 'Martinez', 'A'),
       (5, 654987321, 'Carlos', 'Lopez', 'A'),
       (6, 789123456, 'Laura', 'Garcia', 'A'),
       (7, 654321987, 'Diego', 'Fernandez', 'A'),
       (8, 321987654, 'Silvia', 'Alvarez', 'A'),
       (9, 987321654, 'Jorge', 'Diaz', 'A'),
       (10, 456123789, 'Marta', 'Benitez', 'A'),
       (11, 789654321, 'Ricardo', 'Sosa', 'A'),
       (12, 654789321, 'Florencia', 'Torres', 'A'),
       (13, 321789654, 'Roberto', 'Paz', 'A'),
       (14, 987123654, 'Cecilia', 'Vera', 'A'),
       (15, 456321789, 'Esteban', 'Rios', 'A'),
       (16, 789654123, 'Carolina', 'Mendez', 'A'),
       (17, 654123789, 'Federico', 'Luna', 'A'),
       (18, 321654789, 'Gabriela', 'Aguirre', 'A'),
       (19, 987654123, 'Ezequiel', 'Gimenez', 'A'),
       (20, 456987321, 'Valeria', 'Peralta', 'A');

-- Populate the table FINCAS
INSERT INTO `LBD2024G()AGROSA`.`FINCAS` (`idFINCA`, `finca`, `responsable`, `cuilResoinsable`, `latitud`, `longitud`)
VALUES (1, 'La Estancia', 'Juan Perez', 123456789, -34.23722, -51.281592),
       (2, 'El Descanso', 'Maria Gomez', 987654321, -34.6321722, -18.381592),
       (3, 'La Esperanza', 'Pedro Rodriguez', 456789123, -33.603722, -28.381592),
       (4, 'La Fortuna', 'Ana Martinez', 321654987, -34.60312, -38.381592),
       (5, 'La Victoria', 'Carlos Lopez', 654987321, -34.63722, -58.381392),
       (6, 'La Paz', 'Laura Garcia', 789123456, -34.223722, -52.381392),
       (7, 'La Libertad', 'Diego Fernandez', 654321987, -34.6413722, -12.381392),
       (8, 'La Felicidad', 'Silvia Alvarez', 321987654, -34.601722, -15.181392),
       (9, 'La Unión', 'Jorge Diaz', 987321654, -34.923722, -15.381392),
       (10, 'La Perseverancia', 'Marta Benitez', 456123789, -34.231722, -15.681392),
       (11, 'La Justicia', 'Ricardo Sosa', 789654321, -34.333722, -15.671392),
       (12, 'La Gloria', 'Florencia Torres', 654789321, -34.60643722, -15.676392),
       (13, 'La Dicha', 'Roberto Paz', 321789654, -34.606422, -15.676792),
       (14, 'La Prosperidad', 'Cecilia Vera', 987123654, -34.1233722, -15.676772),
       (15, 'La Alegría', 'Esteban Rios', 456321789, -34.6643722, -15.6123772),
       (16, 'La Fe', 'Carolina Mendez', 789654123, -34.6023422, -15.613772),
       (17, 'La Tranquilidad', 'Federico Luna', 654123789, -34.623421, -16.613772),
       (18, 'La Armonía', 'Gabriela Aguirre', 321654789, -34.62131, -17.613772),
       (19, 'La Solidaridad', 'Ezequiel Gimenez', 987654123, -24.603722, -18.613772),
       (20, 'La Caridad', 'Valeria Peralta', 456987321, -33.123722, -19.613772);

-- Populate the table PARTES
INSERT INTO `LBD2024G()AGROSA`.`PARTES` (`idPARTE`, `fechaParte`, `estado`, `superficie`, `idENCARGADO`, `idFINCA`)
VALUES (1, '2024-05-13', 'A', 100, 1, 1),
       (2, '2024-01-25', 'A', 200, 2, 2),
       (3, '2024-04-11', 'A', 300, 3, 3),
       (4, '2023-11-17', 'P', 400, 4, 4),
       (5, '2024-04-22', 'A', 500, 5, 5),
       (6, '2024-10-16', 'A', 600, 6, 6),
       (7, '2024-10-14', 'A', 700, 7, 7),
       (8, '2022-11-22', 'A', 800, 8, 8),
       (9, '2024-04-21', 'A', 900, 9, 9),
       (10, '2024-08-14', 'A', 1000, 10, 10),
       (11, '2024-02-29', 'A', 1100, 11, 11),
       (12, '2024-11-01', 'A', 1200, 12, 12),
       (13, '2024-01-08', 'A', 1300, 13, 13),
       (14, '2024-06-18', 'A', 1400, 14, 14),
       (15, '2024-03-07', 'A', 1500, 15, 15),
       (16, '2024-03-08', 'A', 1600, 16, 16),
       (17, '2024-03-15', 'A', 1700, 17, 17),
       (18, '2024-03-23', 'A', 1800, 18, 18),
       (19, '2024-03-26', 'A', 1900, 19, 19),
       (20, '2024-03-27', 'A', 2000, 20, 20);

-- Populate the table LINEAS_PARTES
INSERT INTO `LBD2024G()AGROSA`.`LINEAS_PARTES` (`idPARTE`, `idEMPLEADO`, `rol`)
VALUES (1, 1, 'E'),
       (1, 2, 'O'),
       (1, 3, 'O'),
       (1, 4, 'O'),
       (1, 5, 'O'),
       (2, 6, 'E'),
       (2, 7, 'O'),
       (2, 8, 'O'),
       (2, 9, 'O'),
       (2, 10, 'O'),
       (3, 11, 'E'),
       (3, 12, 'O'),
       (3, 13, 'O'),
       (3, 14, 'O'),
       (3, 15, 'O'),
       (4, 16, 'E'),
       (4, 17, 'O'),
       (4, 18, 'O'),
       (4, 19, 'O'),
       (4, 20, 'O'),
       (5, 1, 'E'),
       (5, 2, 'O'),
       (5, 3, 'O'),
       (5, 4, 'O'),
       (5, 5, 'O'),
       (6, 6, 'E'),
       (6, 7, 'O'),
       (6, 8, 'O'),
       (6, 9, 'O'),
       (6, 10, 'O'),
       (7, 11, 'E'),
       (7, 12, 'O'),
       (7, 13, 'O'),
       (7, 14, 'O'),
       (7, 15, 'O'),
       (8, 16, 'E'),
       (8, 17, 'O'),
       (8, 18, 'O'),
       (8, 19, 'O'),
       (8, 20, 'O'),
       (9, 1, 'E'),
       (9, 2, 'O'),
       (9, 3, 'O'),
       (9, 4, 'O'),
       (9, 5, 'O'),
       (10, 6, 'E'),
       (10, 7, 'O'),
       (10, 8, 'O'),
       (10, 9, 'O'),
       (10, 10, 'O'),
       (11, 11, 'E'),
       (11, 12, 'O'),
       (11, 13, 'O'),
       (11, 14, 'O'),
       (11, 15, 'O'),
       (12, 16, 'E'),
       (12, 17, 'O'),
       (12, 18, 'O'),
       (12, 19, 'O'),
       (12, 20, 'O'),
       (13, 1, 'E'),
       (13, 2, 'O'),
       (13, 3, 'O'),
       (13, 4, 'O'),
       (13, 5, 'O'),
       (14, 6, 'E'),
       (14, 7, 'O'),
       (14, 8, 'O'),
       (14, 9, 'O'),
       (14, 10, 'O'),
       (15, 11, 'E'),
       (15, 12, 'O'),
       (15, 13, 'O'),
       (15, 14, 'O'),
       (15, 15, 'O'),
       (16, 16, 'E'),
       (16, 17, 'O'),
       (16, 18, 'O'),
       (16, 19, 'O'),
       (16, 20, 'O'),
       (17, 1, 'E'),
       (17, 2, 'O'),
       (17, 3, 'O'),
       (17, 4, 'O'),
       (17, 5, 'O'),
       (18, 6, 'E'),
       (18, 7, 'O'),
       (18, 8, 'O'),
       (18, 9, 'O'),
       (18, 10, 'O'),
       (19, 11, 'E'),
       (19, 12, 'O'),
       (19, 13, 'O'),
       (19, 14, 'O'),
       (19, 15, 'O'),
       (20, 16, 'E'),
       (20, 17, 'O'),
       (20, 18, 'O'),
       (20, 19, 'O'),
       (20, 20, 'O');


COMMIT ;
