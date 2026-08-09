USE Ventas_Tech_DB;
GO

-- CONSULTA 1 — Resumen ejecutivo mensual 

SELECT
MONTH(fecha_venta) AS mes,
SUM(cantidad*precio_unitario) AS total_facturado,
COUNT(*) AS cantidad_pedidos,
AVG(cantidad*precio_unitario) AS ticket_promedio
FROM dbo.ventas
GROUP BY MONTH (fecha_venta)
ORDER BY mes;

-- CONSULTA 2 — Ranking de productos

SELECT TOP 5
ID_producto,
SUM(cantidad) AS unidades_vendidas,
SUM(cantidad*precio_unitario) AS total_facturado
FROM dbo.ventas
GROUP BY ID_producto
ORDER BY total_facturado DESC;

-- CONSULTA 3 — Clientes recurrentes 

SELECT 
ID_cliente,
COUNT (*) AS cantidad_pedidos,
SUM (cantidad * precio_unitario) AS total_gastado
FROM dbo.ventas
GROUP BY ID_cliente
HAVING COUNT(*)>1
ORDER BY total_gastado DESC;

-- CONSULTA 4 — Meses por encima/por debajo del promedio

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CASE 
    WHEN SUM(cantidad * precio_unitario) > (
        SELECT AVG(total_mensual)
        FROM (
            SELECT 
                MONTH(fecha_venta) AS mes,
                SUM(cantidad * precio_unitario) AS total_mensual
            FROM dbo.ventas
            GROUP BY MONTH(fecha_venta)
        ) AS promedios
    )
    THEN 'Por encima'

    WHEN SUM(cantidad * precio_unitario) < (
        SELECT AVG(total_mensual)
        FROM (
            SELECT 
                MONTH(fecha_venta) AS mes,
                SUM(cantidad * precio_unitario) AS total_mensual
            FROM dbo.ventas
            GROUP BY MONTH(fecha_venta)
        ) AS promedios
    )
    THEN 'Por debajo'

    ELSE 'Igual al promedio'
END AS comparacion_promedio
FROM dbo.ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- HALLAZGOS:
--1: El producto 1 lidera el ranking de facturación con un total de $3600 (un 56% aproximado de la facturación total) y el producto 2 es el que más unidades vendió, con un total de 13 unidades, sin embargo ocupa el último lugar en el top 5 de facturación con $364
--2: Todos los clientes realizaron más de un pedido, siendo el cliente 1 el que tiene mayor gasto total con $2640.
--3: Todas las ventas corresponden al mes de marzo 2024, por lo que no se tienen datos de otros meses para poder comparar la evolución de la facturación mensual. 