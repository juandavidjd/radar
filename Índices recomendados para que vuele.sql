CREATE INDEX IF NOT EXISTS idx_tcs_fecha        ON todos_cuando_son(fecha);
CREATE INDEX IF NOT EXISTS idx_tcs_digito       ON todos_cuando_son(digito);
CREATE INDEX IF NOT EXISTS idx_tcs_fecha_num    ON todos_cuando_son(fecha, numero);
CREATE INDEX IF NOT EXISTS idx_tcs_numero       ON todos_cuando_son(numero);
CREATE INDEX IF NOT EXISTS idx_tcs_posicion     ON todos_cuando_son(posicion);
CREATE INDEX IF NOT EXISTS idx_tcs_digito_fecha ON todos_cuando_son(digito, fecha);
