
SELECT Top 1 r.name
FROM retalhista as r
FULL OUTER JOIN responsavel_por as rp
group by rp.nome_cat
order by count(*) desc;



SELECT ret.name
FROM retalhista as ret
NATURAL JOIN responsavel_por as rf
NATURAL JOIN categoria_simples as cs;



SELECT p.ean 
FROM produto as p
WHERE p.ean 
NOT IN (
    SELECT DISTINCT pr.ean
    FROM evento_reposicao as pr);


SELECT ean FROM( SELECT DISTINCT tin,ean FROM evento_reposicao) as t1
GROUP BY (ean)
HAVING count(ean) = 1;