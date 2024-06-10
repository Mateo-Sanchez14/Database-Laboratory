USE `lbd2024g06agrosa`;
DROP TABLE IF EXISTS `AUDITORIAS_PARTES`;
CREATE TABLE IF NOT EXISTS `AUDITORIAS_PARTES`
(
	`idAUDITORIA_PARTE`   INT 		  NOT NULL AUTO_INCREMENT,
    `usuario` 	  		  VARCHAR(30) NOT NULL,
    `host` 		  		  VARCHAR(30) NOT NULL,
    `tipoOperacion`		  ENUM ('Incersion', 'Modificacion', 'Borrado') NOT NULL,
    `fecha` 	  		  DATETIME 	  NOT NULL,
    `idPARTE`			  INT		  NOT NULL,
    `idFINCA`			  INT		  NOT NULL,
    `nombreFinca` 		  VARCHAR(45) NOT NULL,
    `fechaParte`  		  DATE        NOT NULL,
    `estadoParte`  		  CHAR(1)     NOT NULL,
    `superficie`  		  FLOAT(11)   NOT NULL,
    `idENCARGADO`		  INT 		  NOT NULL,
    `nombresEncargado` 	  VARCHAR(30) NOT NULL,
    `apellidosEncargado`  VARCHAR(30) NOT NULL
    PRIMARY KEY(`idAUDITORIA_PARTE`)
);
DROP TABLE IF EXISTS `AUDITORIAS_LINEAS_PARTES`;
CREATE TABLE IF NOT EXISTS `AUDITORIAS_LINEAS_PARTES`
(
	`idAUDITORIA_LINEA_PARTE`   INT 		NOT NULL AUTO_INCREMENT,
	`usuario` 	  		  		VARCHAR(30) NOT NULL,
    `host` 		  		  		VARCHAR(30) NOT NULL,
    `tipoOperacion`		  		ENUM ('Incersion', 'Modificacion', 'Borrado') NOT NULL,
    `idPARTE`			 		INT		    NOT NULL,
    `idEMPLEADO`			 	INT		    NOT NULL,
    `nombresEmpleado`     		VARCHAR(30) NOT NULL,
    `apellidosEmpleado`   		VARCHAR(30) NOT NULL,
    `rol`         		  		CHAR(1) 	NULL DEFAULT NULL
    
);

DELIMITER $$

CREATE TRIGGER `creacionPartesTrigg` 
AFTER INSERT ON `LINEAS_PARTES`FOR EACH ROW
BEGIN
	DECLARE username 			VARCHAR(30);
    DECLARE hostname 			VARCHAR(30); 
    
    DECLARE nombreFinca			VARCHAR(45);
    DECLARE fechaParte 			DATE; 
    DECLARE estadoParte 		VARCHAR(30);
    DECLARE superficie 			FLOAT(11); 
    
    DECLARE nombresEncargado 	VARCHAR(30);
    DECLARE apellidosEncargado 	VARCHAR(30); 
    DECLARE nombresEmpleado 	VARCHAR(30);
    DECLARE apellidosEmpleado 	VARCHAR(30); 
    
    SELECT E.nombres, E.apellidos FROM EMPLEADOS E
    JOIN PARTES P
    ON P.idPARTE = NEW.idPARTE
    
    SET username = CURRENT_USER();
    SELECT @hostname INTO hostname;
    INSERT INTO AUDITORIAS_PARTES VALUES(
		DEFAULT,
        username,
        hostname,
        NOW(),
    );
END $$
DELIMITER ;
    
    