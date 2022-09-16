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

    # sql = """
    #     SELECT 
    #     CONCAT(CONCAT(prov,fed),ea) AS eauid,
    #     ca_cma AS cma,
    #     CONCAT(ca_cma,LPAD(LEFT(ct_name, -5),7,'000')) AS ctuid,
    #     ea_pop AS ea_pop,
    #     ea_pri_dwe AS ea_dwe,
    #     geom AS geom
    #     FROM in_1986_gaf_pt;
    #     """
    # dfea = gpd.read_postgis(sql, connection)

    sql = """
        SELECT 
        geosid, geom
        FROM in_1986_cbf_ct;
    """
    dfct = gpd.read_postgis(sql, connection)


eas = []

dfct = dfct[dfct["geosid"] == '5350011.00']


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
    

    if len(ea.index) > 2:

        try:

            ea["geom"] = gpd.points_from_xy(ea["x"],ea["y"])

            coords = points_to_coords(ea.geom)

            poly_shapes, points = voronoi_regions_from_coords(coords, geom, per_geom = False)

            print(points)

            i = 0
            polys = []
            while i < len(poly_shapes):
                j = points[i][0]
                polys.append(poly_shapes[j])
                i += 1 

            ea["geometry"] = gpd.GeoSeries(polys)

            del ea['geom']

            eas.append(ea)

        except:
            ea["geom"] = gpd.points_from_xy(ea["x"],ea["y"])
            ea["geometry"] = gpd.GeoSeries([geom])
            del ea['geom']
            eas.append(ea)

    if len(ea.index) == 2:

        sql = f"""
            SELECT 
            *
            FROM in_1986_gaf_pt 
            WHERE ctuid = {ct};
        """
        ea = gpd.read_postgis(sql, connection)
        print(ea)


        # coords = points_to_coords(ea.geom)

        # poly_shapes, points = voronoi_regions_from_coords(coords, geom, per_geom = False)

        # print(points)

        # i = 0
        # polys = []
        # while i < len(poly_shapes):
        #     j = points[i][0]
        #     polys.append(poly_shapes[j])
        #     i += 1 

        # ea["geometry"] = gpd.GeoSeries(polys)

        # del ea['geom']

        # eas.append(ea)

        # ea["letter"] = pd.Series(["A","B"])

        # ea0 = ea.copy()
        # ea1 = ea.copy()
        # ea2 = ea.copy()
        # ea1["x"] = ea1["x"] + 0.0001
        # ea1["y"] = ea1["y"] + 0.0001
        # ea2["x"] = ea2["x"] - 0.0001
        # ea2["y"] = ea2["y"] - 0.0001

        # ea = pd.concat([ea1,ea2]).reset_index()
        # del ea["index"]
        # ea["ea_pop"] = ea["ea_pop"] / 2
        # ea["ea_dwe"] = ea["ea_dwe"] / 2

        # ea["geom"] = gpd.points_from_xy(ea["x"],ea["y"])

        # ea = ea.sort_values(by = ["letter"], ascending = False).reset_index()

        # del ea["index"]

        # print(ea)


        # coords = points_to_coords(ea.geom)
     
        # poly_shapes, points = voronoi_regions_from_coords(coords, geom, per_geom = False)

        # print(poly_shapes)
        # print(points)

        # i = 0
        # polys = []
        # while i < len(poly_shapes):
        #     j = points[i][0]
        #     polys.append(poly_shapes[j])
        #     i += 1 
        # print(polys[0])
        # ea["geometry"] = gpd.GeoSeries(polys)

        # del ea['geom']

        # ead = ea[["letter","geometry"]]

        # ead = gpd.GeoDataFrame(ead).dissolve("letter")
        # ea = pd.merge(ea0, ead, on="letter")

        # eas.append(ea)

        # except:
        #     ea["geom"] = gpd.points_from_xy(ea["x"],ea["y"])
        #     ea["geometry"] = gpd.GeoSeries([geom])
        #     del ea['geom']
        #     eas.append(ea)
        

    else:

        ea["geom"] = gpd.points_from_xy(ea["x"],ea["y"])
        ea["geometry"] = gpd.GeoSeries([geom])
        del ea['geom']
        eas.append(ea)

eas = pd.concat(eas)

print(eas)

gpd.GeoDataFrame(eas).to_file("temp.geojson")
