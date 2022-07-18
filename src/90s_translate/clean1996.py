import pandas as pd
import geopandas as gpd

in_file = "data/DLI_1996_Census_BF_Eng_Nat_bf/geoportal/DLI_1996_Census_BF_Eng_Nat_bf.shp"

df = gpd.read_file(in_file)

tr = pd.read_csv("translate_table.csv", dtype={'cma': 'str'} )

print(df.columns)

df["ctuid"] = df["cmaca_code"] + df["ct_name"]

df = df[["cmaca_code","ctuid","eauid","pop_count","dwe_count","long", "lat"]]

df = df.dropna(subset = ["cmaca_code"]) 

df['pop_count'] = df['pop_count'].astype(int)
df['dwe_count'] = df['dwe_count'].astype(int)

print(df)

dfs = df.groupby(['ctuid'])['pop_count'].sum().reset_index()

print(dfs)