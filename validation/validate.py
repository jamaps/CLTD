import pandas as pd

df = pd.read_csv("ct_2021_with_SCadjusted.csv")[["ctuid_2021","Population_2016","Population_2021"]]

dfa = pd.read_csv("data_from_2016_into_2021_CTs.csv")

dfc = pd.read_csv("ct_2016_2021.csv")


dfcm = dfc.groupby('target_ctuid').agg({'w_pop': ['min']})
dfcm.reset_index(inplace=True)
dfcm.columns = ['target_ctuid', 'min_w']
print(dfcm)

df = pd.merge(df, dfa, how='left', left_on = "ctuid_2021", right_on="target_ctuid")

df["dif"] = df["Population_2016"] - df["w_pop_2016"]

df = pd.merge(df, dfcm, left_on = "ctuid_2021", right_on="target_ctuid")

print(df)

# remove out those that overlap new areas, since we don't know the pop there

dfs = df[df['min_w'] > -1]

print(dfs)

print(dfs.corr())

dfs.to_csv("export_2016_in_2021.csv")