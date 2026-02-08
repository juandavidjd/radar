SELECT name
FROM sqlite_master
WHERE type='table'
  AND name IN (
    'todos_cuando_son',
    'todo_cuando_0_es','todo_cuando_1_es','todo_cuando_2_es','todo_cuando_3_es','todo_cuando_4_es',
    'todo_cuando_5_es','todo_cuando_6_es','todo_cuando_7_es','todo_cuando_8_es','todo_cuando_9_es'
  )
ORDER BY name;
