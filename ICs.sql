/*1*/

DROP TRIGGER IF EXISTS catergorias ON tem_outra;

CREATE OR REPLACE FUNCTION categorias_proc() 
RETURNS TRIGGER AS $$
DECLARE var_count INTEGER := 0;
BEGIN
    select count(*) into var_count from tem_outra where categoria=super_categoria 
    IF var_count > 0 THEN
        RAISE EXCEPTION 'Uma Categoria nao pode estar contida em si propria';
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT categorias AFTER INSERT OR UPDATE ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE categorias_trigger_proc();

/*2*/

CREATE OR REPLACE FUNCTION nao_pode_exceder() 
RETURNS TRIGGER AS $$
DECLARE var_count INTEGER := 0;
BEGIN

    select count(*) into var_count
    from evento_reposicao as er
    from planograma as plan
    sum(er.unidades) as nunits
    where plan.unidades>nunits

    
    IF var_count > 0 THEN
        RAISE EXCEPTION 'O numero de unidades respostas num evento de reposicao nao pode exceder o numero de unidades especificado no planograma';
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT nao_pode_exceder AFTER INSERT OR UPDATE ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE nao_pode_exceder_trigger_proc();

/*3*/

CREATE OR REPLACE FUNCTION pelo_menos() 
RETURNS TRIGGER AS $$
DECLARE var_count INTEGER := 0;
BEGIN
    if prateleira.nome IS NOT NULL THEN
        if produto.nome IS NOT NULL THEN
            select count(*) into var_count
            from produto as p
            from prateleira as pra 
            where pra.nome=p.cat 
            IF var_count < 1 THEN
                RAISE EXCEPTION 'Um produto so pode ser reposto numa prateleira que apresente uma das categorias desse produto';
            END IF;
        END IF;
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT pelo_menos AFTER INSERT OR UPDATE ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE pelo_menos_trigger_proc();