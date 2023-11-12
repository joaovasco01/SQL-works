CREATE VIEW Vendas(ean, cat, ano, trimestre, dia_mes, dia_semana, distrito, concelho, unidades) 
AS
SELECT pl.ean, p.cat, EXTRACT (YEAR FROM e.instante), EXTRACT (QUARTER FROM e.instante), EXTRACT (DAY FROM e.instante), EXTRACT (ISODOW FROM e.instante), pdr.distrito,pdr.concelho , pl.unidades
FROM planograma pl
INNER JOIN produto p on pl.ean = p.ean
INNER JOIN instalada_em ie on (pl.num_serie,pl.fabricante) = (ie.num_serie,ie.fabricante)
INNER JOIN ponto_de_retalho pdr on ie.locale = pdr.nome
INNER JOIN evento_reposicao e on pl.ean = e.ean and pl.nro = e.nro and pl.num_serie = e.num_serie and pl.fabricante = e.fabricante;

