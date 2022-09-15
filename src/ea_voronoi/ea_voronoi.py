import psycopg2
from config import config as conf
import geopandas as gpd

year = 1986

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


if year == 1986:

    sql = """
        SELECT 
        CONCAT(CONCAT(prov,fed),ea) AS eauid,
        ca_cma AS cma,
        LEFT(ct_name, -5) AS ctuid,
        ea_pop AS ea_pop,
        ea_pri_dwe AS ea_dwe,
        geom AS geom
        FROM in_1986_gaf_pt;
        """
    ea = gpd.read_postgis(sql, connection)

    sql = """
        SELECT 
        geosid, geom
        FROM in_1986_cbf_ct;
    """
    ct = gpd.read_postgis(sql, connection)

print(ea)
    

# for ct in ct:

#     do stuff