SELECT digito, n_7d, n_30d, n_90d
FROM v_digit_rolling
WHERE fecha = (SELECT MAX(fecha) FROM v_digit_rolling)
ORDER BY digito;
