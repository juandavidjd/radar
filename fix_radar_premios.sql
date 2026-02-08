------------------------------------------------------------------
-- C:\RadarPremios\scripts\fix_radar_premios.sql
-- Se ejecuta en modo seguro con apply_sql_safe.py
-- No incluye BEGIN/COMMIT/ROLLBACK/ATTACH/DETACH.
------------------------------------------------------------------

-- Índices de apoyo “por si acaso” (no-únicos)
CREATE INDEX IF NOT EXISTS idx_astro_luna_fecha ON astro_luna(fecha);
CREATE INDEX IF NOT EXISTS idx_matriz_aslu_fecha ON matriz_astro_luna(fecha);

-- Runs ya lo manejamos en fix_schema.py, pero dejamos esto por idempotencia:
CREATE INDEX IF NOT EXISTS idx_runs_gen_seed ON runs(gen, seed);
CREATE INDEX IF NOT EXISTS idx_runs_created_at ON runs(created_at);

-- (Opcional) índices ligeros por fecha en regionales
CREATE INDEX IF NOT EXISTS idx_boyaca_fecha     ON boyaca(fecha);
CREATE INDEX IF NOT EXISTS idx_huila_fecha      ON huila(fecha);
CREATE INDEX IF NOT EXISTS idx_manizales_fecha  ON manizales(fecha);
CREATE INDEX IF NOT EXISTS idx_medellin_fecha   ON medellin(fecha);
CREATE INDEX IF NOT EXISTS idx_quindio_fecha    ON quindio(fecha);
CREATE INDEX IF NOT EXISTS idx_tolima_fecha     ON tolima(fecha);

------------------------------------------------------------------
-- Fuera del SAVEPOINT (el helper lo ejecuta en autocommit):
PRAGMA optimize;
------------------------------------------------------------------
-- =========================================
-- Vistas estandarizadas: u,d,c,um por juego
-- Requisitos esperados en tablas base: fecha (TEXT o DATE), ganador (TEXT o INT de 4 dígitos)
-- Si tus columnas se llaman distinto (p.ej. 'numero'), los scripts Python hacen fallback automático.
-- =========================================

-- Helper: función segura para normalizar a 4 dígitos (como texto)
-- (No hay UDF aquí; resolvemos en SELECT con LPAD manual.)
-- Nota: SQLite no tiene LPAD nativa; se emula.
-- num_txt = substr('0000'||ganador, length('0000'||ganador)-3, 4)

DROP VIEW IF EXISTS boyaca_std;
CREATE VIEW IF NOT EXISTS boyaca_std AS
SELECT
  fecha,
  'boyaca' AS juego,
  CAST(substr('0000'||ganador, length('0000'||ganador)-3, 4) AS INT) AS num,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 4, 1) AS INT) AS u,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 3, 1) AS INT) AS d,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 2, 1) AS INT) AS c,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 1, 1) AS INT) AS um
FROM boyaca
WHERE length(substr('0000'||ganador, length('0000'||ganador)-3, 4)) = 4;

DROP VIEW IF EXISTS huila_std;
CREATE VIEW IF NOT EXISTS huila_std AS
SELECT
  fecha,
  'huila' AS juego,
  CAST(substr('0000'||ganador, length('0000'||ganador)-3, 4) AS INT) AS num,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 4, 1) AS INT) AS u,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 3, 1) AS INT) AS d,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 2, 1) AS INT) AS c,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 1, 1) AS INT) AS um
FROM huila
WHERE length(substr('0000'||ganador, length('0000'||ganador)-3, 4)) = 4;

DROP VIEW IF EXISTS manizales_std;
CREATE VIEW IF NOT EXISTS manizales_std AS
SELECT
  fecha,
  'manizales' AS juego,
  CAST(substr('0000'||ganador, length('0000'||ganador)-3, 4) AS INT) AS num,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 4, 1) AS INT) AS u,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 3, 1) AS INT) AS d,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 2, 1) AS INT) AS c,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 1, 1) AS INT) AS um
FROM manizales
WHERE length(substr('0000'||ganador, length('0000'||ganador)-3, 4)) = 4;

DROP VIEW IF EXISTS medellin_std;
CREATE VIEW IF NOT EXISTS medellin_std AS
SELECT
  fecha,
  'medellin' AS juego,
  CAST(substr('0000'||ganador, length('0000'||ganador)-3, 4) AS INT) AS num,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 4, 1) AS INT) AS u,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 3, 1) AS INT) AS d,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 2, 1) AS INT) AS c,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 1, 1) AS INT) AS um
FROM medellin
WHERE length(substr('0000'||ganador, length('0000'||ganador)-3, 4)) = 4;

DROP VIEW IF EXISTS quindio_std;
CREATE VIEW IF NOT EXISTS quindio_std AS
SELECT
  fecha,
  'quindio' AS juego,
  CAST(substr('0000'||ganador, length('0000'||ganador)-3, 4) AS INT) AS num,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 4, 1) AS INT) AS u,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 3, 1) AS INT) AS d,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 2, 1) AS INT) AS c,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 1, 1) AS INT) AS um
FROM quindio
WHERE length(substr('0000'||ganador, length('0000'||ganador)-3, 4)) = 4;

DROP VIEW IF EXISTS tolima_std;
CREATE VIEW IF NOT EXISTS tolima_std AS
SELECT
  fecha,
  'tolima' AS juego,
  CAST(substr('0000'||ganador, length('0000'||ganador)-3, 4) AS INT) AS num,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 4, 1) AS INT) AS u,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 3, 1) AS INT) AS d,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 2, 1) AS INT) AS c,
  CAST(substr(substr('0000'||ganador, length('0000'||ganador)-3, 4), 1, 1) AS INT) AS um
FROM tolima
WHERE length(substr('0000'||ganador, length('0000'||ganador)-3, 4)) = 4;

-- Ya tienes astro_luna_std (reporta "OK" en tu maintenance), lo dejamos igual.

-- =========================================
-- Índices sugeridos en tablas base (por fecha)
-- (Ignorados si ya existen)
-- =========================================
CREATE INDEX IF NOT EXISTS idx_boyaca_fecha ON boyaca(fecha);
CREATE INDEX IF NOT EXISTS idx_huila_fecha ON huila(fecha);
CREATE INDEX IF NOT EXISTS idx_manizales_fecha ON manizales(fecha);
CREATE INDEX IF NOT EXISTS idx_medellin_fecha ON medellin(fecha);
CREATE INDEX IF NOT EXISTS idx_quindio_fecha ON quindio(fecha);
CREATE INDEX IF NOT EXISTS idx_tolima_fecha ON tolima(fecha);

-- ===============================================================
-- ESTÁNDAR DE VISTAS *_std PARA EL PIPELINE (fecha, num, game)
-- Si una fuente no es de 4 dígitos (p.ej. Baloto), la vista expone
-- las columnas pero sin filas (WHERE 1=0) para no romper consultas.
-- ===============================================================

BEGIN;

-- ---------- Utilidad: dropear si existen ----------
DROP VIEW IF EXISTS astro_luna_std;
DROP VIEW IF EXISTS boyaca_std;
DROP VIEW IF EXISTS huila_std;
DROP VIEW IF EXISTS manizales_std;
DROP VIEW IF EXISTS medellin_std;
DROP VIEW IF EXISTS quindio_std;
DROP VIEW IF EXISTS tolima_std;
DROP VIEW IF EXISTS baloto_resultados_std;
DROP VIEW IF EXISTS revancha_resultados_std;

-- ===============================================================
-- ASTRO LUNA (4 dígitos)
-- Supone tabla base: astro_luna con columna de ganador de 4 dígitos
-- Si tu tabla usa otra columna (p.ej. 'numero'), cambia 'ganador' por la real.
-- ===============================================================
CREATE VIEW astro_luna_std AS
SELECT
    date(fecha)                           AS fecha,
    CAST(ganador AS TEXT)                 AS num,
    'astro_luna'                          AS game
FROM astro_luna
WHERE CAST(ganador AS TEXT) GLOB '[0-9][0-9][0-9][0-9]';

-- ===============================================================
-- LOTERÍAS REGIONALES (4 dígitos): boyaca, huila, manizales,
-- medellin, quindio, tolima
-- Supone columna 'ganador' de 4 dígitos. Ajusta si tu columna real
-- es 'numero' o 'premio' (solo cambiar el alias en SELECT).
-- ===============================================================
CREATE VIEW boyaca_std AS
SELECT date(fecha) AS fecha,
       CAST(ganador AS TEXT) AS num,
       'boyaca' AS game
FROM boyaca
WHERE CAST(ganador AS TEXT) GLOB '[0-9][0-9][0-9][0-9]';

CREATE VIEW huila_std AS
SELECT date(fecha) AS fecha,
       CAST(ganador AS TEXT) AS num,
       'huila' AS game
FROM huila
WHERE CAST(ganador AS TEXT) GLOB '[0-9][0-9][0-9][0-9]';

CREATE VIEW manizales_std AS
SELECT date(fecha) AS fecha,
       CAST(ganador AS TEXT) AS num,
       'manizales' AS game
FROM manizales
WHERE CAST(ganador AS TEXT) GLOB '[0-9][0-9][0-9][0-9]';

CREATE VIEW medellin_std AS
SELECT date(fecha) AS fecha,
       CAST(ganador AS TEXT) AS num,
       'medellin' AS game
FROM medellin
WHERE CAST(ganador AS TEXT) GLOB '[0-9][0-9][0-9][0-9]';

CREATE VIEW quindio_std AS
SELECT date(fecha) AS fecha,
       CAST(ganador AS TEXT) AS num,
       'quindio' AS game
FROM quindio
WHERE CAST(ganador AS TEXT) GLOB '[0-9][0-9][0-9][0-9]';

CREATE VIEW tolima_std AS
SELECT date(fecha) AS fecha,
       CAST(ganador AS TEXT) AS num,
       'tolima' AS game
FROM tolima
WHERE CAST(ganador AS TEXT) GLOB '[0-9][0-9][0-9][0-9]';

-- ===============================================================
-- BALOTO / REVANCHA (NO 4 dígitos) -> vistas “vacías” pero con
-- columnas estándar para no romper 'sanity_check' del pipeline.
-- Si más adelante quieres un estándar específico para 5+1 bolas,
-- se crea otro *_std_v2 con su propio consumidor.
-- ===============================================================
CREATE VIEW baloto_resultados_std AS
SELECT
    date(fecha)                 AS fecha,
    CAST(NULL AS TEXT)          AS num,
    'baloto_resultados'         AS game
FROM baloto_resultados
WHERE 1=0;  -- sin filas: no es juego de 4 dígitos

CREATE VIEW revancha_resultados_std AS
SELECT
    date(fecha)                 AS fecha,
    CAST(NULL AS TEXT)          AS num,
    'revancha_resultados'       AS game
FROM revancha_resultados
WHERE 1=0;  -- sin filas: no es juego de 4 dígitos

COMMIT;

