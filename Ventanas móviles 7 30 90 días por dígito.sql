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