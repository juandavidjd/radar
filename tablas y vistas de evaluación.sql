-- === 1. Tablas de logging ===
CREATE TABLE IF NOT EXISTS rp_runs (
  run_id       INTEGER PRIMARY KEY AUTOINCREMENT,
  ts_utc       TEXT NOT NULL,          -- timestamp de la corrida (UTC o local, define tu script)
  seed         INTEGER,
  gen          INTEGER,
  top_n        INTEGER,
  shortlist_n  INTEGER,
  w_hotcold    REAL,
  w_cal        REAL,
  w_dp         REAL,
  w_exact      REAL,
  cap_digitpos INTEGER,
  cap_exact    INTEGER,
  export_top   TEXT,
  export_all   TEXT,
  report_html  TEXT,
  extra_json   TEXT                    -- opcional: parámetros/flags en JSON
);

CREATE TABLE IF NOT EXISTS rp_predictions (
  run_id   INTEGER NOT NULL,
  rank     INTEGER NOT NULL,           -- 1..N del TOP/shortlist
  numero   TEXT    NOT NULL,           -- "NNNN"
  score    REAL,
  hotcold  REAL,
  cal      REAL,
  dp       REAL,
  exact    REAL,
  patt_adj REAL,
  signo_pred TEXT,                     -- si más adelante predices signo, lo guardas aquí
  PRIMARY KEY (run_id, rank),
  FOREIGN KEY (run_id) REFERENCES rp_runs(run_id) ON DELETE CASCADE
);

-- === 2. Vista que vincula cada run con su "próximo sorteo" ===
-- Toma para cada run la primera fecha en astro_luna con fecha >= date(ts_utc).
CREATE VIEW IF NOT EXISTS v_run_target AS
WITH rt AS (
  SELECT
    r.run_id,
    r.ts_utc,
    (SELECT MIN(fecha) FROM astro_luna a WHERE date(a.fecha) >= date(r.ts_utc)) AS target_fecha
  FROM rp_runs r
)
SELECT * FROM rt;

-- === 3. Vista de evaluación por run vs resultado real ===
-- Empareja el run con el sorteo target y calcula aciertos/rasgos básicos.
CREATE VIEW IF NOT EXISTS v_run_eval AS
WITH tgt AS (
  SELECT rt.run_id, rt.target_fecha, a.numero AS numero_ganador, a.signo
  FROM v_run_target rt
  LEFT JOIN astro_luna a ON a.fecha = rt.target_fecha
),
px AS (
  SELECT
    p.run_id, p.rank, p.numero AS candidato, p.score, p.hotcold, p.cal, p.dp, p.exact, p.patt_adj
  FROM rp_predictions p
)
SELECT
  t.run_id,
  t.target_fecha,
  t.numero_ganador,
  t.signo,
  px.rank,
  px.candidato,
  px.score,
  -- métricas:
  CASE WHEN t.numero_ganador = px.candidato THEN 1 ELSE 0 END AS exact_hit,
  -- coincidencias por dígito sin considerar posición:
  (SELECT COUNT(*)
     FROM (SELECT substr(t.numero_ganador,1,1) d UNION ALL
           SELECT substr(t.numero_ganador,2,1)  UNION ALL
           SELECT substr(t.numero_ganador,3,1)  UNION ALL
           SELECT substr(t.numero_ganador,4,1)
     ) g
     JOIN (SELECT substr(px.candidato,1,1) d UNION ALL
           SELECT substr(px.candidato,2,1)  UNION ALL
           SELECT substr(px.candidato,3,1)  UNION ALL
           SELECT substr(px.candidato,4,1)
     ) c USING (d)
  ) AS shared_digits,
  -- coincidencias por posición (um,c,d,u):
  (CASE WHEN substr(t.numero_ganador,1,1)=substr(px.candidato,1,1) THEN 1 ELSE 0 END +
   CASE WHEN substr(t.numero_ganador,2,1)=substr(px.candidato,2,1) THEN 1 ELSE 0 END +
   CASE WHEN substr(t.numero_ganador,3,1)=substr(px.candidato,3,1) THEN 1 ELSE 0 END +
   CASE WHEN substr(t.numero_ganador,4,1)=substr(px.candidato,4,1) THEN 1 ELSE 0 END
  ) AS pos_matches
FROM tgt t
JOIN px ON px.run_id = t.run_id;

-- === 4. Resumen por run (quién pegó, cuántos cerca, etc.) ===
CREATE VIEW IF NOT EXISTS v_run_eval_summary AS
SELECT
  run_id,
  target_fecha,
  numero_ganador,
  signo,
  MAX(CASE WHEN rank=1 THEN candidato END) AS top1,
  MAX(CASE WHEN rank=1 THEN exact_hit END) AS top1_exact,
  SUM(exact_hit) AS total_exact_hits,
  MAX(shared_digits) AS best_shared_digits,
  MAX(pos_matches) AS best_pos_matches
FROM v_run_eval
GROUP BY run_id, target_fecha, numero_ganador, signo;
