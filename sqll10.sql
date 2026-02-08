SELECT fecha, numero
FROM todos_cuando_son
WHERE (posicion IN ('c','d')) AND digito = 7
GROUP BY fecha, numero
HAVING COUNT(DISTINCT posicion) = 2;
