import geopandas as gpd
from shapely.geometry import Point
import random
import sys
import psycopg2

# setting path
sys.path.append('..')
from config import config as conf

# connect to database
connection = psycopg2.connect(
	"""host='{host}' port='{port}' dbname='{dbname}'
		user='{user}' password='{password}'
	""".format(
		host = conf['pg']['host'],
		port = conf['pg']['port'],
		dbname = conf['pg']['database'],
		user = conf['pg']['user'],
		password = conf['pg']['password']
	)
)
connection.autocommit = True

# dot creation
def gen_dot(polygon, number):
    points = []    
    while len(points) < number:
        pnt = Point(random.uniform(polygon.bounds.minx, polygon.bounds.maxx), random.uniform(polygon.bounds.miny, polygon.bounds.maxy))
        if polygon.iloc[0].contains(pnt):
            points.append([pnt.x,pnt.y])
    return points


sql = f"""
    SELECT 
    ctuid71 as ctuid,
    pop_71 as pop,
    dwl_71 as dwe,
    geom as geom
    FROM in_1971_ea_jct
    """
df = gpd.read_postgis(sql, connection)

print(df)