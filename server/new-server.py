#!/usr/bin/env python3
import src.core as core
import flask
from flask_cors import cross_origin
import src.utils.files as files

app = flask.Flask(__name__)
app.debug = True


# placeholder landing page.
@app.route('/')
def landing():
    return 'hello world!'


# placeholder callback route.
@app.route('/callback/<callback>', methods = ['GET','POST'])
@cross_origin()
def callback(callback):
    print("callback: ",callback)
    print("method: ",flask.request.method)
    return flask.Response(status=200)


# placeholder survey route.
@app.route('/surveys/<survey>', methods = ['GET'])
def surveys(survey):
    print("survey: ",survey)
    if core.survey_exists(survey):
        spec = core.load_survey(survey)
        print('spec: ',spec)
        return flask.Response(status=200)
    else:
        print('does not exist!')
        return flask.Response(status=400)
