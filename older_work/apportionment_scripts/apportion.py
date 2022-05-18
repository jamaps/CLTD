# example of apportioning data from source tracts to target tracts using an apportionment (i.e. crosswalk) table

import csv
import pandas as pd

# the apportionment table
crosswalk_csv = 'cw_86_to_16_ct.csv'

# the csv with source tract data to apportioned
data_csv = 'data_in_1986_CTs.csv'

# the name of the field pertaining to the ctuid in data_csv
ctuidcol = "ctuid"

# names of columns we ewant ot apportion
fields = [
    "population",
    "dwellings",
    "recent_immigrants"
]

# output file name
output_file_name = 'data_from_1986_into_2016_CTs.csv'



# read in the data
df = pd.read_csv(data_csv)

# read in crosswalk table
cw = pd.read_csv(crosswalk_csv)

# joining the two input tables
merge_cw_df = cw.merge(df, how = "inner", left_on = "ctuid_s", right_on = ctuidcol)

# loop over each field, multiplying by the apportionment weight
output_fields = []
for f in fields:
    print(f)
    merge_cw_df["w_" + f] = merge_cw_df["w"] * merge_cw_df[f]
    output_fields.append("w_" + f)
	
# group by the target census tracts, summing by the wanted fields
output_data = merge_cw_df.groupby(["ctuid_t"]).sum()
output_data = output_data[output_fields]

# write to file
output_data.to_csv(output_file_name)



