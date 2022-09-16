import psycopg2
from config import config as conf
import geopandas as gpd
from geovoronoi import voronoi_regions_from_coords, points_to_coords
import pandas as pd

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



sql = f"""
    SELECT 
    geosid, geom
    FROM in_{str(year)}_cbf_ct;
    """
dfct = gpd.read_postgis(sql, connection)


eas = []

dfct = dfct[dfct["geosid"] == '5350011.00']


q = 0
for index, row in dfct.iterrows():

    

    ct = str(row["geosid"])
    print(ct)
    geom = str(row["geosid"])

    sql = f"""
        SELECT 
        *
        FROM in_{str(year)}_gaf_pt_min
        WHERE ctuid = '{ct}';
        """
    dfea = gpd.read_postgis(sql, connection)

    if len(dfea.index) > 1:

        sql = f"""
            WITH ct AS (SELECT ST_Transform(geom, 3857) AS geom FROM in_1986_cbf_ct WHERE geosid = '{ct}'), 
            vor AS (
                SELECT (ST_Dump(ST_VoronoiPolygons(
                (SELECT 
                ST_Collect(ST_Transform(geom,3857))
                FROM in_1986_gaf_pt_min
                WHERE ctuid = '{ct}'),
                0,
                (SELECT ST_Transform(geom,3857) FROM ct)
                    ))).geom
            ),
            ea AS (
                SELECT 
                *
                FROM in_1986_gaf_pt_min
                WHERE ctuid = '{ct}'
            ),
            vor_join AS (
                SELECT
                coalesce(sum(ea.ea_pop::integer),0) AS pop,
                coalesce(sum(ea.ea_dwe::integer),0) AS dwe,
                ea.ctuid AS ctuid,
                vor.geom
                FROM vor  
                    LEFT JOIN ea 
                    ON ST_Intersects(ST_Transform(vor.geom,4269), ea.geom) 
                GROUP BY vor.geom, ea.ctuid
            )

            SELECT ST_Intersection(vor_join.geom,ct.geom) AS geom FROM vor_join, ct;

            """

        ea = gpd.read_postgis(sql, connection)

        eas.append(ea)

        q += 1

    else:

        print(dfea)

        sql = f"""
            SELECT 
            ea_pop AS pop,
            ea_dwe AS dwe,
            ctuid AS ctuid,
            (SELECT geom FROM in_1986_cbf_ct WHERE geosid = '{ct}') as geom
            FROM in_{str(year)}_gaf_pt_min
            WHERE ctuid = '{ct}'
        """

        ea = gpd.read_postgis(sql, connection)

        eas.append(ea)
    

eas = pd.concat(eas)

gpd.GeoDataFrame(eas).to_file("in_1986_vor_ea.geojson")
