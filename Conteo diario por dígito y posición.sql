CREATE VIEW IF NOT EXISTS v_digit_counts_daily AS
WITH base AS (
  SELECT fecha, digito, posicion, COUNT(*) AS n
  FROM todos_cuando_son
  GROUP BY fecha, digito, posicion
)
SELECT b.*, vc.anio, vc.mes, vc.wday
FROM base b
JOIN v_cal vc USING(fecha);
