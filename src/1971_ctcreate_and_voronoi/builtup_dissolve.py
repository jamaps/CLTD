import pandas as pd
import geopandas as gpd
import os

folder = "data/built-up/"
out_name = "built_up_1971.shp"

files = os.listdir(folder)

shps = []
for file in files:
    if file.endswith(".shp"):
        shps.append(file)

gdfs = []
for shp in shps:
    gdf = gpd.read_file(folder + shp)
    # optional filter columns
    gdf = gdf[["Code","CMA_RMR","geometry"]]
    gdfs.append(gdf)

gdfs = pd.concat(gdfs)
gdfs.to_file(folder + out_name)
