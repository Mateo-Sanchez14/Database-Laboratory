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

CREATE PROCEDURE `SP_LISTAR_FINCAS` (IN cuil BIGINT,IN `latitud1` FLOAT, IN `latitud2` FLOAT, IN `longitud1` FLOAT, IN `longitud2` FLOAT)
BEGIN
    SELECT P.apellidos, P.nombres, F.nombreFinca, F.latitud, F.longitud
    FROM FINCAS F
    JOIN PROPIETARIOS P ON F.cuilPROPIETARIO = P.cuil
    WHERE P.cuil = cuil AND F.latitud BETWEEN latitud1 AND latitud2 AND F.longitud BETWEEN longitud1 AND longitud2
    ORDER BY F.nombreFinca;
END;


# 2. Realizar un listado de cantidad de partes agrupadas por vehículos.
CREATE PROCEDURE `SP_PARTES_POR_VEHICULO` ()
BEGIN
    SELECT V.tipo, V.modelo, COUNT(*) AS cantidadPartes
    FROM VEHICULOS V
    JOIN VEHICULOS_POR_PARTES VP ON V.idVEHICULO = VP.idVEHICULO AND V.patente = VP.patente
    JOIN PARTES P ON VP.idPARTE = P.idPARTE
    GROUP BY V.idVEHICULO, V.tipo, V.modelo;
END ;

# 3. Dado un año y mes, mostrar la diferencia entre el total de superficie de todos los partes
# de los vehículoe en ese mes, con el mismo mes de otro año también dado.
CREATE PROCEDURE `SP_DIFERENCIA_SUPERFICIE` ( IN anio1 INT, IN mes INT, IN anio2 INT)
BEGIN
    SELECT SUM(CASE WHEN YEAR(fechaParte) = anio1 AND MONTH(fechaParte) = mes THEN superficie ELSE 0 END) -
           SUM(CASE WHEN YEAR(fechaParte) = anio2 AND MONTH(fechaParte) = mes THEN superficie ELSE 0 END) AS diferencia
    FROM PARTES;
END ;

# 4. Dado un rango de fechas, mostrar mes a mes la cantidad de partes por finca. El formato
# deberá ser: més, finca, total de partes

CREATE PROCEDURE `SP_PARTES_POR_FINCA` ( IN fechaInicio DATE, IN fechaFin DATE )
BEGIN
    SELECT MONTH(fechaParte) AS mes, F.nombreFinca, COUNT(*) AS totalPartes
    FROM PARTES P
    JOIN FINCAS F ON P.idFINCA = F.idFINCA
    WHERE fechaParte BETWEEN fechaInicio AND fechaFin
    GROUP BY MONTH(fechaParte), F.nombreFinca
    ORDER BY mes, F.nombreFinca;
END ;

# 5. Hacer un ranking con los vehículos que más partes tengan (por cantidad) en un rango de
# fechas.

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
END ;


# LLAMADAS A LOS PROCEDIMIENTOS ALMACENADOS
CALL SP_LISTAR_FINCAS(27891234567, -35, -32, -60, -18);
CALL SP_PARTES_POR_VEHICULO();
CALL SP_DIFERENCIA_SUPERFICIE(2024, 5, 2025);
CALL SP_PARTES_POR_FINCA('2024-01-01', '2024-12-31');
CALL SP_RANKING_VEHICULOS('2024-01-01', '2024-12-31');



