CREATE VIEW IF NOT EXISTS v_cal AS
SELECT
  fecha,
  CAST(STRFTIME('%Y', fecha) AS INT)  AS anio,
  CAST(STRFTIME('%m', fecha) AS INT)  AS mes,
  CAST(STRFTIME('%d', fecha) AS INT)  AS dia,
  CAST(STRFTIME('%w', fecha) AS INT)  AS wday -- 0=Domingo ... 6=Sábado
FROM (SELECT DISTINCT fecha FROM todos_cuando_son);