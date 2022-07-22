import pandas as pd
import geopandas as gpd
from shapely.geometry import Point

file_name = "data/pts_1996.csv"

df = pd.read_csv(file_name, dtype={"cmaca_code":str,"ctuid":str})

dfs = df.loc[df["cmaca_code"] == "001"].copy()

tr = pd.read_csv("translate_table.csv", dtype={"cma":str})

def translate_point(xi, yi, cma):

	trc = tr.loc[tr["cma"] == cma].copy()

	trc["xd"] = trc["xi"] - trc["xg"]
	trc["yd"] = trc["yi"] - trc["yg"]

	trc["d"] = ((trc["xi"] - xi) ** 2 + (trc["yi"] - yi) ** 2) ** 0.5

	trc["db"] = trc["d"] ** -2

	sum_db = trc["db"].sum()

	trc["q"] = 	trc["db"] / sum_db

	trc["q_xd"] = trc["q"] * trc["xd"]
	trc["q_yd"] = trc["q"] * trc["yd"]

	xg = round(xi + trc["q_xd"].sum(), 6)
	yg = round(yi + trc["q_yd"].sum(), 6)

	return xg, yg

g = translate_point(-52.79224, 47.6006, "001")

dfs["coords"] = dfs.apply(lambda x: translate_point(x['long'], x['lat'], x["cmaca_code"]), axis=1)

dfs['geometry'] = dfs.coords.apply(Point)
dfs = gpd.GeoDataFrame(dfs,crs=4326)

dfs = dfs[["cmaca_code","ctuid","eauid","pop_count","pt_type","geometry"]]

print(dfs)
