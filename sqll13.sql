CREATE INDEX IF NOT EXISTS idx_astro_fecha           ON astro_luna(fecha);
CREATE INDEX IF NOT EXISTS idx_matriz_fecha_numero   ON matriz_astro_luna(fecha, numero);
CREATE INDEX IF NOT EXISTS idx_todosres_fecha_numero ON todos_resumen_matriz_aslu(fecha, numero);
CREATE INDEX IF NOT EXISTS idx_tcs_fecha_num_pos     ON todos_cuando_son(fecha, numero, posicion);
