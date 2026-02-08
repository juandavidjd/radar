-- filas que están en TRMA pero no machean en TCS (debería dar 0)
SELECT COUNT(*) AS sin_match
FROM todos_resumen_matriz_aslu a
LEFT JOIN todos_cuando_son b
  ON a.fecha=b.fecha AND a.numero=b.numero
WHERE b.fecha IS NULL;
