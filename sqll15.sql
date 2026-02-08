PRAGMA integrity_check;                      -- 1) Integridad general
SELECT MIN(fecha), MAX(fecha) FROM astro_luna; -- 2) Rango
SELECT fecha FROM astro_luna
GROUP BY fecha, numero HAVING COUNT(*) > 1;    -- 3) Duplicados (debe dar 0 filas)
SELECT COUNT(*) FROM todo;                      -- 4) Vista responde
