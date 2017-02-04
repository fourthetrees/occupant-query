#!/usr/bin/env python3
import json

# This file contains helpers for searching for query parameters.
# Currently, the `get_config()` function returns default
# values even if no query is found.  This decision was made
# in order to allow for the setting of a kiosk to a url
# which is known to be populated in the future...
# If this kind of silent failure becomes problematic in the future,
# this policy may be changed.

# Called to get parameters for a given query.
# Merges defaults with any values found for qname.
def get_config(qname):
    config = get_defaults()
    qvalues  = get_query(qname)
    config.update(qvalues)
    return config

# Attempts to find specific query file.
# Returns an empty dict if no file found.
def get_query(qname):
    qfile = 'tmp/queries/{}.json'.format(qname)
    try:
        with open(qfile) as fp:
            qdata = json.load(fp)
    except: qdata = {}
    return qdata

# Loads default query values.
def get_defaults():
    dfile = 'tmp/config/query_defaults.json'
    with open(dfile) as fp:
        ddata = json.load(fp)
    return ddata
