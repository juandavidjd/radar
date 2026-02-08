DROP VIEW IF EXISTS v_digit_hotcold;
CREATE VIEW v_digit_hotcold AS
WITH last_date AS (
  SELECT MAX(date(fecha)) AS max_f FROM todos_cuando_son
),
win AS (
  SELECT * FROM todos_cuando_son
  WHERE date(fecha) >= date((SELECT max_f FROM last_date), '-30 day')
),
agg AS (
  SELECT digito, COUNT(*) AS cnt
  FROM win
  GROUP BY digito
),
stats AS (
  SELECT COALESCE(MIN(cnt),0) AS mn,
         COALESCE(MAX(cnt),0) AS mx
  FROM agg
)
SELECT a.digito,
       COALESCE(a.cnt,0) AS cnt,
       CASE
         WHEN s.mx = s.mn THEN 0.5
         ELSE (a.cnt - s.mn) * 1.0 / (s.mx - s.mn)
       END AS hotcold_norm
FROM agg a CROSS JOIN stats s;
