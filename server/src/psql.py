#!/usr/bin/env python3
from collections import namedtuple
import psycopg2 as sql
# Accept data of form {sensor_id:[(datetime,value),...],...}
# Return data of form [(sensor_id,datetime,value),...]
Row = namedtuple('row',['question','response','timestamp'])

def mkrows(question,data):
    rows = []
    for rsp in data:
        if not data[rsp]: continue
        rows += [Row(question,rsp,time) for time in data[rsp]]
    return rows

def push(question,data,dbname,tblname):
    rows = mkrows(question,data)
    print("\nsaving {} rows to table: {}".format(len(rows),tblname))
    with sql.connect(database=dbname) as con:
        cur = con.cursor()
        for i,r in enumerate(rows):
            try:
                cur.execute('''INSERT INTO {} (question,response,timestamp) VALUES
                    (%s,%s,to_timestamp(%s))'''.format(tblname),r)
                con.commit()
            except sql.IntegrityError:
                con.rollback()
    con.close()
