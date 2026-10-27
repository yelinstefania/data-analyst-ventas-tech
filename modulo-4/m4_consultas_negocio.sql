-- =====================================================================
-- Pre-entrega 4: Consultas SQL de negocio
-- Proyecto: RetailPro | Base de datos: Ventas_Tech_DB (SQL Server)
-- Tabla utilizada: ventas (id_cliente, id_producto, cantidad,
--                          precio_unitario, fecha_venta)
-- Total facturado = cantidad * precio_unitario
-- =====================================================================

USE Ventas_Tech_DB;
GO

-- ---------------------------------------------------------------------
-- Consulta 1 - Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes
-- ---------------------------------------------------------------------
SELECT
    MONTH(fecha_venta)                          AS mes,
    SUM(cantidad * precio_unitario)             AS total_facturado,
    COUNT(*)                                    AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)             AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

-- ---------------------------------------------------------------------
-- Consulta 2 - Ranking de productos
-- Top 5 de id_producto por total facturado, con unidades vendidas
-- ---------------------------------------------------------------------
SELECT TOP 5
    id_producto,
    SUM(cantidad)                               AS unidades_vendidas,
    SUM(cantidad * precio_unitario)             AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO

-- ---------------------------------------------------------------------
-- Consulta 3 - Clientes recurrentes
-- id_cliente con más de un pedido, con cantidad de pedidos y total gastado
-- ---------------------------------------------------------------------
SELECT
    id_cliente,
    COUNT(*)                                    AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)             AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

-- ---------------------------------------------------------------------
-- Consulta 4 - Meses por encima / por debajo del promedio
-- Total facturado por mes, etiquetado respecto del promedio mensual general
-- (el promedio mensual general es el promedio de los totales mensuales)
-- ---------------------------------------------------------------------
WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta)                      AS mes,
        SUM(cantidad * precio_unitario)         AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_mensual)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END                                         AS posicion_vs_promedio
FROM facturacion_mensual
ORDER BY mes;
GO

-- =====================================================================
-- Hallazgos
-- =====================================================================
-- 1. El producto 1 concentra el 56% de la facturacion total (3600 de
--    6444) con solo 3 unidades vendidas.
-- 2. El producto 2 es el que mas unidades vende (13) pero queda quinto
--    en el ranking por facturacion (364), por su precio unitario bajo.
-- 3. Los 5 clientes son recurrentes (2 pedidos cada uno); el cliente 1
--    es el que mas gasto (2640) y el cliente 4 el que menos (510).
