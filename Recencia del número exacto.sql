-- Recencia del número exacto (días desde su última aparición)
CREATE VIEW IF NOT EXISTS v_last_seen_exact AS
SELECT
    numero,
    CAST(julianday((SELECT MAX(fecha) FROM astro_luna)) - julianday(MAX(fecha)) AS INTEGER) AS dias_desde
FROM astro_luna
GROUP BY numero;
