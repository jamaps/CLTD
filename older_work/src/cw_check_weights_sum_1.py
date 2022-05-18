import pandas as pd
import csv
import sys
from operator import itemgetter

# input crosswalk csv file
crosswalk_csv = 'cwxd_16_to_01_ct.csv'

# gen array of where the source is a ctuid
cw_neg = []
cw_in = []
with open(crosswalk_csv, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        if row[0] == '-1':# or row[1] == '-1':
            cw_neg.append([row[0],row[1],float(row[2])])
        else:
            cw_in.append([row[0],row[1],float(row[2])])

print len(cw_in)

# into pandas data frame
df = pd.DataFrame(cw_in)
c = df.groupby(0)[2].agg({"number": 'size'}).join(df.groupby(0).sum())
c.columns = ['a', 'b']
print c[c.b > 1]

#
