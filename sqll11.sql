SELECT fecha, numero
FROM todos_cuando_son
WHERE digito = 0
GROUP BY fecha, numero
HAVING COUNT(DISTINCT posicion) = 4;
