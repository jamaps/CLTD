import pandas as pd
import geopandas as gpd
from shapely.geometry import Point
from sqlalchemy import create_engine  
import random

db_connection_url = "postgresql://postgres:postgres@localhost:5432/census"
con = create_engine(db_connection_url)  


# get ct pop from EA file in db

sql = "SELECT * FROM pop_ct_1991"
dfd = pd.read_sql(sql, con)  


# load in block face points, remove unneeded cols

in_file = "data/DLI_1991_Census_BF_Eng_Nat_bf/geoportal/DLI_1991_Census_BF_Eng_Nat_bf.shp"
df = gpd.read_file(in_file)
df["ctuid"] = df["cmaca_code"] + df["ctpct_name"]
df["eauid"] = df["pr_code"] + df["fed_code"] + df["ea_code"]
df = df[["cmaca_code","ctuid","eauid","pop_count","dwe_count","long", "lat"]]
df = df.dropna(subset = ["cmaca_code"]) 
df['pop_count'] = df['pop_count'].astype(int)
df['dwe_count'] = df['dwe_count'].astype(int)


print(df)

# # get total pop in block face, to see whats missing

# dfd = dfd.merge(df.groupby(['ctuid'])['pop_count'].sum().reset_index(), how="left", on="ctuid")

# # then remove the incomplete CTs 

# dfctea = dfd[(dfd["ct_pop"] > dfd["pop_count"]) | (dfd["pop_count"].isna())]["ctuid"].tolist()
# df = df[~df["ctuid"].isin(dfctea)]


# # select EAs that are still needed

# sql = """
# WITH ea_ct AS 
#     (SELECT
#     coalesce(ea_pop::integer,0) AS ea_pop,
#     coalesce(ea_pri_dwe::integer,0) AS ea_dwe,
# 	RIGHT('00' || prov, 2) || RIGHT('000' || fed, 3) || RIGHT('000' || ea, 3) as eauid,
#     RIGHT('000' || cma_ca::varchar, 3) || RIGHT('000' || ROUND(ct_pct_nam::numeric, 2)::varchar, 7) as ctuid	
#     FROM in_1991_gaf_pt 
#     WHERE cma_ca != '0')
# SELECT
# ea_ct.*, 
# in_1991_dbf_ea.geom
# FROM ea_ct
# LEFT JOIN in_1991_dbf_ea ON ea_ct.eauid::varchar = in_1991_dbf_ea.ea::varchar
# WHERE ea_ct.ctuid IN (SELECT ctuid FROM in_1991_cbf_ct_moved);
# """
# ea = gpd.read_postgis(sql, con)
# ea = ea[ea["ctuid"].isin(dfctea)]



# # generate random points by DA, 1 per 25 population

# eapts = []
# for index, row in ea.iterrows():
# 	try:
# 		points = []
# 		number = int(row["ea_pop"] / 25) + 1
# 		min_x, min_y, max_x, max_y = row["geom"].bounds
# 		i = 0
# 		while i < number:
# 			point = Point(random.uniform(min_x, max_x), random.uniform(min_y, max_y))
# 			if row["geom"].contains(point):
# 				points.append([point.x,point.y])
# 				i += 1
# 		for p in points:
# 			pop = 0.0001 + row["ea_pop"] / number
# 			dwe = 0.0001 + row["ea_dwe"] / number
# 			eapts.append([row["eauid"],row["ctuid"],pop,dwe,p[0],p[1]])
# 	except:
# 		print(index,row)

# eapts = pd.DataFrame(eapts, columns = ['eauid', 'ctuid', 'pop_count', 'dwe_count', 'long', 'lat'])
# eapts["cmaca_code"] = eapts["ctuid"].str[:3]


# # combine the block and ea points

# df["pt_type"] = "bf"
# eapts["pt_type"] = "ea_rand"

# df = pd.concat([df, eapts], axis=0)

# print(df.ctuid.nunique())

# df.to_csv("data/pts_1991.csv", index=False)
