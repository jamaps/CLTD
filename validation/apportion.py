# example of apportioning data from source tracts to target tracts using an apportionment (i.e. crosswalk) table

import pandas as pd

# the apportionment table
crosswalk_csv = 'ct_2016_2021.csv'

# the csv with source tract data to apportioned
data_csv = 'ct_2016_pop.csv'

# the name of the field pertaining to the ctuid in data_csv
ctuidcol = "ctuid_2016"

# weight we want to use to apportion
weight = "w_pop"

# names of columns we want to apportion
fields = [
    "pop_2016"
]

# output file name
output_file_name = 'data_from_2016_into_2021_CTs.csv'

# read in the data
df = pd.read_csv(data_csv)

# read in crosswalk table
cw = pd.read_csv(crosswalk_csv)

# joining the two input tables
merge_cw_df = cw.merge(df, how = "inner", left_on = "source_ctuid", right_on = ctuidcol)

# loop over each field, multiplying by the apportionment weight
output_fields = []
for f in fields:
    print(f)
    merge_cw_df["w_" + f] = merge_cw_df[weight] * merge_cw_df[f]
    output_fields.append("w_" + f)
	
# group by the target census tracts, summing by the wanted fields
output_data = merge_cw_df.groupby(["target_ctuid"]).sum()
output_data = output_data[output_fields]

# write to file
output_data.to_csv(output_file_name)
