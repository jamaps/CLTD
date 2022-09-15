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


if year == 1986:

    sql = """
        SELECT 
        CONCAT(CONCAT(prov,fed),ea) AS eauid,
        ca_cma AS cma,
        CONCAT(ca_cma,LPAD(LEFT(ct_name, -5),7,'000')) AS ctuid,
        ea_pop AS ea_pop,
        ea_pri_dwe AS ea_dwe,
        geom AS geom
        FROM in_1986_gaf_pt;
        """
    dfea = gpd.read_postgis(sql, connection)

    sql = """
        SELECT 
        geosid, geom
        FROM in_1986_cbf_ct;
    """
    dfct = gpd.read_postgis(sql, connection)


eas = []

q = 0
for index, row in dfct.iterrows():

    ct = row["geosid"]
    print(ct)
    geom = row["geom"]

    ea = dfea.loc[dfea["ctuid"] == ct].reset_index()

    ea["x"] = ea.geom.x
    ea["y"] = ea.geom.y

    ea["ea_pop"] = ea["ea_pop"].astype(int)
    ea["ea_dwe"] = ea["ea_dwe"].astype(int)

    ea = ea.groupby(["ctuid","x","y"])["ea_pop","ea_dwe"].sum().reset_index()
    ea["geom"] = gpd.points_from_xy(ea["x"],ea["y"])

    if len(ea.index) > 1:

        coords = points_to_coords(ea.geom)

        poly_shapes, points = voronoi_regions_from_coords(coords, geom, per_geom = False)

        i = 0
        polys = []
        while i < len(poly_shapes):
            j = points[i][0]
            polys.append(poly_shapes[j])
            i += 1
        ea["geometry"] = gpd.GeoSeries(polys)

        del ea['geom']

        eas.append(ea)

    else:

        ea["geometry"] = gpd.GeoSeries([geom])
        del ea['geom']
        eas.append(ea)

    # q += 1
    # if q > 100:
    #     break

eas = pd.concat(eas)

print(eas)

gpd.GeoDataFrame(eas).to_file("temp.geojson")
