import pandas as pd

df = pd.read_csv("ctuid_ctpct_1981.csv", dtype = 'str')

df["ctuid"] = df["cma"] + "0" + df["ct"]

df = df[["ctuid","ct_pct"]]

df.to_csv("ctuid_ctpct_1981_min.csv", index=False)