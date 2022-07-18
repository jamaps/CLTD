import pandas as pd
import geopandas as gpd

in_file = "data/DLI_1996_Census_BF_Eng_Nat_bf/geoportal/DLI_1996_Census_BF_Eng_Nat_bf.shp"

df = gpd.read_file(in_file)

tr = pd.read_file("translate_table.csv")

print(df.columns)

df = df[["cmaca_code","ct_name","eauid","pop_count","dwe_count","long", "lat"]]

df = df.dropna(subset = ["cmaca_code"]) 

print(df)

print(tf)