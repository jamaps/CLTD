import psycopg2
from config import config as conf
import geopandas as gpd
import pandas as pd

year = "1981"

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
    geosid, ct_pct, geom
    FROM in_{str(year)}_cbf_ct;
    """
dfct = gpd.read_postgis(sql, connection)


# # subset for testing
# dfct = dfct[dfct["geosid"] == '5350008.00']

eas = []

for index, row in dfct.iterrows():

    ct = str(row["ct_pct"])
    ctuid = str(row["geosid"])
    print(ct)

    sql = f"""
        SELECT 
        *
        FROM in_{str(year)}_gaf_pt
        WHERE ct_pct = '{ct}';
        """
    dfea = gpd.read_postgis(sql, connection)

    if len(dfea.index) > 1:

        sql = f"""
            WITH ct AS (SELECT ST_Transform(geom, 3857) AS geom FROM in_{year}_cbf_ct WHERE ct_pct = '{ct}'), 
            vor AS (
                SELECT (ST_Dump(ST_VoronoiPolygons(
                (SELECT 
                ST_Collect(ST_Transform(geom,3857))
                FROM in_{year}_gaf_pt
                WHERE ct_pct = '{ct}'),
                0,
                (SELECT ST_Transform(geom,3857) FROM ct)
                    ))).geom
            ),
            ea AS (
                SELECT 
                *
                FROM in_{year}_gaf_pt
                WHERE ct_pct = '{ct}'
            ),
            vor_join AS (
                SELECT
                coalesce(sum(ea.ea_pop::integer),0) AS pop,
                coalesce(sum(ea.pri_hhlds::integer),0) AS dwe,
                ea.ct_pct AS ct_pct,
                vor.geom
                FROM vor  
                    LEFT JOIN ea 
                    ON ST_Intersects(vor.geom, ST_Transform(ea.geom, 3857)) 
                GROUP BY vor.geom, ea.ct_pct
            )
            SELECT
            vor_join.pop,
            vor_join.dwe,
            vor_join.ct_pct,
            '{ctuid}' AS ctuid,
            ST_Transform(ST_Intersection(vor_join.geom,ct.geom), 4269) AS geom
            FROM vor_join, ct;
            """

        ea = gpd.read_postgis(sql, connection)

        eas.append(ea)

        None

    else:

        sql = f"""
            SELECT 
            coalesce(ea_pop::integer,0) AS pop,
            coalesce(pri_hhlds::integer,0) AS dwe,
            ct_pct AS ct_pct,
            '{ctuid}' AS ctuid,
            (SELECT geom FROM in_{year}_cbf_ct WHERE ct_pct = '{ct}') as geom
            FROM in_{str(year)}_gaf_pt
            WHERE ct_pct = '{ct}'
        """

        ea = gpd.read_postgis(sql, connection)

        eas.append(ea)


eas = pd.concat(eas)

print(eas)

gpd.GeoDataFrame(eas).to_file("in_" + year + "_vor_ea.geojson")
