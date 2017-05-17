#!/usr/bin/env python3
import toml
import json
import os
import os.path as path

# load a given config file.
def load_config(name):
    uri = 'tmp/config/'
    config = load_file(uri,name)
    return config

# load a survey file.
def load_deployment(deployment):
    uri = 'tmp/deployments/'
    config = load_file(uri,deployment)
    return config

# write a deployment file.
def write_deployment(deployment,data):
    uri = 'tmp/deployments/'
    write_file(uri,deployment,data)

# get a list of all active deployments.
def get_active_deployments():
    uri,name = 'tmp/','active-deployments'
    active = load_file(uri,name)
    deployments = []
    for dep in active:
        if is_active(active[dep]):
            deployments.append(load_deployment(dep))
    return deployments

# check if a given target is active.
def is_active(target):
    if not target: return False
    if 'settings' in target:
        target = target['settings']
    if 'is-active' in target:
        if not target['is-active']:
            return False
    return True

# generically load a toml or json file.
def load_file(directory,name):
    files = os.listdir(directory)
    matches = [f for f in files if f.startswith(name)]
    if not matches:
        raise Exception('no file found for: ' + name)
    match = matches.pop(0)
    if match.endswith('toml'):
        load = lambda fp: toml.load(fp)
    elif match.endswith('json'):
        load = lambda fp: json.load(fp)
    else: raise Exception('unknown file format: ' + match)
    with open(match) as fp:
        data = load(fp)
    return data

# generically write a toml or json file.
def write_file(directory,name,data,fmt='toml'):
    if not directory.endswith('/'):
        directory = directory + '/'
    if not path.isdir(directory):
        os.makedirs(directory)
    if fmt == 'toml':
        name = '{}.toml'.format(name)
        dump = lambda d,f: toml.dump(d,f)
    elif fmt == 'json':
        name = '{}.json'.format(name)
        dump = lambda d,f: json.dump(d,f)
    else: raise Exception('unknown file format: ' + fmt)
    with open(directory + name) as fp:
        dump(data,fp)
