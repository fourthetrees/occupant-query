#!/usr/bin/env python3
import src.psql_utils as psql
import toml


def update():
    active = psql.load_active()
    with open('update-test.toml','w') as fp:
        toml.dump(active,fp)





if __name__ == '__main__':
    update()
