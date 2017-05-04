#!/usr/bin/env python3
from flask import Response
import json

def json_response(rsp_dict):
    rsp = Response( response = json.dumps(rsp_dict),
                    mimetype = 'application/json',
                    status   = 200 )
    return rsp
