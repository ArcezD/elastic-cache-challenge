# /usr/bin/python2.7
import sys
import psycopg2
from rediscluster import RedisCluster
from configparser import ConfigParser
from flask import Flask, request, render_template, g, abort
from waitress import serve
import time

def config(filename='config/database.ini', section='postgresql'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        print('Section {0} not found in the {1} file'.format(section, filename), file=sys.stderr)
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return db

def fetch(sql):
    # try to get it from the cache
    r = None
    try:
        r = get_redis_client()
        if r is not None and r.exists(sql):
            return r.get(sql)
     
    except (Exception) as error:
        print(f'Error getting {sql} from redis cache.', error, file=sys.stderr)

    # connect to database listed in database.ini
    conn = connect()
    if(conn != None):
        cur = conn.cursor()
        cur.execute(sql)
        
        # fetch one row
        retval = cur.fetchone()
        
        # try to save it to redis cache for 300 seconds
        try:
            if r is not None:
                r.setex(sql, 300, ''.join(retval))
        except (Exception) as error:
            print(f'Error saving {sql} to redis cache.', error, file=sys.stderr)
        
        # close db connection
        cur.close() 
        conn.close()
        print("PostgreSQL connection is now closed", file=sys.stdout)

        return retval
    else:
        return None    

def connect():
    """ Connect to the PostgreSQL database server and return a cursor """
    conn = None
    try:
        # read connection parameters
        params = config()

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...', file=sys.stdout)
        conn = psycopg2.connect(**params)
        
                
    except (Exception, psycopg2.DatabaseError) as error:
        print("Error:", error, file=sys.stderr)
        conn = None
    
    else:
        # return a conn
        return conn

def get_redis_client():
    """ Connect to the Redis """
    rc = None
    try:
        # read connection parameters
        params = config(section='redis')

        # connect to the redis instance
        print('Connecting to the Redis instance...', file=sys.stdout)
        rc = RedisCluster(**params) #(startup_nodes=startup_nodes, decode_responses=True)
                
    except (Exception) as error:
        print("Error:", error, file=sys.stderr)
        r = None
    
    else:
        # return a redis client
        return rc

app = Flask(__name__) 

@app.before_request
def before_request():
   g.request_start_time = time.time()
   g.request_time = lambda: "%.5fs" % (time.time() - g.request_start_time)

@app.route("/")     
def index():
    sql = 'SELECT slow_version();'
    db_result = fetch(sql)

    if(db_result):
        db_version = ''.join(db_result)    
    else:
        abort(500)
    params = config()
    return render_template('index.html', db_version = db_version, db_host = params['host'])

if __name__ == "__main__":         # on running python app.py
    #app.run()                      # run the flask app
    serve(app, host='0.0.0.0', port=5000)
