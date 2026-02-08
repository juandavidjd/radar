SELECT fecha, numero
FROM todos_cuando_son
WHERE posicion IN ('um','u') AND digito = 5
GROUP BY fecha, numero
HAVING COUNT(DISTINCT posicion) = 2;
