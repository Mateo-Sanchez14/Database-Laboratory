# 3. Borrado
# Se deberá auditar el tipo de operación que se realizó (creación, borrado,
# modificación), el usuario que la hizo, la fecha y hora de la operación, la máquina
# desde donde se la hizo y todas las información necesaria para la auditoría (en el caso
# de las modificaciones, se deberán auditar tanto los valores viejos como los nuevos).

DROP TABLE IF EXISTS `AUDITORIAS_PARTES`;
CREATE TABLE IF NOT EXISTS `AUDITORIAS_PARTES`
(
    `idAUDITORIA_PARTE` INT                                                                   NOT NULL AUTO_INCREMENT,
    `usuario`           VARCHAR(30)                                                           NOT NULL,
    `host`              VARCHAR(30)                                                           NOT NULL,
    `fecha`             DATETIME,
    `tipoOperacion`     ENUM ('Insercion', 'Modificacion/OLD', 'Modificacion/NEW', 'Borrado') NOT NULL,
    `idPARTE`           INT(11)                                                               NOT NULL,
    `idENCARGADO`       INT(11)                                                               NOT NULL,
    `idFINCA`           INT(11)                                                               NOT NULL,
    `fechaParte`        DATE                                                                  NOT NULL,
    `estado`            CHAR(1)                                                               NOT NULL DEFAULT 'P',
    `superficie`        FLOAT(11)                                                             NOT NULL,
    PRIMARY KEY (`idAUDITORIA_PARTE`)
);
DROP TABLE IF EXISTS `AUDITORIAS_LINEAS_PARTES`;
CREATE TABLE IF NOT EXISTS `AUDITORIAS_LINEAS_PARTES`
(
    `idAUDITORIA_LINEA_PARTE` INT                                                                   NOT NULL AUTO_INCREMENT,
    `usuario`                 VARCHAR(30)                                                           NOT NULL,
    `host`                    VARCHAR(30)                                                           NOT NULL,
    `fecha`                   DATETIME,
    `tipoOperacion`           ENUM ('Insercion', 'Modificacion/OLD', 'Modificacion/NEW', 'Borrado') NOT NULL,
    `idPARTE`                 INT                                                                   NOT NULL,
    `idEMPLEADO`              INT                                                                   NOT NULL,
    `rol`                     CHAR(1)                                                               NULL DEFAULT NULL,
    PRIMARY KEY (`idAUDITORIA_LINEA_PARTE`)
);
# 6. Borrado de un Parte y sus Líneas (no en cascada).

DELIMITER //

DROP TRIGGER IF EXISTS `borrado_parte` //

CREATE TRIGGER `borrado_parte`
    AFTER DELETE
    ON `PARTES`
    FOR EACH ROW
BEGIN
    INSERT INTO `AUDITORIAS_PARTES` (`usuario`, `host`, `fecha`, `tipoOperacion`, `idPARTE`, `idENCARGADO`, `idFINCA`,
                                     `fechaParte`, `estado`, `superficie`)
    VALUES (USER(), HOST(), NOW(), 'Borrado', OLD.`idPARTE`, OLD.`idENCARGADO`, OLD.`idFINCA`, OLD.`fechaParte`,
            OLD.`estado`, OLD.`superficie`);
END //

DROP TRIGGER IF EXISTS `borrado_linea_parte` //

CREATE TRIGGER `borrado_linea_parte`
    AFTER DELETE
    ON `LINEAS_PARTES`
    FOR EACH ROW
BEGIN
    INSERT INTO `AUDITORIAS_LINEAS_PARTES` (`usuario`, `host`, `fecha`, `tipoOperacion`, `idPARTE`, `idEMPLEADO`, `rol`)
    VALUES (USER(), HOST(), NOW(), 'Borrado', OLD.`idPARTE`, OLD.`idEMPLEADO`, OLD.`rol`);
END //

DROP PROCEDURE IF EXISTS `borrar_parte` //

CREATE PROCEDURE `borrar_parte`(IN `id` INT, OUT `resultado` VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET resultado = 'Error al intentar borrar la parte.';
    END;

    DELETE FROM `LINEAS_PARTES` WHERE `idPARTE` = id;

    DELETE FROM `PARTES` WHERE `idPARTE` = id;
    IF ROW_COUNT() = 0 THEN
        SET resultado = 'El idPARTE no existe en PARTES.';
    ELSE
        SET resultado = 'Operación exitosa.';
    END IF;
END //



# 8. Listado de Partes, ordenado por fecha de Parte

DROP PROCEDURE IF EXISTS `listar_partes` //

CREATE PROCEDURE `listar_partes`(OUT `resultado` VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET resultado = 'Error al listar las partes.';
    END;

    SELECT `idPARTE`, `idENCARGADO`, `idFINCA`, `fechaParte`, `estado`, `superficie`
    FROM `PARTES`
    ORDER BY `fechaParte` ASC;

    SET resultado = 'Operación exitosa.';
END //


# 9 Dado un rango de fechas, mostrar los Partes y sus líneas por Finca.

DROP PROCEDURE IF EXISTS `listar_partes_por_fecha` //

CREATE PROCEDURE `listar_partes_por_fecha`(IN `fechaInicio` DATE, IN `fechaFin` DATE, OUT `resultado` VARCHAR(255))
SALIR: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET resultado = 'Error al listar las partes por fecha.';
    END;

    IF fechaInicio > fechaFin THEN
        SET resultado = 'La fecha de inicio es mayor que la fecha de fin.';
        LEAVE SALIR;
    END IF;

    SELECT `P`.`idPARTE`, `P`.`idENCARGADO`, `P`.`idFINCA`, `P`.`fechaParte`, `P`.`estado`, `P`.`superficie`,
           `LP`.`idEMPLEADO`, `LP`.`rol`
    FROM `PARTES` `P`
             JOIN `LINEAS_PARTES` `LP` ON `P`.`idPARTE` = `LP`.`idPARTE`
    WHERE `P`.`fechaParte` BETWEEN fechaInicio AND fechaFin
    ORDER BY `P`.`idFINCA`, `P`.`fechaParte`;

    IF ROW_COUNT() = 0 THEN
        SET resultado = 'No se encontraron registros en el rango de fechas especificado.';
    ELSE
        SET resultado = 'Operación exitosa.';
    END IF;
END //


# 10. Suma de superficies de Partes por Finca en un rango de fechas.

DROP PROCEDURE IF EXISTS `sumar_superficies_por_finca` //

CREATE PROCEDURE `sumar_superficies_por_finca`(IN `fechaInicio` DATE, IN `fechaFin` DATE, OUT `resultado` VARCHAR(255))
SALIR: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET resultado = 'Error al sumar superficies por finca.';
    END;

    IF fechaInicio > fechaFin THEN
        SET resultado = 'La fecha de inicio es mayor que la fecha de fin.';
        LEAVE SALIR;
    END IF;

    SELECT `P`.`idFINCA`, `F`.`nombreFinca` AS `nombre_finca`, SUM(`P`.`superficie`) AS `superficieTotal`
    FROM `PARTES` `P`
             JOIN `FINCAS` `F` ON `P`.`idFINCA` = `F`.`idFINCA`
    WHERE `P`.`fechaParte` BETWEEN fechaInicio AND fechaFin
    GROUP BY `P`.`idFINCA`;

    IF ROW_COUNT() = 0 THEN
        SET resultado = 'No se encontraron registros en el rango de fechas especificado.';
    ELSE
        SET resultado = 'Operación exitosa.';
    END IF;
END //

# 11. Llamadas a los procedimientos almacenados con errores y exitosos.





