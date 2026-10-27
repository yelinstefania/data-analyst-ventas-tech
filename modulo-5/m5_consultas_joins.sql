-- =====================================================================
-- Pre-entrega 5: Consultas con JOINs
-- Proyecto: RetailPro | Base de datos: Ventas_Tech_DB (SQL Server)
-- Tablas: ventas, clientes, productos, categorias
-- =====================================================================

USE Ventas_Tech_DB;
GO

-- ---------------------------------------------------------------------
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Proposito: una sola fila por venta con cliente, ciudad, producto y
-- categoria. Es la fuente de datos principal para Power BI.
-- ---------------------------------------------------------------------
SELECT
    v.fecha_venta,
    v.id_cliente,
    c.nombre                            AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario      AS total_venta
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
GO
-- Hallazgo: la vista devuelve las 10 ventas, asi que no se pierde ninguna
-- al cruzar las tablas. Computacion concentra 4950 de los 6444 facturados (77%).

-- ---------------------------------------------------------------------
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Proposito: detectar clientes registrados que nunca compraron, para que
-- CRM los contacte.
-- ---------------------------------------------------------------------
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO
-- Hallazgo: 0 de los 5 clientes registrados nunca compraron; todos compraron
-- al menos una vez, por lo que CRM no tiene inactivos para contactar y puede
-- enfocarse en fomentar la recompra.

-- ---------------------------------------------------------------------
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Proposito: identificar articulos del catalogo sin movimiento, para que
-- el area de producto revise su stock o su precio.
-- ---------------------------------------------------------------------
SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v       ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL;
GO
-- Hallazgo: 0 de los 6 productos del catalogo estan sin ventas; todos tuvieron
-- movimiento, asi que producto no tiene articulos para descontinuar por ahora.

-- ---------------------------------------------------------------------
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Proposito: comparar el total vendido en dos periodos del mes. La columna
-- canal es un valor fijo que se crea en cada SELECT.
-- ---------------------------------------------------------------------
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Periodo 1 (5-9 mar)' AS canal
    FROM ventas
    WHERE fecha_venta < '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Periodo 2 (10-15 mar)' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-10'
) AS consolidado
GROUP BY canal;
GO
-- Hallazgo: el primer periodo factura 3230 y el segundo 3214; el reparto es
-- casi parejo y entre los dos suman los 6444 totales, sin ventas repetidas.
