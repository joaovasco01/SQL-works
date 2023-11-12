SELECT dia_semana, concelho, SUM(unidades) AS total_unidades
FROM Vendas
WHERE ano BETWEEN 2018 AND 2021
GROUP BY GROUPING SETS (dia_semana, concelho)

SELECT concelho, cat, dia_semana, SUM(unidades) AS total_unidades
FROM Vendas
WHERE distrito = "Lisboa"
GROUP BY GROUPING SETS (concelho, cat, dia_semana)
