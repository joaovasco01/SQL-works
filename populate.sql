DROP TABLE IF EXISTS categoria CASCADE;
DROP TABLE IF EXISTS categoria_simples CASCADE;
DROP TABLE IF EXISTS super_categoria CASCADE;
DROP TABLE IF EXISTS tem_outra CASCADE;
DROP TABLE IF EXISTS produto CASCADE; 
DROP TABLE IF EXISTS tem_categoria CASCADE; 
DROP TABLE IF EXISTS IVM CASCADE; 
DROP TABLE IF EXISTS ponto_de_retalho CASCADE; 
DROP TABLE IF EXISTS instalada_em CASCADE;
DROP TABLE IF EXISTS prateleira CASCADE;
DROP TABLE IF EXISTS planograma CASCADE;
DROP TABLE IF EXISTS retalhista CASCADE;
DROP TABLE IF EXISTS responsavel_por CASCADE;
DROP TABLE IF EXISTS evento_reposicao CASCADE;

CREATE TABLE categoria
    (nome VARCHAR(20) NOT NULL, 
    PRIMARY KEY (nome));

CREATE TABLE categoria_simples
    (nome VARCHAR(20) NOT NULL, 
    PRIMARY KEY (nome),
    FOREIGN KEY (nome)
    REFERENCES categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE super_categoria
    (nome VARCHAR(20) NOT NULL, 
    PRIMARY KEY (nome),
    FOREIGN KEY (nome)
    REFERENCES categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE);


CREATE TABLE tem_outra                                                  
    (categoria VARCHAR(20) NOT NULL, 
    super_categoria VARCHAR(20) NOT NULL,
    PRIMARY KEY (categoria),
    FOREIGN KEY (super_categoria)
    REFERENCES super_categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (categoria)
    REFERENCES categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE);
    

CREATE TABLE produto
    (ean NUMERIC(13) NOT NULL,
    cat VARCHAR(20),
    descr VARCHAR(20),
    PRIMARY KEY (ean),
    FOREIGN KEY (cat)
    REFERENCES categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE tem_categoria
    (ean numeric(13) NOT NULL,
    nome VARCHAR(20) NOT NULL,
    FOREIGN KEY (ean)
    REFERENCES produto(ean) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nome)
    REFERENCES categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE IVM
    (num_serie INTEGER,
    fabricante VARCHAR(20) NOT NULL,
    PRIMARY KEY (num_serie, fabricante));

CREATE TABLE ponto_de_retalho
    (nome VARCHAR(20) NOT NULL,
    distrito VARCHAR(20) NOT NULL,
    concelho VARCHAR(20) NOT NULL,
    PRIMARY KEY (nome));

CREATE TABLE instalada_em
    (num_serie INTEGER,
    fabricante VARCHAR(20) NOT NULL,
    locale VARCHAR(20) NOT NULL,
    PRIMARY KEY (fabricante, num_serie),
    FOREIGN KEY (num_serie,fabricante)
    REFERENCES ivm(num_serie,fabricante) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (locale)
    REFERENCES ponto_de_retalho(nome) ON DELETE CASCADE ON UPDATE CASCADE);  
    
CREATE TABLE prateleira
    (nro INTEGER,
    num_serie INTEGER,
    fabricante VARCHAR(20) NOT NULL,
    altura INTEGER,
    nome VARCHAR(20) NOT NULL,
    PRIMARY KEY (nro,fabricante, num_serie),
    FOREIGN KEY (num_serie,fabricante)
    REFERENCES IVM(num_serie, fabricante)  ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nome)
    REFERENCES categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE);    


CREATE TABLE planograma
    (ean numeric(13) NOT NULL,
    nro INTEGER,
    num_serie INTEGER,
    fabricante VARCHAR(20) NOT NULL,
    faces VARCHAR(20) NOT NULL,
    unidades VARCHAR(20) NOT NULL,
    loc VARCHAR(20) NOT NULL,
    PRIMARY KEY (ean,nro,fabricante, num_serie),
    FOREIGN KEY (ean)
    REFERENCES produto(ean) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nro,num_serie,fabricante)
    REFERENCES prateleira(nro,num_serie,fabricante) ON DELETE CASCADE ON UPDATE CASCADE);    

CREATE TABLE retalhista
    (tin INTEGER, 
    name VARCHAR(20) NOT NULL,
    PRIMARY KEY (tin));

CREATE TABLE responsavel_por
    (num_serie INTEGER,
    fabricante VARCHAR(20) NOT NULL,
    nome_cat VARCHAR(20) NOT NULL,
    tin INTEGER NOT NULL,
    PRIMARY KEY (num_serie, fabricante),
    FOREIGN KEY (num_serie,fabricante)
    REFERENCES IVM(num_serie, fabricante)  ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nome_cat)
    REFERENCES categoria(nome) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tin)
    REFERENCES retalhista(tin) ON DELETE CASCADE ON UPDATE CASCADE);  

CREATE TABLE evento_reposicao
    (instante TIMESTAMP,
    ean numeric(13) NOT NULL,
    nro INTEGER,
    num_serie INTEGER,
    fabricante VARCHAR(20) NOT NULL,
    unidades INTEGER,
    tin INTEGER NOT NULL,
    PRIMARY KEY (instante,ean,nro,fabricante, num_serie),
    FOREIGN KEY (ean,nro,num_serie,fabricante)
    REFERENCES planograma(ean,nro,num_serie,fabricante) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tin)
    REFERENCES retalhista(tin) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE OR REPLACE function activateSuper()
RETURNS TRIGGER AS 
$$
BEGIN
    IF NOT (SELECT EXISTS(SELECT 1 FROM super_categoria WHERE super_categoria.nome = new.super_categoria))
        THEN INSERT INTO super_categoria(nome) VALUES (new.super_categoria);
        DELETE FROM categoria_simples WHERE nome=new.super_categoria ;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER activateSuper
BEFORE UPDATE OR INSERT ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE activateSuper();

CREATE OR REPLACE function addToSimple()
RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO categoria_simples(nome) VALUES (new.nome);
    RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER addToSimple
AFTER UPDATE OR INSERT ON categoria
FOR EACH ROW EXECUTE PROCEDURE addToSimple();


INSERT INTO categoria(nome) VALUES
    ('Bolachas'),
    ('Chocolates'),
    ('Doces'),
    ('Folhados'),
    ('Bolachas Maria'),
    ('sirkazzio'),
    ('tiagovski'),
    ('wuant');


INSERT INTO tem_outra(categoria, super_categoria)
VALUES
('Bolachas Maria','Bolachas');


INSERT INTO IVM (num_serie, fabricante) 
VALUES
(5,'cocacola'),
(6,'nike'),
(7,'adidas'),
(8,'empresa');


INSERT INTO ponto_de_retalho (nome, distrito, concelho)
VALUES
('GALP','Lisboa','Lisboa'),
('IST - TAGUS','Lisboa','Oeiras'),
('IST - ALAMEDA','Lisboa','Lisboa');

INSERT INTO instalada_em (num_serie, fabricante,locale)
VALUES
(5,'cocacola','GALP'),
(6,'nike','GALP'),
(7,'adidas','IST - ALAMEDA'),
(8,'empresa','IST - TAGUS');


INSERT INTO retalhista (tin, name) 
VALUES
(1,'primeiro'),
(2,'maria andre'),
(3,'joazinho'),
(4,'luis');


INSERT INTO responsavel_por (num_serie, fabricante, nome_cat,tin) 
VALUES
(5,'cocacola','Bolachas Maria',1),
(6,'nike','sirkazzio',2);
-- (7,'adidas','tiagovski',3),
-- (8,'empresa','wuant',4);



INSERT INTO produto (ean,cat,descr) 
VALUES
(500,'Folhados','apple'),
(600,'Bolachas Maria','samsung'),
(700,'wuant','base_de_dados'),
(800,'wuant','ceu');

INSERT INTO prateleira (nro, num_serie, fabricante, altura, nome) 
VALUES
(13, 5, 'cocacola', 14, 'Bolachas Maria'),
(17, 6, 'nike', 18, 'wuant'),
(19, 5, 'cocacola', 19, 'tiagovski');

INSERT INTO planograma (ean, nro, num_serie, fabricante, faces, unidades, loc) 
VALUES
(500, 13, 5, 'cocacola', 'frente', 2, 'Figueira'),
(600, 17, 6, 'nike',     'frente', 2, 'Figueira'),
(700, 19, 5, 'cocacola', 'frente', 2, 'Figueira');

INSERT INTO evento_reposicao (instante, ean, nro, num_serie, fabricante, unidades, tin) 
VALUES
('2021-08-09 13:57:45',500, 13, 5, 'cocacola',  2, 1),
('2021-08-09 13:57:46',600, 17, 6, 'nike',      2, 2),
('2021-08-09 13:57:47',700, 19, 5, 'cocacola',  2, 1);


INSERT INTO tem_outra(categoria, super_categoria) VALUES ('Doces','Bolachas')
