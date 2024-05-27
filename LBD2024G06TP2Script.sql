-- Año: 2024
-- Grupo Nro:06
-- Integrantes: Grellet Martinoia, Alejandro // Sanchez, Mateo
-- Tema: AGROSA
-- Nombre del Esquema (LBD02024G06AGROSA)
-- Plataforma Windows 10 // Docker Buildx (Docker Inc., v0.9.1) :
-- Motor y Versión: MySQL SServer 8.0.36
-- GitHub Repositorio: LBD2024G06
-- GitHub Usuario: AlejandroGrellet // Mateo-Sanchez14

# 1. Dado un propietario, listar todas sus fincas entre ciertas latitudes y longitudes dadas.
DELIMITER $$
CREATE PROCEDURE `SP_LISTAR_FINCAS` (IN cuil BIGINT,IN `latitud1` FLOAT, IN `latitud2` FLOAT, IN `longitud1` FLOAT, IN `longitud2` FLOAT)
BEGIN
    SELECT P.apellidos, P.nombres, F.nombreFinca, F.latitud, F.longitud
    FROM FINCAS F
    JOIN PROPIETARIOS P ON F.cuilPROPIETARIO = P.cuil
    WHERE P.cuil = cuil AND F.latitud BETWEEN latitud1 AND latitud2 AND F.longitud BETWEEN longitud1 AND longitud2
    ORDER BY F.nombreFinca;
END$$


# 2. Realizar un listado de cantidad de partes agrupadas por vehículos.
DELIMITER $$
CREATE PROCEDURE `SP_PARTES_POR_VEHICULO` ()
BEGIN
    SELECT V.tipo, V.modelo, COUNT(*) AS cantidadPartes
    FROM VEHICULOS V
    JOIN VEHICULOS_POR_PARTES VP ON V.idVEHICULO = VP.idVEHICULO AND V.patente = VP.patente
    JOIN PARTES P ON VP.idPARTE = P.idPARTE
    GROUP BY V.idVEHICULO, V.tipo, V.modelo;
END $$

# 3. Dado un año y mes, mostrar la diferencia entre el total de superficie de todos los partes
# de los vehículoe en ese mes, con el mismo mes de otro año también dado.
DELIMITER $$
CREATE PROCEDURE `SP_DIFERENCIA_SUPERFICIE` ( IN anio1 INT, IN mes INT, IN anio2 INT)
BEGIN
    SELECT SUM(CASE WHEN YEAR(fechaParte) = anio1 AND MONTH(fechaParte) = mes THEN superficie ELSE 0 END) -
           SUM(CASE WHEN YEAR(fechaParte) = anio2 AND MONTH(fechaParte) = mes THEN superficie ELSE 0 END) AS diferencia
    FROM PARTES;
END $$

# 4. Dado un rango de fechas, mostrar mes a mes la cantidad de partes por finca. El formato
# deberá ser: més, finca, total de partes
DELIMITER $$
CREATE PROCEDURE `SP_PARTES_POR_FINCA` ( IN fechaInicio DATE, IN fechaFin DATE )
BEGIN
    SELECT MONTH(fechaParte) AS mes, F.nombreFinca, COUNT(*) AS totalPartes
    FROM PARTES P
    JOIN FINCAS F ON P.idFINCA = F.idFINCA
    WHERE fechaParte BETWEEN fechaInicio AND fechaFin
    GROUP BY MONTH(fechaParte), F.nombreFinca
    ORDER BY mes, F.nombreFinca;
END $$

# 5. Hacer un ranking con los vehículos que más partes tengan (por cantidad) en un rango de
# fechas.
DELIMITER $$
CREATE PROCEDURE `SP_RANKING_VEHICULOS` ( IN fechaInicio DATE, IN fechaFin DATE )
BEGIN
    SELECT  V.tipo, V.modelo, COUNT(*) AS cantidadPartes
    FROM VEHICULOS V
    JOIN VEHICULOS_POR_PARTES VP 
    ON V.idVEHICULO = VP.idVEHICULO AND V.patente = VP.patente
    JOIN PARTES P ON VP.idPARTE = P.idPARTE
    WHERE P.fechaParte BETWEEN fechaInicio AND fechaFin
    GROUP BY V.idVEHICULO, V.tipo, V.modelo
    ORDER BY cantidadPartes DESC;
END $$

-- 6. Hacer un ranking con los rubros que más recaudan (por importe) en un rango de fechas.

DELIMITER $$
CREATE PROCEDURE `PUNTO 6` (IN fecha_inicio DATE, IN fecha_fin DATE )
BEGIN
	SELECT R.rubro, SUM(M.monto) AS total_recaudado
	FROM RUBROS R
	INNER JOIN MOVIMIENTOS M
		ON R.idRUBRO = M.idRUBRO
	WHERE fecha BETWEEN fecha_inicio AND fecha_fin
	GROUP BY rubro
	ORDER BY total_recaudado DESC;
END$$

-- 7. Hacer un ranking con los rubros más recaudan (por cantidad) en un rango de fechas.

DELIMITER $$
CREATE PROCEDURE `PUNTO 7` (IN fecha_inicio DATE, IN fecha_fin DATE )
BEGIN
	SELECT R.rubro, COUNT(M.idMOVIMIENTO) AS cantidad_de_Movimientos
    FROM RUBROS R
    INNER JOIN MOVIMIENTOS M
		ON R.idRUBRO = M.idRUBRO
    WHERE fecha BETWEEN fecha_inicio AND fecha_fin
    GROUP BY R.rubro
    ORDER BY cantidad_de_Movimientos DESC; 
END$$

-- 8. Crear una vista con la funcionalidad del apartado 2.

CREATE VIEW `PUNTO 8` AS
	SELECT V.tipo, V.modelo, COUNT(*) AS cantidadPartes
    FROM VEHICULOS V
    JOIN VEHICULOS_POR_PARTES VP ON V.idVEHICULO = VP.idVEHICULO AND V.patente = VP.patente
    JOIN PARTES P ON VP.idPARTE = P.idPARTE
    GROUP BY V.idVEHICULO, V.tipo, V.modelo;

-- 9. Crear una copia de la tabla rubros, que además tenga una columna del tipo JSON para 
-- guardar los movimientos. Llenar esta tabla con los mismos datos del TP1 y resolver la
-- consulta: Dado un rubro listar todos los movimientos de ese rubro.

-- Crear una tabla temporal con los datos de la tabla MOVIMIENTOS guardados en formato JSON
	DROP TABLE IF EXISTS `LBD2024G06AGROSA`.`TEMP_JSON` ;
		CREATE TEMPORARY TABLE IF NOT EXISTS `LBD2024G06AGROSA`.`TEMP_JSON` (
			`idTEM_JSON` INT AUTO_INCREMENT PRIMARY KEY,
			jsonData JSON
	);
-- Insertar los datos de la tabla MOVIMIENTOS en la tabla temporal
	INSERT INTO `LBD2024G06AGROSA`.`TEMP_JSON` (jsonData)
	SELECT JSON_OBJECT(
		'tipoMovimiento', tipoMovimiento,
		'fecha', fecha,
		'monto', monto,
		'detalle', detalle,
		'estado', estado,
		'idRUBRO', idRUBRO
	)
	FROM MOVIMIENTOS;
-- Crear la copia de la tabla RUBROS 
	DROP TABLE IF EXISTS `LBD2024G06AGROSA`.`RUBROS_JSON` ;
	CREATE TABLE IF NOT EXISTS `LBD2024G06AGROSA`.`RUBROS_JSON` LIKE `LBD2024G06AGROSA`.`RUBROS` ;
-- Agregar la columna "movientos" tipo JSON
	ALTER TABLE `LBD2024G06AGROSA`.`RUBROS_JSON` 
	ADD COLUMN `movimientos` JSON;
-- Insertar los datos de ambas tablas, RUBROS y TEMP_JSON
	INSERT INTO `LBD2024G06AGROSA`.`RUBROS_JSON` ( `rubro`, `estado`, `movimientos`)
		SELECT rubro, estado, jsonData
		FROM RUBROS R
		INNER JOIN TEMP_JSON T
			ON R.idRUBRO = JSON_EXTRACT(jsonData, '$.idRUBRO');
-- Borrar la tabla temporal
    DROP TABLE IF EXISTS `TEMP_JSON`;

-- Inicio del SP
DELIMITER $$
CREATE PROCEDURE `PUNTO 9` (IN rubro VARCHAR(45))
BEGIN
    SELECT 
        RJ.rubro,
        JSON_UNQUOTE(JSON_EXTRACT(RJ.movimientos, '$.tipoMovimiento')) AS tipoMovimiento,
        JSON_UNQUOTE(JSON_EXTRACT(RJ.movimientos, '$.fecha')) AS fecha,
        JSON_UNQUOTE(JSON_EXTRACT(RJ.movimientos, '$.monto')) AS monto,
        JSON_UNQUOTE(JSON_EXTRACT(RJ.movimientos, '$.detalle')) AS detalle,
        JSON_UNQUOTE(JSON_EXTRACT(RJ.movimientos, '$.estado')) AS estado
    FROM RUBROS_JSON RJ
    WHERE RJ.rubro = rubro;
END$$


-- 10: Realizar una vista que considere importante para su modelo. También dejar escrito el enunciado de la misma.
-- Enunciado: Dado un empleado, mostrar las veces que trabajó como empleado, y operario en el último año

CREATE VIEW `PUNTO 10` AS
	SELECT E.idEMPLEADO,
		SUM(CASE WHEN L.rol = 'O' THEN 1 ELSE 0 END) AS Veces_Como_Operario,
		SUM(CASE WHEN L.rol = 'E' THEN 1 ELSE 0 END) AS Veces_Como_Empleado
		FROM  EMPLEADOS E
		INNER JOIN LINEAS_PARTES L
			ON E.idEMPLEADO=L.idEMPLEADO
		GROUP BY E.idEMPLEADO;

# LLAMADAS A LOS PROCEDIMIENTOS ALMACENADOS
CALL SP_LISTAR_FINCAS(27891234567, -35, -32, -60, -18);
CALL SP_PARTES_POR_VEHICULO();
CALL SP_DIFERENCIA_SUPERFICIE(2024, 5, 2025);
CALL SP_PARTES_POR_FINCA('2024-01-01', '2024-12-31');
CALL SP_RANKING_VEHICULOS('2024-01-01', '2024-12-31');
CALL `PUNTO 6` ('2024-01-01', '2024-12-31');
CALL `PUNTO 7` ('2024-01-01', '2024-12-31');
SELECT * FROM `PUNTO 8`;
CALL `PUNTO 9` ('venta');
SELECT * FROM `PUNTO 10`;