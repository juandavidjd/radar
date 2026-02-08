-- create_analytics.sql
-- Vistas utilitarias para análisis rápido en Astro Luna

-- 1) Hot/Cold 30 y 120 draws por dígito y posición
DROP VIEW IF EXISTS v_digit_hotcold;
CREATE VIEW v_digit_hotcold AS
WITH ultimos AS (
    SELECT *
    FROM astro_luna
    WHERE fecha >= date((SELECT MAX(fecha) FROM astro_luna), '-120 day')
),
numeros AS (
    SELECT
        fecha,
        substr(numero, 1, 1) AS umil,
        substr(numero, 2, 1) AS cent,
        substr(numero, 3, 1) AS dec,
        substr(numero, 4, 1) AS unid
    FROM ultimos
)
SELECT
    digito,
    posicion,
    COUNT(*) AS freq_120,
    SUM(CASE WHEN fecha >= date((SELECT MAX(fecha) FROM astro_luna), '-30 day') THEN 1 ELSE 0 END) AS freq_30
FROM (
    SELECT fecha, umil AS digito, 'UM' AS posicion FROM numeros
    UNION ALL
    SELECT fecha, cent, 'C' FROM numeros
    UNION ALL
    SELECT fecha, dec, 'D' FROM numeros
    UNION ALL
    SELECT fecha, unid, 'U' FROM numeros
)
GROUP BY digito, posicion;

-- 2) Recencia por dígito+posición (30 días)
DROP VIEW IF EXISTS v_last_seen_digit_pos;
CREATE VIEW v_last_seen_digit_pos AS
WITH pos AS (
    SELECT
        substr(numero, 1, 1) AS umil,
        substr(numero, 2, 1) AS cent,
        substr(numero, 3, 1) AS dec,
        substr(numero, 4, 1) AS unid,
        fecha
    FROM astro_luna
)
SELECT
    digito,
    posicion,
    julianday((SELECT MAX(fecha) FROM astro_luna)) - julianday(MAX(fecha)) AS dias_desde
FROM (
    SELECT fecha, umil AS digito, 'UM' AS posicion FROM pos
    UNION ALL
    SELECT fecha, cent, 'C' FROM pos
    UNION ALL
    SELECT fecha, dec, 'D' FROM pos
    UNION ALL
    SELECT fecha, unid, 'U' FROM pos
)
GROUP BY digito, posicion;

-- 3) Recencia del número exacto (180 días)
DROP VIEW IF EXISTS v_last_seen_exact;
CREATE VIEW v_last_seen_exact AS
SELECT
    numero,
    julianday((SELECT MAX(fecha) FROM astro_luna)) - julianday(MAX(fecha)) AS dias_desde
FROM astro_luna
GROUP BY numero;
