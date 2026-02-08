CREATE INDEX IF NOT EXISTS idx_astro_luna_fecha_numero
  ON astro_luna(fecha, numero);

CREATE INDEX IF NOT EXISTS idx_matriz_aslu_fecha_numero
  ON matriz_astro_luna(fecha, numero);

CREATE INDEX IF NOT EXISTS idx_resumen_fecha_numero
  ON todos_resumen_matriz_aslu(fecha, numero);

CREATE INDEX IF NOT EXISTS idx_cuando_son_fecha_numero
  ON todos_cuando_son(fecha, numero);
