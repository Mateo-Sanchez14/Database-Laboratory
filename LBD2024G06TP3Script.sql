USE `lbd2024g06agrosa`;

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
    
    SET username = CURRENT_USER();
    SELECT @hostname INTO hostname;
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
    
    SET username = CURRENT_USER();
    SELECT @hostname INTO hostname;
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
    
    SET username = CURRENT_USER();
    SELECT @hostname INTO hostname;
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
    
    SET username = CURRENT_USER();
    SELECT @hostname INTO hostname;
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

DELIMITER ;

-- SECCION PARA LOS STORE PROCEDURES
DELIMITER $$
-- Punto 4: Creación de un Parte y sus Líneas.
-- Consideraciones: Se recibe un request con los siguientes datos:
-- 		Nombre de la finca
-- 		Cuil del encargado
-- 		Nombre del empleado que oficia como encargado
-- 		Apellido del empleado que oficia como encargado
-- 		Fecha
-- 		Superficie
-- 		Cuil del empleado
-- 		Nombre del empleado 
-- 		Apellido del empleado
-- 		Rol del empleado 
CREATE PROCEDURE `PUNTO 4` (IN nombreFinca VARCHAR(30), fechaParte DATE, superficie FLOAT(11), cuilEncargado BIGINT(11), nombreEncargado VARCHAR(30), apellidoEncargado VARCHAR(30), cuilEmpleado BIGINT(11), nombreEmpleado VARCHAR(30), apellidoEmpleado VARCHAR(30), rol CHAR(1), OUT mensaje VARCHAR(100))
SALIR: BEGIN
			IF 	(nombreFinca IS NULL) OR (fechaParte IS NULL) OR (superficie IS NULL) OR 
				(cuilEncargado IS NULL) OR (nombreEncargado IS NULL) OR (apellidoEncargado IS NULL)  OR 
				(cuilEmpleado IS NULL) OR (nombreEmpleado IS NULL) OR (apellidoEmpleado IS NULL)
			THEN
				SET mensaje = 'Error al cargar el parte, datos incompletos';
			LEAVE SALIR;
            ELSEIF EXISTS (SELECT * FROM LINEAS_PARTES JOIN
END$$
-- Punto 7: Búsqueda de un Parte.
-- Consideraciones: Se recibe un request con los siguientes datos:
-- 		Nombre de la finca
-- 		Cuil del encargado
-- 		Nombre del empleado que oficia como encargado
-- 		Apellido del empleado que oficia como encargado
-- 		Fecha
-- 		Superficie
-- 		Cuil del empleado
-- 		Nombre del empleado 
-- 		Apellido del empleado
-- 		Rol del empleado 

DELIMITER $$

CREATE PROCEDURE `buscarParte`(
    IN p_nombreFinca VARCHAR(30),
    IN p_fechaParte DATE,
    IN p_superficie FLOAT(11),
    IN p_cuilEncargado BIGINT(11),
    IN p_nombreEncargado VARCHAR(30),
    IN p_apellidoEncargado VARCHAR(30),
    OUT p_mensaje VARCHAR(100)
)
BEGIN
    DECLARE v_idPARTE INT;
    DECLARE v_count INT;

    -- Realizar la búsqueda del parte
    SELECT P.idPARTE
    INTO v_idPARTE
    FROM PARTES P
    JOIN FINCAS F ON P.idFINCA = F.idFINCA
    JOIN EMPLEADOS E ON P.idENCARGADO = E.idEMPLEADO
    WHERE F.nombreFinca = p_nombreFinca
      AND P.fechaParte = p_fechaParte
      AND P.superficie = p_superficie
      AND E.cuil = p_cuilEncargado
      AND E.nombres = p_nombreEncargado
      AND E.apellidos = p_apellidoEncargado
    LIMIT 1;

    -- Verificar si se encontró el parte
    SET v_count = (SELECT COUNT(*) FROM PARTES P
                   JOIN FINCAS F ON P.idFINCA = F.idFINCA
                   JOIN EMPLEADOS E ON P.idENCARGADO = E.idEMPLEADO
                   WHERE F.nombreFinca = p_nombreFinca
                     AND P.fechaParte = p_fechaParte
                     AND P.superficie = p_superficie
                     AND E.cuil = p_cuilEncargado
                     AND E.nombres = p_nombreEncargado
                     AND E.apellidos = p_apellidoEncargado);

    IF v_count = 0 THEN
        SET p_mensaje = 'No se encontró el parte con los criterios especificados.';
    ELSE
        SET p_mensaje = CONCAT('Parte encontrado: ID = ', v_idPARTE);
    END IF;
END $$

DELIMITER ;
