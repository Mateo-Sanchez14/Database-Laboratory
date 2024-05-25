# Agregar todo lo que necesitamos arriba.

# 1. Dado un propietario, listar todas sus fincas entre ciertas latitudes y longitudes dadas.


# 2. Realizar un listado de cantidad de partes agrupadas por vehículos.
# 3. Dado un año y mes, mostrar la diferencia entre el total de superficie de todos los partes
# de los vehículoe en ese mes, con el mismo mes de otro año también dado.
# 4. Dado un rango de fechas, mostrar mes a mes la cantidad de partes por finca. El formato
# deberá ser: més, finca, total de partes
# 5. Hacer un ranking con los vehículos que más partes tengan (por cantidad) en un rango de
# fechas.
# 6. Hacer un ranking con los rubros que más recaudan (por importe) en un rango de fechas.
# 7. Hacer un ranking con los productos más recaudan (por cantidad) en un rango de fechas.
# 8. Crear una vista con la funcionalidad del apartado 2.
# 9. Crear una copia de la tabla rubros, que además tenga una columna del tipo JSON para
# guardar los movimientos. Llenar esta tabla con los mismos datos del TP1 y resolver la
# consulta: Dado un rubro listar todos los movimientos de ese rubro.
# 10: Realizar una vista que considere importante para su modelo. También dejar escrito el
# enunciado de la misma.


# 1. Dado un propietario, listar todas sus fincas entre ciertas latitudes y longitudes dadas.

SELECT P.nombres, P.apellidos, F.nombreFinca, F.latitud, F.longitud
FROM PROPIETARIOS P
JOIN FINCAS F ON P.cuil = F.cuilPROPIETARIO
WHERE F.latitud BETWEEN -34.5 AND -34.0
AND F.longitud BETWEEN -52.0 AND -51.0;

# Realizar un SP con el SQL anterior

DELIMITER //

CREATE PROCEDURE `LBD2024G06AGROSA`.`SP_LISTAR_FINCAS` (IN `latitud1` FLOAT, IN `latitud2` FLOAT, IN `longitud1` FLOAT, IN `longitud2` FLOAT)
BEGIN
    SELECT P.nombres, P.apellidos, F.nombreFinca, F.latitud, F.longitud
    FROM PROPIETARIOS P
    JOIN FINCAS F ON P.cuil = F.cuilPROPIETARIO
    WHERE F.latitud BETWEEN latitud1 AND latitud2
    AND F.longitud BETWEEN longitud1 AND longitud2;
END //

DELIMITER ;

# Llama al SP

CALL `LBD2024G06AGROSA`.`SP_LISTAR_FINCAS`(-34.5, -34.0, -52.0, -51.0);

# 2. Realizar un listado de cantidad de partes agrupadas por vehículos.
CREATE PROCEDURE `LBD2024G06AGROSA`.`SP_PARTES_POR_VEHICULO` ( IN idVEHICULO INT )
BEGIN
    SELECT V.idVEHICULO, V.tipo, V.modelo, COUNT(*) AS cantidadPartes
    FROM VEHICULOS V
    JOIN VEHICULOS_POR_PARTES VP ON V.idVEHICULO = VP.idVEHICULO
    JOIN PARTES P ON VP.idPARTE = P.idPARTE
    WHERE V.idVEHICULO = idVEHICULO
    GROUP BY V.idVEHICULO, V.tipo, V.modelo;
END ;

# 3. Dado un año y mes, mostrar la diferencia entre el total de superficie de todos los partes
# de los vehículoe en ese mes, con el mismo mes de otro año también dado.
CREATE PROCEDURE `LBD2024G06AGROSA`.`SP_DIFERENCIA_SUPERFICIE` ( IN anio1 INT, IN mes1 INT, IN anio2 INT, IN mes2 INT )
BEGIN
    SELECT SUM(CASE WHEN YEAR(fechaParte) = anio1 AND MONTH(fechaParte) = mes1 THEN superficie ELSE 0 END) -
           SUM(CASE WHEN YEAR(fechaParte) = anio2 AND MONTH(fechaParte) = mes2 THEN superficie ELSE 0 END) AS diferencia
    FROM PARTES;
END ;

# 4. Dado un rango de fechas, mostrar mes a mes la cantidad de partes por finca. El formato
# deberá ser: més, finca, total de partes

CREATE PROCEDURE `LBD2024G06AGROSA`.`SP_PARTES_POR_FINCA` ( IN fechaInicio DATE, IN fechaFin DATE )
BEGIN
    SELECT MONTH(fechaParte) AS mes, F.nombreFinca, COUNT(*) AS totalPartes
    FROM PARTES P
    JOIN FINCAS F ON P.idFINCA = F.idFINCA
    WHERE fechaParte BETWEEN fechaInicio AND fechaFin
    GROUP BY MONTH(fechaParte), F.nombreFinca;
END ;

# 5. Hacer un ranking con los vehículos que más partes tengan (por cantidad) en un rango de
# fechas.

CREATE PROCEDURE `LBD2024G06AGROSA`.`SP_RANKING_VEHICULOS` ( IN fechaInicio DATE, IN fechaFin DATE )
BEGIN
    SELECT V.idVEHICULO, V.tipo, V.modelo, COUNT(*) AS cantidadPartes
    FROM VEHICULOS V
    JOIN VEHICULOS_POR_PARTES VP ON V.idVEHICULO = VP.idVEHICULO
    JOIN PARTES P ON VP.idPARTE = P.idPARTE
    WHERE P.fechaParte BETWEEN fechaInicio AND fechaFin
    GROUP BY V.idVEHICULO, V.tipo, V.modelo
    ORDER BY cantidadPartes DESC;
END ;





