SELECT digito_a, digito_b, COUNT(*) AS n
FROM v_digit_pairs
GROUP BY digito_a, digito_b
ORDER BY n DESC
LIMIT 20;
