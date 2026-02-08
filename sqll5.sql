-- 1) El conteo de la vista 'todo' debe ser 4x el resumen
SELECT
  (SELECT COUNT(*) FROM todos_resumen_matriz_aslu)            AS n_resumen,
  (SELECT COUNT(*) FROM todo)                                 AS n_todo,
  (SELECT COUNT(*)*4 FROM todos_resumen_matriz_aslu)          AS n_resumen_x4;

-- 2) Últimas fechas en los 4 objetos clave (debe dar 2025-08-08 en todos)
SELECT 'astro_luna' obj, MAX(fecha) FROM astro_luna
UNION ALL
SELECT 'matriz_astro_luna', MAX(fecha) FROM matriz_astro_luna
UNION ALL
SELECT 'todos_resumen_matriz_aslu', MAX(fecha) FROM todos_resumen_matriz_aslu
UNION ALL
SELECT 'todo(view)', MAX(fecha) FROM todo;
