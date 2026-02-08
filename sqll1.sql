SELECT digito, COUNT(*) AS n, MAX(fecha) AS max_f
FROM todos_cuando_son
GROUP BY digito
ORDER BY digito;
