-- ==========================================
-- 1) Bloque seguro (no usa BEGIN/COMMIT)
-- ==========================================
SAVEPOINT fix_update;

-- === Diagnóstico previo ===
SELECT 'ANTES astro' AS obj, COUNT(*) n, MAX(fecha) max_f FROM astro_luna;
SELECT 'ANTES matriz', COUNT(*), MAX(fecha) FROM matriz_astro_luna;
SELECT 'ANTES todos_resumen', COUNT(*), MAX(fecha) FROM todos_resumen_matriz_aslu;

-- ==========================================
-- 2) Normalizar fechas DD/MM/YYYY -> YYYY-MM-DD
--    (idempotente: solo toca valores con barras)
-- ==========================================
UPDATE astro_luna
SET fecha = CASE
  WHEN fecha GLOB '??/??/????'
    THEN SUBSTR(fecha,7,4) || '-' || SUBSTR(fecha,4,2) || '-' || SUBSTR(fecha,1,2)
  ELSE fecha
END;

UPDATE matriz_astro_luna
SET fecha = CASE
  WHEN fecha GLOB '??/??/????'
    THEN SUBSTR(fecha,7,4) || '-' || SUBSTR(fecha,4,2) || '-' || SUBSTR(fecha,1,2)
  ELSE fecha
END;

UPDATE todos_resumen_matriz_aslu
SET fecha = CASE
  WHEN fecha GLOB '??/??/????'
    THEN SUBSTR(fecha,7,4) || '-' || SUBSTR(fecha,4,2) || '-' || SUBSTR(fecha,1,2)
  ELSE fecha
END;

-- Índices por rendimiento (no fallan si ya existen)
CREATE INDEX IF NOT EXISTS idx_astro_luna_fecha       ON astro_luna(fecha);
CREATE INDEX IF NOT EXISTS idx_matriz_aslu_fecha      ON matriz_astro_luna(fecha);
CREATE INDEX IF NOT EXISTS idx_todos_resumen_fecha    ON todos_resumen_matriz_aslu(fecha);

-- Confirmar este bloque
RELEASE fix_update;

-- ==========================================
-- 3) (Opcional) Asegurar la vista `todo` con LEFT JOIN
--    SQLite no tiene OR REPLACE para VIEW: se hace DROP + CREATE
-- ==========================================
DROP VIEW IF EXISTS todo;

CREATE VIEW todo AS
SELECT *
FROM todos_resumen_matriz_aslu AS a
LEFT JOIN todos_cuando_son AS b
  ON a.fecha = b.fecha
 AND a.numero = b.numero;

-- ==========================================
-- 4) Verificación rápida
-- ==========================================
SELECT 'DESPUES astro' AS obj, COUNT(*) n, MAX(fecha) max_f FROM astro_luna;
SELECT 'DESPUES matriz', COUNT(*), MAX(fecha) FROM matriz_astro_luna;
SELECT 'DESPUES todos_resumen', COUNT(*), MAX(fecha) FROM todos_resumen_matriz_aslu;

-- Últimas fechas (ya deben ordenar bien en ISO)
SELECT DISTINCT fecha FROM matriz_astro_luna ORDER BY fecha DESC LIMIT 20;
SELECT DISTINCT fecha FROM todo               ORDER BY fecha DESC LIMIT 20;

-- Chequeos de conteos clave
SELECT 'astro_luna' obj, COUNT(*) n, MAX(fecha) max_f FROM astro_luna
UNION ALL
SELECT 'matriz_astro_luna', COUNT(*), MAX(fecha) FROM matriz_astro_luna
UNION ALL
SELECT 'todos_resumen_matriz_aslu', COUNT(*), MAX(fecha) FROM todos_resumen_matriz_aslu
UNION ALL
SELECT 'todo(view)', COUNT(*), MAX(fecha) FROM todo;
