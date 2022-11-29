import pandas as pd
import geopandas as gpd

df = gpd.read_file("data/ct_71_dissolved_ea.shp")

print(df.nunique())

print(df.groupby(['ctuid71new'])["cmauid_71"].count().sort_values())

print(df.groupby(['source']).count())
