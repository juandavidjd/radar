SELECT digito, fecha, n_30d, ROUND(mu_diaria,2) AS mu_dia, ROUND(z30,2) AS z30
FROM v_digit_hotcold
WHERE fecha = (SELECT MAX(fecha) FROM v_digit_hotcold)
ORDER BY z30 DESC;
