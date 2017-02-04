#!/usr/bin/env python3
from flask import Flask
from flask import request
from flask import Response
from flask import render_template
from flask_cors import cross_origin
import os.path as path
import src.psql as psql
import src.utils as utils
import src.queries as queries
import json


app = Flask(__name__)
app.debug = True

# Because its rude not to say hello.
@app.route('/')
def landing():
    return 'hello world'

# Primary data-logging route.
@app.route('/callback/<query>', methods = ['GET','POST'])
@cross_origin()
def log_responses(query):
    if request.method == 'POST':
        jdata = request.get_json(force=True)
        store_values(query,jdata)
        rsp = utils.json_response({'hello':'world'})
        return rsp
    elif request.method == 'GET':
        data = queries.get_config(query)
        rsp  = utils.json_response(data)
        return rsp
    else:
        rsp = Response(status=400)
        return rsp

# Primary query-serving route.
@app.route('/queries/<query>', methods = ['GET'])
def query_generator(query):
    seed = queries.get_config(query)
    return render_template('main.html',seed=seed)

# Storage function -- overwrite as appropriate.
def store_values(query,data):
    print('Values Recieved For {}'.format(query))
    print(json.dumps(data,indent=2))
    #config = psql.get_config()
    #psql.push(query,data,**config)
