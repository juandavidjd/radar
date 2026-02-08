-- ============================================
-- ANALYTICS PACK (sobre todos_cuando_son)
-- Requiere: fecha en ISO (YYYY-MM-DD)
-- ============================================

-- 0) Calendario básico (día, mes, año, weekday)
CREATE VIEW IF NOT EXISTS v_cal AS
SELECT
  fecha,
  CAST(STRFTIME('%Y', fecha) AS INT)  AS anio,
  CAST(STRFTIME('%m', fecha) AS INT)  AS mes,
  CAST(STRFTIME('%d', fecha) AS INT)  AS dia,
  CAST(STRFTIME('%w', fecha) AS INT)  AS wday -- 0=Domingo ... 6=Sábado
FROM (SELECT DISTINCT fecha FROM todos_cuando_son);

-- 1) Conteo diario por dígito y posición
CREATE VIEW IF NOT EXISTS v_digit_counts_daily AS
WITH base AS (
  SELECT fecha, digito, posicion, COUNT(*) AS n
  FROM todos_cuando_son
  GROUP BY fecha, digito, posicion
)
SELECT b.*, vc.anio, vc.mes, vc.wday
FROM base b
JOIN v_cal vc USING(fecha);

-- 2) Conteo diario por dígito (todas las posiciones)
CREATE VIEW IF NOT EXISTS v_digit_counts_daily_allpos AS
WITH base AS (
  SELECT fecha, digito, COUNT(*) AS n
  FROM todos_cuando_son
  GROUP BY fecha, digito
)
SELECT b.*, vc.anio, vc.mes, vc.wday
FROM base b
JOIN v_cal vc USING(fecha);

-- 3) Ventanas móviles 7/30/90 días por dígito
CREATE VIEW IF NOT EXISTS v_digit_rolling AS
WITH base AS (
  SELECT fecha, digito, COUNT(*) AS n
  FROM todos_cuando_son
  GROUP BY fecha, digito
),
w AS (
  SELECT
    digito,
    fecha,
    n,
    SUM(n) OVER (PARTITION BY digito ORDER BY fecha ROWS BETWEEN 6 PRECEDING  AND CURRENT ROW) AS n_7d,
    SUM(n) OVER (PARTITION BY digito ORDER BY fecha ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS n_30d,
    SUM(n) OVER (PARTITION BY digito ORDER BY fecha ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS n_90d
  FROM base
)
SELECT w.*, vc.anio, vc.mes, vc.wday
FROM w
JOIN v_cal vc USING(fecha);

-- 4) Promedio histórico por dígito y z-score simple (sobre los últimos 30 días)
-- Nota: z-score aquí es “rápido”: (n_30d - mean30) / sqrt(mean30) asumiendo Poisson.
CREATE VIEW IF NOT EXISTS v_digit_hotcold AS
WITH longrun AS (
  SELECT digito, AVG(n) AS mu_diaria
  FROM v_digit_counts_daily_allpos
  GROUP BY digito
),
roll AS (
  SELECT d.digito, d.fecha, d.n,
         d.n_7d, d.n_30d, d.n_90d
  FROM v_digit_rolling d
),
calc AS (
  SELECT
    r.*,
    lr.mu_diaria,
    CASE WHEN lr.mu_diaria>0 THEN (r.n_30d - 30*lr.mu_diaria)/SQRT(30*lr.mu_diaria) END AS z30
  FROM roll r
  JOIN longrun lr USING(digito)
)
SELECT * FROM calc;

-- 5) Última aparición por dígito y por dígito+posición
CREATE VIEW IF NOT EXISTS v_last_seen_digit AS
SELECT digito, MAX(fecha) AS ultima_fecha
FROM todos_cuando_son
GROUP BY digito;

CREATE VIEW IF NOT EXISTS v_last_seen_digit_pos AS
SELECT digito, posicion, MAX(fecha) AS ultima_fecha
FROM todos_cuando_son
GROUP BY digito, posicion;

-- 6) Racha desde última aparición (por dígito)
-- “racha_sin_aparecer_dias” = días desde la última fecha hasta la max(fecha) del dataset
CREATE VIEW IF NOT EXISTS v_digit_streaks AS
WITH lim AS (SELECT MAX(fecha) AS max_f FROM todos_cuando_son)
SELECT
  l.digito,
  l.ultima_fecha,
  (JULIANDAY(lim.max_f) - JULIANDAY(l.ultima_fecha)) AS racha_sin_aparecer_dias
FROM v_last_seen_digit l, lim;

-- 7) Co-ocurrencia de dígitos dentro del mismo número (pares de posiciones distintas)
CREATE VIEW IF NOT EXISTS v_digit_pairs AS
SELECT
  a.fecha,
  a.numero,
  a.digito AS digito_a,
  b.digito AS digito_b,
  a.posicion AS pos_a,
  b.posicion AS pos_b
FROM todos_cuando_son a
JOIN todos_cuando_son b
  ON a.fecha=b.fecha AND a.numero=b.numero AND a.posicion < b.posicion;

-- 8) Persistencia día-a-día del mismo número (repetición exacta)
CREATE VIEW IF NOT EXISTS v_num_persistencia AS
WITH base AS (
  SELECT fecha, numero,
         LAG(numero) OVER (ORDER BY fecha) AS numero_prev,
         LAG(fecha)  OVER (ORDER BY fecha) AS fecha_prev
  FROM (SELECT DISTINCT fecha, numero FROM todos_cuando_son)
)
SELECT
  fecha,
  numero,
  fecha_prev,
  numero_prev,
  CASE WHEN numero = numero_prev AND fecha_prev IS NOT NULL THEN 1 ELSE 0 END AS repite_vs_dia_anterior
FROM base;

-- 9) Efectos de calendario (weekday / mes) por dígito
CREATE VIEW IF NOT EXISTS v_digit_calendar_effects AS
SELECT
  v.wday,
  v.mes,
  t.digito,
  COUNT(*) AS n
FROM todos_cuando_son t
JOIN v_cal v USING(fecha)
GROUP BY v.wday, v.mes, t.digito;
