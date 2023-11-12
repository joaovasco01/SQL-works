#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request
import psycopg2
import psycopg2.extras

##SGBD configs
DB_HOST="db.tecnico.ulisboa.pt"
DB_USER="ist195628"
DB_DATABASE=DB_USER
DB_PASSWORD="password"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD)
app = Flask(__name__)


@app.route('/')
def menu():
    try:
        return render_template("menu.html", params=request.args)
    except Exception as e:
        return str(e)


@app.route('/categorias')
def list_accounts():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("index.html", cursor=cursor)
    except Exception as e:
        return str(e) #Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route('/addCat')
def addCategory():
    try:
        return render_template("categorias.html", params=request.args)
    except Exception as e:
        return str(e)


@app.route('/upCat', methods = ["POST"])
def updateCategory():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        cat=request.form["cat"]
        query = "INSERT into categoria(nome) VALUES (%s)"
        data = (cat,)
        cursor.execute(query,data)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("index.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/remCat', methods = ["POST"])
def remCat():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        cat=request.form["cat"]
        query = "DELETE FROM categoria WHERE nome=%s;"
        data = (cat,)
        cursor.execute(query,data)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("index.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route('/addSubCat')
def addSubCat():
    try:
        return render_template("addSubCat.html", params=request.args)
    except Exception as e:
        return str(e)
    

@app.route('/upSubCat', methods = ['POST'])
def upSubCat():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        subcat = request.form["subcat"]
        supercat = request.form["supercat"]
        #query = "INSERT into categoria(nome) VALUES (%s)"
        query = "INSERT INTO tem_outra(categoria, super_categoria) VALUES (%s,%s)"
        data = (subcat, supercat)
        #data = (subcat,)
        cursor.execute(query,data)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("index.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

    


@app.route('/retalhistas')
def listRetailers():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        query = "SELECT r.tin, r.name, p.num_serie, p.fabricante, p.nome_cat FROM retalhista r, responsavel_por p WHERE r.tin = p.tin;"
        cursor.execute(query)
        return render_template("retalhistas.html", cursor=cursor)
    except Exception as e:
        return str(e) #Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route('/addRet')
def addRetailer():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        cursor2 = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        query = "SELECT num_serie, fabricante FROM IVM WHERE (num_serie,fabricante) NOT IN (SELECT r.num_serie, r.fabricante FROM responsavel_por r);"
        cursor.execute(query)
        query2 = "SELECT * FROM categoria"
        cursor2.execute(query2)
        return render_template("addRetailer.html", params=request.args, cursor = cursor, cursor2 = cursor2)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()

@app.route('/upRet', methods = ['POST'])
def upRetailers():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        id=request.form["id"]
        nome=request.form["nome"]
        maq=request.form["maq"].split(',')
        cat=request.form["cat"]
        query = "INSERT into retalhista(tin,name) VALUES (%s,%s)"
        data = (id,nome)
        cursor.execute(query,data)
        query = "INSERT into responsavel_por(num_serie, fabricante, nome_cat, tin) VALUES (%s,%s,%s,%s)"
        data = (maq[0], maq[1], cat, id)
        cursor.execute(query,data)
        query = "SELECT r.tin, r.name, p.num_serie, p.fabricante, p.nome_cat FROM retalhista r, responsavel_por p WHERE r.tin = p.tin;"
        cursor.execute(query)
        return render_template("retalhistas.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

@app.route('/remRet', methods = ['POST'])
def remRetailer():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        id=request.form["id"]
        query = "DELETE FROM retalhista WHERE tin=%s;"
        data = (id,)
        cursor.execute(query,data)
        query = "SELECT r.tin, r.name, p.num_serie, p.fabricante, p.nome_cat FROM retalhista r, responsavel_por p WHERE r.tin = p.tin;"
        cursor.execute(query)
        return render_template("retalhistas.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route('/superCategorias')
def listSuperCat():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        query = "SELECT * FROM super_categoria;"
        cursor.execute(query)
        return render_template("superCat.html", cursor=cursor)
    except Exception as e:
        return str(e) #Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()


@app.route('/subCats', methods = ['POST'])
def listSubCat():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        supercat = request.form["supercat1"]
        query = "WITH RECURSIVE subc AS (SELECT categoria FROM tem_outra WHERE tem_outra.super_categoria = %s UNION SELECT t.categoria FROM tem_outra t INNER JOIN subc s on s.categoria = t.super_categoria) SELECT * FROM subc;"
        data = (supercat,)
        cursor.execute(query,data)
        return render_template("subCat.html", params=request.args, cursor=cursor )
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()



@app.route('/eventosReposicao')
def listIVM():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        query="SELECT * FROM IVM"
        cursor.execute(query)
        return render_template("listIVMs.html", cursor=cursor)
    except Exception as e:
        return str(e) #Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()

@app.route('/repEv', methods=['POST'])
def repEv():
    dbConn=None
    cursor=None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        cursor2=dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
        maq=request.form["maq"].split(',')
        query="SELECT instante, ean, nro, unidades, tin FROM evento_reposicao WHERE num_serie=%s AND fabricante=%s"
        data=(maq[0],maq[1])
        cursor.execute(query,data)
        query2= "SELECT nome, sum(unidades) as sum_unit FROM evento_reposicao NATURAL JOIN prateleira WHERE num_serie = %s GROUP BY nome;"
        data2=(maq[0],)
        cursor2.execute(query2, data2)
        return render_template("listRepEv.html", cursor=cursor, cursor2=cursor2)
    except Exception as e:
        return str(e) #Renders a page with the error.
    finally:
        cursor.close()
        dbConn.close()






CGIHandler().run(app)