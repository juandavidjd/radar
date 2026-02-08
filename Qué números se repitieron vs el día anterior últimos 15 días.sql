SELECT *
FROM v_num_persistencia
WHERE repite_vs_dia_anterior = 1
ORDER BY fecha DESC
LIMIT 50;
