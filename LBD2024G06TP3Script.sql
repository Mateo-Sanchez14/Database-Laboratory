USE `LBD2024G06AGROSA`;

DROP TABLE IF EXISTS `AUDITORIAS_PARTES`;
DROP TABLE IF EXISTS `AUDITORIAS_LINEAS_PARTES`;

CREATE TABLE IF NOT EXISTS `AUDITORIAS_PARTES`
(
	`idAUDITORIA_PARTE`   	INT 		NOT NULL AUTO_INCREMENT,
    `usuario` 	  		  	VARCHAR(30) NOT NULL,
    `host` 		  		  	VARCHAR(30) NOT NULL,
    `fecha`					DATETIME,
    `tipoOperacion`		  	ENUM ('Insercion', 'Modificacion/OLD', 'Modificacion/NEW', 'Borrado') NOT NULL,
    `idPARTE`     			INT(11)   NOT NULL,
    `idENCARGADO` 			INT(11)   NOT NULL,
    `idFINCA`     			INT(11)   NOT NULL,
    `fechaParte`  			DATE      NOT NULL,
    `estado`      			CHAR(1)   NOT NULL,
    `superficie`  			FLOAT(11) NOT NULL,
    PRIMARY KEY(`idAUDITORIA_PARTE`)
);

CREATE TABLE IF NOT EXISTS `AUDITORIAS_LINEAS_PARTES`
(
	`idAUDITORIA_LINEA_PARTE`   INT 		NOT NULL AUTO_INCREMENT,
	`usuario` 	  		  		VARCHAR(30) NOT NULL,
    `host` 		  		  		VARCHAR(30) NOT NULL,
    `fecha`						DATETIME,
    `tipoOperacion`		  		ENUM ('Insercion', 'Modificacion/OLD', 'Modificacion/NEW', 'Borrado') NOT NULL,
    `idPARTE`			 		INT		    NOT NULL,
    `idEMPLEADO`			 	INT		    NOT NULL,
    `rol`         		  		CHAR(1) 	NULL DEFAULT NULL,
	PRIMARY KEY(`idAUDITORIA_LINEA_PARTE`)
);

-- Triggers para la tabla PARTES
DROP TRIGGER IF EXISTS `creacionPartesTrigg`;
DROP TRIGGER IF EXISTS `modificacionPartesTrigg`;

DELIMITER $$
CREATE TRIGGER `creacionPartesTrigg` 
AFTER INSERT ON `PARTES`
FOR EACH ROW
BEGIN
	DECLARE username 	VARCHAR(30);
    DECLARE hostname 	VARCHAR(30); 
    
    SET username = SUBSTRING_INDEX(USER(), '@', 1);
    SET hostname = SUBSTRING_INDEX(USER(), '@', -1);
    
    INSERT INTO AUDITORIAS_PARTES VALUES(
		DEFAULT,
        username,
        hostname,
        NOW(),
        'Insercion',
        NEW.idPARTE,
        NEW.idENCARGADO,
        NEW.idFINCA,
        NEW.fechaParte,
        NEW.estado,
        NEW.superficie
    );
END $$

CREATE TRIGGER `modificacionPartesTrigg` 
AFTER UPDATE ON `PARTES`
FOR EACH ROW
BEGIN
	DECLARE username 	VARCHAR(30);
    DECLARE hostname 	VARCHAR(30); 
    
    SET username = SUBSTRING_INDEX(USER(), '@', 1);
    SET hostname = SUBSTRING_INDEX(USER(), '@', -1);
    
    INSERT INTO AUDITORIAS_PARTES VALUES(
		DEFAULT,
        username,
        hostname,
        NOW(),
        'Modificacion/OLD',
        OLD.idPARTE,
        OLD.idENCARGADO,
        OLD.idFINCA,
        OLD.fechaParte,
        OLD.estado,
        OLD.superficie
    );
    INSERT INTO AUDITORIAS_PARTES VALUES(
		DEFAULT,
        username,
        hostname,
        NOW(),
        'Modificacion/NEW',
        NEW.idPARTE,
        NEW.idENCARGADO,
        NEW.idFINCA,
        NEW.fechaParte,
        NEW.estado,
        NEW.superficie
    );
END $$
DELIMITER ;

-- Triggers para la tabla LINEAS_PARTES
DROP TRIGGER IF EXISTS `creacionLineasPartesTrigg`;
DROP TRIGGER IF EXISTS `modificacionLineasPartesTrigg`;

DELIMITER $$
CREATE TRIGGER `creacionLineasPartesTrigg` 
AFTER INSERT ON `LINEAS_PARTES`
FOR EACH ROW
BEGIN
	DECLARE username 	VARCHAR(30);
    DECLARE hostname 	VARCHAR(30); 
    
    SET username = SUBSTRING_INDEX(USER(), '@', 1);
    SET hostname = SUBSTRING_INDEX(USER(), '@', -1);
    
    INSERT INTO AUDITORIAS_LINEAS_PARTES VALUES(
		DEFAULT,
        username,
        hostname,
        NOW(),
        'Insercion',
        NEW.idPARTE,
        NEW.idEMPLEADO,
        NEW.rol
    );
END $$

CREATE TRIGGER `modificacionLineasPartesTrigg` 
AFTER UPDATE ON `LINEAS_PARTES`
FOR EACH ROW
BEGIN
	DECLARE username 	VARCHAR(30);
    DECLARE hostname 	VARCHAR(30); 
    
    SET username = SUBSTRING_INDEX(USER(), '@', 1);
    SET hostname = SUBSTRING_INDEX(USER(), '@', -1);
    
    INSERT INTO AUDITORIAS_LINEAS_PARTES VALUES(
		DEFAULT,
        username,
        hostname,
        NOW(),
        'Modificacion/OLD',
        OLD.idPARTE,
        OLD.idEMPLEADO,
        OLD.rol
    );
    INSERT INTO AUDITORIAS_LINEAS_PARTES VALUES(
		DEFAULT,
        username,
        hostname,
        NOW(),
        'Modificacion/NEW',
        NEW.idPARTE,
        NEW.idEMPLEADO,
        NEW.rol
    );
END $$

DELIMITER //

DROP TRIGGER IF EXISTS `borrado_parte` //

CREATE TRIGGER `borrado_parte`
    AFTER DELETE
    ON `PARTES`
    FOR EACH ROW
BEGIN
    DECLARE username 	VARCHAR(30);
    DECLARE hostname 	VARCHAR(30);

    SET username = SUBSTRING_INDEX(USER(), '@', 1);
    SET hostname = SUBSTRING_INDEX(USER(), '@', -1);

    INSERT INTO `AUDITORIAS_PARTES` (`usuario`, `host`, `fecha`, `tipoOperacion`, `idPARTE`, `idENCARGADO`, `idFINCA`,
                                     `fechaParte`, `estado`, `superficie`)
    VALUES (username, hostname, NOW(), 'Borrado', OLD.`idPARTE`, OLD.`idENCARGADO`, OLD.`idFINCA`, OLD.`fechaParte`,
            OLD.`estado`, OLD.`superficie`);
END //

DROP TRIGGER IF EXISTS `borrado_linea_parte` //

CREATE TRIGGER `borrado_linea_parte`
    AFTER DELETE
    ON `LINEAS_PARTES`
    FOR EACH ROW
BEGIN
    DECLARE username 	VARCHAR(30);
    DECLARE hostname 	VARCHAR(30);

    SET username = SUBSTRING_INDEX(USER(), '@', 1);
    SET hostname = SUBSTRING_INDEX(USER(), '@', -1);

    INSERT INTO `AUDITORIAS_LINEAS_PARTES` (`usuario`, `host`, `fecha`, `tipoOperacion`, `idPARTE`, `idEMPLEADO`, `rol`)
    VALUES (username, hostname, NOW(), 'Borrado', OLD.`idPARTE`, OLD.`idEMPLEADO`, OLD.`rol`);
END //

DELIMITER ;

-- SECCION PARA LOS STORE PROCEDURES


-- Punto 4: Creación de un Parte y sus Líneas.

DROP PROCEDURE IF EXISTS `crearPartes`;
DROP PROCEDURE IF EXISTS `crearLineasPartes`;

DELIMITER $$
CREATE PROCEDURE `crearPartes` (IN IN_idFINCA INT, IN_fechaParte DATE, IN_superficie FLOAT(11), IN_idENCARGADO INT, IN_estado CHAR(1), OUT mensaje VARCHAR(100))
SALIR: BEGIN

		IF (IN_idFINCA IS NULL) OR (IN_fechaParte IS NULL) OR (IN_superficie IS NULL) OR (IN_idENCARGADO IS NULL)
		THEN
			SET mensaje = 'Error al cargar el parte, datos incompletos';
		LEAVE SALIR;
        
        ELSEIF (IN_fechaParte>NOW())
        THEN 
			SET mensaje = 'Error al cargar el parte, fecha posterior a la actual';
		LEAVE SALIR;
        
        ELSEIF (IN_estado IS NULL)
        THEN
			START TRANSACTION;
				INSERT INTO `PARTES` (`fechaParte`, `superficie`, `idENCARGADO`, `idFINCA`)
				VALUES(IN_fechaParte, IN_superficie, IN_idENCARGADO, IN_idFINCA);
                SET mensaje = 'No se ingresó estado, se guardó el parte con estado por defecto "PENDIENTE"';
			COMMIT;
		LEAVE SALIR;
        
        ELSE
			START TRANSACTION;
				INSERT INTO `PARTES` (`fechaParte`, `estado`, `superficie`, `idENCARGADO`, `idFINCA`)
                VALUES(IN_fechaParte, IN_estado, IN_superficie, IN_idENCARGADO, IN_idFINCA);
                SET mensaje = 'Parte cargado con exito';
			COMMIT;
            END IF;
END$$
DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `crearPartes`

-- Error: Datos incompletos (IN_superficie es NULL)
CALL crearPartes(1, '2024-06-10', NULL, 1, 'P', @mensaje);
SELECT @mensaje;

-- Error: Fecha posterior a la actual
CALL crearPartes(1, '2025-01-01', 100.0, 1, 'P', @mensaje);
SELECT @mensaje;

-- Inserción con estado por defecto "PENDIENTE" (IN_estado es NULL)
CALL crearPartes(1, '2024-06-10', 100.0, 1, NULL, @mensaje);
SELECT @mensaje;
SELECT * FROM AUDITORIAS_PARTES;

-- Inserción correcta
CALL crearPartes(1, '2024-06-10', 100.0, 1, 'C', @mensaje);
SELECT @mensaje;
SELECT * FROM AUDITORIAS_PARTES;

DELIMITER $$
CREATE PROCEDURE `crearLineasPartes` (IN IN_idPARTE INT, IN_idEMPLEADO INT, IN_rol CHAR(1), OUT mensaje VARCHAR(100))
SALIR: BEGIN
		IF (IN_idPARTE IS NULL) OR (IN_idEMPLEADO IS NULL) OR (IN_rol IS NULL)
		THEN
			SET mensaje = 'Error al cargar esta linea, datos incompletos';
		LEAVE SALIR;
        
		ELSEIF EXISTS (SELECT * FROM PARTES WHERE idPARTE = IN_idPARTE AND idENCARGADO = IN_idEMPLEADO)
		THEN
			SET mensaje = 'Error al cargar esta linea, el empleado ingresado ya fue asignado como encargado';
        LEAVE SALIR;
        
        ELSEIF EXISTS (SELECT * FROM LINEAS_PARTES WHERE idPARTE = IN_idPARTE AND idEMPLEADO = IN_idEMPLEADO)
        THEN 
			SET mensaje = 'Error al cargar esta linea, el empleado ya fue ingresado';
		LEAVE SALIR;
        
        ELSE 
			START TRANSACTION;
				INSERT INTO `LINEAS_PARTES` (`idPARTE`, `idEMPLEADO`, `rol`)
				VALUES (IN_idPARTE, IN_idEMPLEADO, IN_rol);
                SET mensaje ='Linea cargada con exito';
			COMMIT;
		END IF;
END $$
 DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `crearLineasPartes`

-- Error: Datos incompletos (IN_idEMPLEADO es NULL)
CALL crearLineasPartes(103, NULL, 'E', @mensaje);
SELECT @mensaje;

-- Error: Empleado asignado como encargado en el parte
CALL crearLineasPartes(103, 1, 'E', @mensaje);
SELECT @mensaje;

-- Error: Empleado cargado 2 veces
CALL crearLineasPartes(103, 2, 'E', @mensaje);
CALL crearLineasPartes(103, 2, 'O', @mensaje);
SELECT @mensaje;

-- Inserción correcta
CALL crearLineasPartes(103, 3, 'O', @mensaje);
SELECT @mensaje;
SELECT * FROM AUDITORIAS_LINEAS_PARTES;

-- Punto 5: Modificación de un Parte y sus Líneas.

DROP PROCEDURE IF EXISTS `modificarPartes`;
DROP PROCEDURE IF EXISTS `modificarLineasPartes`;

DELIMITER $$
CREATE PROCEDURE `modificarPartes` (IN IN_idPARTE INT, IN_idFINCA INT, IN_fechaParte DATE, IN_superficie FLOAT(11), IN_idENCARGADO INT, IN_estado CHAR(1), OUT mensaje VARCHAR(100))
SALIR: BEGIN
			IF NOT EXISTS (SELECT * FROM PARTES WHERE idPARTE = IN_idPARTE)  
            THEN 
				SET mensaje = 'Error, el parte no existe';
			LEAVE SALIR;
            
            ELSEIF (IN_fechaParte>NOW())
            THEN 
				SET mensaje = 'Error al modificar el parte, fecha posterior a la actual';
			LEAVE SALIR;
            
            ELSEIF (IN_idPARTE IS NULL) OR (IN_idFINCA IS NULL) OR (IN_fechaParte IS NULL) OR (IN_superficie IS NULL) OR (IN_idENCARGADO IS NULL)
			THEN
				SET mensaje = 'Error al modificar el parte, datos incompletos';
			LEAVE SALIR; 
            
            ELSEIF EXISTS (SELECT * FROM LINEAS_PARTES WHERE idPARTE = IN_idPARTE AND idEMPLEADO = IN_idENCARGADO)
            THEN 
				SET mensaje = 'Error al modificar el parte, el empleado ingresado ya fue cargado';
			LEAVE SALIR; 
            
            ELSE
				-- Actualizar la parte con los nuevos valores o mantener los existentes si los nuevos son nulos
				UPDATE PARTES
				SET 
					idFINCA = IN_idFINCA,
					fechaParte = IN_fechaParte,
					superficie = IN_superficie,
					idENCARGADO = IN_idENCARGADO,
					estado = IN_estado
				WHERE idPARTE = IN_idPARTE;
				SET mensaje = 'Parte modificado exitosamente';
            END IF;
END$$
DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `modificarPartes`

-- Error: El parte no existe (suponiendo que el idPARTE 999 no existe)
CALL modificarPartes(999, 1, '2024-06-09', 100.0, 1, 'C', @mensaje);
SELECT @mensaje;

-- Error: Fecha posterior a la actual
CALL modificarPartes(103, 1, '2025-01-01', 100.0, 1, 'C', @mensaje);
SELECT @mensaje;

-- Error: Datos incompletos (IN_superficie es NULL)
CALL modificarPartes(1, 1, '2024-06-10', NULL, 1, 'C', @mensaje);
SELECT @mensaje;

-- Modificación correcta
CALL modificarPartes(1, 1, '2024-06-10', 100.0, 1, 'C', @mensaje);
SELECT @mensaje;
SELECT * FROM AUDITORIAS_PARTES;

DELIMITER $$
CREATE PROCEDURE `modificarLineasPartes` (IN IN_idPARTE INT, IN IN_idEMPLEADO INT, IN IN_rol CHAR(1), OUT mensaje VARCHAR(100))
SALIR: BEGIN
    -- Verificar si los datos están completos
    IF (IN_idPARTE IS NULL) OR (IN_idEMPLEADO IS NULL) OR (IN_rol IS NULL) 
    THEN
        SET mensaje = 'Error, datos incompletos';
        LEAVE SALIR;
    ELSEIF NOT EXISTS (SELECT * FROM LINEAS_PARTES WHERE idPARTE = IN_idPARTE AND idEMPLEADO = IN_idEMPLEADO) 
    THEN 
        SET mensaje = 'Error, La línea ingresada no existe';
        LEAVE SALIR;
    ELSE
        -- Actualizar la línea
        UPDATE LINEAS_PARTES
        SET rol = IN_rol
        WHERE idPARTE = IN_idPARTE AND idEMPLEADO = IN_idEMPLEADO;

        SET mensaje = 'Línea modificada exitosamente';
    END IF;
END $$
DELIMITER ;

 -- LLAMADAS AL STORE PROCEDURE `modificarLineasPartes`
 
 -- Error: Datos incompletos (IN_idEMPLEADO es NULL)
CALL modificarLineasPartes(103, NULL, 'E', @mensaje);
SELECT @mensaje;

-- Error: Error, La linea ingresada no existe
CALL modificarLineasPartes(103, 144, 'E', @mensaje);
SELECT @mensaje;

-- Modificación correcta
CALL modificarLineasPartes(103, 3, 'O', @mensaje);
SELECT @mensaje;
SELECT * FROM AUDITORIAS_LINEAS_PARTES;

# 6. Borrado de un Parte y sus Líneas (no en cascada).

DELIMITER //

DROP PROCEDURE IF EXISTS `borrar_parte` //

CREATE PROCEDURE `borrar_parte`(IN `id` INT, OUT `resultado` VARCHAR(255))
SALIR: BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET resultado = 'Error al intentar borrar la parte, tiene lineas parte asociadas.';
    END;

    DELETE FROM `PARTES` WHERE `idPARTE` = id;
    IF ROW_COUNT() = 0 THEN
        SET resultado = 'El idPARTE no existe en PARTES.';
    ELSE
        SET resultado = 'Operación exitosa.';
    END IF;
END //

DROP PROCEDURE IF EXISTS `borrar_linea_parte` //

CREATE PROCEDURE `borrar_linea_parte`(IN `IN_idParte` INT, IN `IN_idEmpleado` INT ,OUT `resultado` VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET resultado = 'Error al intentar borrar la linea de parte.';
    END;

    DELETE FROM `LINEAS_PARTES` WHERE `idPARTE` = IN_idParte AND `idEMPLEADO` = IN_idEmpleado;
    IF ROW_COUNT() = 0 THEN
        SET resultado = 'La linea parte no existe.';
    ELSE
        SET resultado = 'Operación exitosa.';
    END IF;
END //

DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `borrar_parte`

SELECT * FROM PARTES LEFT JOIN LINEAS_PARTES ON PARTES.idPARTE = LINEAS_PARTES.idPARTE  ;

-- Error: No se puede borrar un parte con lineasPartes asociadas
CALL borrar_parte(1, @resultado);
SELECT @resultado;

-- Borrado correcto (El parte 101 no tiene lineas de parte asociadas
CALL borrar_parte(101, @resultado);
SELECT @resultado;


-- LLAMADAS AL STORE PROCEDURE `borrar_linea_parte`

-- Error: El idPARTE no existe en LINEAS_PARTES
CALL borrar_linea_parte(105, 106, @resultado);
SELECT @resultado;

-- Borrado correcto (Vamos a borrar todas las lineas partes del parte 1)
CALL borrar_linea_parte(1, 5, @resultado);
SELECT @resultado;
CALL borrar_linea_parte(1, 8, @resultado);
CALL borrar_linea_parte(1, 15, @resultado);
CALL borrar_linea_parte(1, 24, @resultado);
CALL borrar_linea_parte(1, 25, @resultado);
SELECT @resultado;

-- Borrado correcto Ahora vamos a borrar el parte 1
CALL borrar_parte(1, @resultado);
SELECT @resultado;


-- Punto 7: Búsqueda de un Parte.
-- La búsqueda se realiza por la combinación de idFINCA, idENCARGADO, y fecha, para encontrar un único parte
DROP PROCEDURE IF EXISTS `buscarParte`;
DELIMITER $$
CREATE PROCEDURE `buscarParte`(IN IN_idFINCA INT, IN_idENCARGADO INT, IN_fechaParte DATE, OUT mensaje VARCHAR(100)) 
SALIR: BEGIN
	IF (IN_idFINCA IS NULL) OR (IN_idENCARGADO IS NULL) OR (IN_fechaParte IS NULL)
	THEN
		SET mensaje = 'Error, no se proporcionaron suficientes parámetros';
		LEAVE SALIR;
	ELSEIF (IN_fechaParte>NOW())
    THEN
		SET mensaje = 'Error, la fecha ingresada es posterior a la fecha atual';
		LEAVE SALIR;
	ELSEIF NOT EXISTS (SELECT * FROM PARTES WHERE idFINCA = IN_idFINCA AND idENCARGADO = IN_idENCARGADO AND fechaParte = IN_fechaParte)
	THEN
        SET mensaje = 'El parte buscado no existe';
        LEAVE SALIR;
	ELSE
		SELECT F.nombreFinca AS Finca, CONCAT(E.nombres , E.apellidos) AS Encargado, P.fechaParte AS Fecha, P.superficie, P.estado
        FROM PARTES P
        INNER JOIN EMPLEADOS E
        ON P.idENCARGADO = E.idEMPLEADO
        INNER JOIN FINCAS F
        ON P.idFINCA = F.idFINCA
		WHERE P.idFINCA = IN_idFINCA AND P.idENCARGADO = IN_idENCARGADO AND P.fechaParte = IN_fechaParte
        LIMIT 1;
	END IF;
END$$
DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `buscarParte
-- Error: Datos incompletos (IN_idENCARGADO es NULL)
CALL buscarParte (1, NULL, '2024-06-10', @mensaje);
SELECT @mensaje;

-- Error: fecha ingresada es posterior a la fecha atual
CALL buscarParte (1, 2, '2025-06-10', @mensaje);
SELECT @mensaje;

-- Error: El parte buscado no existe
CALL buscarParte (1, 2, '2024-06-10', @mensaje);
SELECT @mensaje;

-- Consulta exitosa
CALL buscarParte (11, 8, '2024-05-15', @mensaje);
-- SELECT @mensaje;

# 8. Listado de Partes, ordenado por fecha de Parte

DELIMITER //

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

DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `listar_partes`

CALL listar_partes(@resultado);

# 9 Dado un rango de fechas, mostrar los Partes y sus líneas por Finca.

DELIMITER //

DROP PROCEDURE IF EXISTS `listar_partes_por_fecha` //

CREATE PROCEDURE `listar_partes_por_fecha`(IN `fechaInicio` DATE, IN `fechaFin` DATE, OUT `resultado` VARCHAR(255))
SALIR: BEGIN
     -- Contar el número de filas devueltas
    DECLARE row_count INT;

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

    # Hago esto porque la funcion ROW_COUNT() me devuelve -1
    SELECT COUNT(*) INTO row_count
    FROM `PARTES` `P`
             JOIN `LINEAS_PARTES` `LP` ON `P`.`idPARTE` = `LP`.`idPARTE`
    WHERE `P`.`fechaParte` BETWEEN fechaInicio AND fechaFin;

    -- Verificar el resultado de la consulta
    IF row_count = 0 THEN
        SET resultado = 'No se encontraron registros en el rango de fechas especificado.';
    ELSE
        SET resultado = 'operacion exitosa.';
    END IF;
END //

DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `listar_partes_por_fecha`

-- Error: La fecha de inicio es mayor que la fecha de fin

CALL listar_partes_por_fecha('2024-06-10', '2024-06-09', @resultado);
SELECT @resultado;

-- Caso: No se encontraron registros en el rango de fechas especificado

CALL listar_partes_por_fecha('2022-06-10', '2022-06-10', @resultado);
SELECT @resultado;

-- Caso: Operación exitosa

CALL listar_partes_por_fecha('2024-06-10', '2024-07-15', @resultado);
SELECT @resultado;


# 10. Suma de superficies de Partes por Finca en un rango de fechas.

DELIMITER //

DROP PROCEDURE IF EXISTS `sumar_superficies_por_finca` //

CREATE PROCEDURE `sumar_superficies_por_finca`(IN `fechaInicio` DATE, IN `fechaFin` DATE, OUT `resultado` VARCHAR(255))
SALIR: BEGIN
    DECLARE row_count INT;

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

    SELECT COUNT(*) INTO row_count
    FROM `PARTES` `P`
             JOIN `FINCAS` `F` ON `P`.`idFINCA` = `F`.`idFINCA`
    WHERE `P`.`fechaParte` BETWEEN fechaInicio AND fechaFin;

    IF row_count = 0 THEN
        SET resultado = 'No se encontraron registros en el rango de fechas especificado.';
    ELSE
        SET resultado = 'Operación exitosa.';
    END IF;
END //

DELIMITER ;

-- LLAMADAS AL STORE PROCEDURE `sumar_superficies_por_finca`

-- Error: La fecha de inicio es mayor que la fecha de fin

CALL sumar_superficies_por_finca('2024-06-10', '2024-06-09', @resultado);
SELECT @resultado;

-- Caso: No se encontraron registros en el rango de fechas especificado

CALL sumar_superficies_por_finca('2022-06-10', '2022-06-10', @resultado);
SELECT @resultado;

-- Caso: Operación exitosa

CALL sumar_superficies_por_finca('2024-06-10', '2024-07-15', @resultado);
SELECT @resultado;


-- Ver tablas de auditorias

SELECT * FROM AUDITORIAS_PARTES;
SELECT * FROM AUDITORIAS_LINEAS_PARTES;