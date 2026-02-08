SELECT 'astro_luna' obj, COUNT(*) n, MAX(fecha) max_f FROM astro_luna
UNION ALL
SELECT 'matriz_astro_luna', COUNT(*), MAX(fecha) FROM matriz_astro_luna
UNION ALL
SELECT 'todos_resumen_matriz_aslu', COUNT(*), MAX(fecha) FROM todos_resumen_matriz_aslu
UNION ALL
SELECT 'todos_cuando_son', COUNT(*), MAX(fecha) FROM todos_cuando_son
UNION ALL
SELECT 'todo(view)', COUNT(*), MAX(fecha) FROM todo;
