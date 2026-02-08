WITH tot AS (
  SELECT wday, SUM(n) AS total
  FROM v_digit_calendar_effects
  GROUP BY wday
)
SELECT e.wday, e.digito,
       ROUND(1.0*e.n / t.total, 4) AS share_wday
FROM v_digit_calendar_effects e
JOIN tot t USING(wday)
ORDER BY e.wday, e.digito;
