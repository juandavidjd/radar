SELECT * FROM (
  SELECT 0 AS digito, COUNT(*) AS n, MAX(fecha) AS max_f FROM todo_cuando_0_es
  UNION ALL SELECT 1, COUNT(*), MAX(fecha) FROM todo_cuando_1_es
  UNION ALL SELECT 2, COUNT(*), MAX(fecha) FROM todo_cuando_2_es
  UNION ALL SELECT 3, COUNT(*), MAX(fecha) FROM todo_cuando_3_es
  UNION ALL SELECT 4, COUNT(*), MAX(fecha) FROM todo_cuando_4_es
  UNION ALL SELECT 5, COUNT(*), MAX(fecha) FROM todo_cuando_5_es
  UNION ALL SELECT 6, COUNT(*), MAX(fecha) FROM todo_cuando_6_es
  UNION ALL SELECT 7, COUNT(*), MAX(fecha) FROM todo_cuando_7_es
  UNION ALL SELECT 8, COUNT(*), MAX(fecha) FROM todo_cuando_8_es
  UNION ALL SELECT 9, COUNT(*), MAX(fecha) FROM todo_cuando_9_es
) ORDER BY digito;
