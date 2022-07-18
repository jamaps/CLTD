import pandas as pd
import geopandas as gpd
from sqlalchemy import create_engine  

db_connection_url = "postgresql://postgres:postgres@localhost:5432/census"
con = create_engine(db_connection_url)  

# get ct pop from EA file in db

sql = "SELECT * FROM pop_ct_1996"
dfd = pd.read_sql(sql, con)  


# load in block face points, remove unneeded cols

in_file = "data/DLI_1996_Census_BF_Eng_Nat_bf/geoportal/DLI_1996_Census_BF_Eng_Nat_bf.shp"
df = gpd.read_file(in_file)
df["ctuid"] = df["cmaca_code"] + df["ct_name"]
df = df[["cmaca_code","ctuid","eauid","pop_count","dwe_count","long", "lat"]]
df = df.dropna(subset = ["cmaca_code"]) 
df['pop_count'] = df['pop_count'].astype(int)
df['dwe_count'] = df['dwe_count'].astype(int)


# get total pop in block face, to see whats missing

dfd = dfd.merge(df.groupby(['ctuid'])['pop_count'].sum().reset_index(), how="left", on="ctuid")

# then remove the incomplete CTs 

dfctea = dfd[(dfd["ct_pop"] > dfd["pop_count"]) | (dfd["pop_count"].isna())]["ctuid"].tolist()
df = df[~df["ctuid"].isin(dfctea)])





tr = pd.read_csv("translate_table.csv", dtype={'cma': 'str'} )
