# updates the sum of weights by source tract to 1


import pandas as pd
import csv
import sys
from operator import itemgetter

# input crosswalk csv file
crosswalk_csv = 'cwxd_16_to_01_ct.csv'
out_cw = 'cwxd_16_to_01_ct_fixed.csv'


# open the csv

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

# convert to dataframe and group by source = counting and summing the weights
df = pd.DataFrame(cw_in)
c = df.groupby(0)[2].agg({"number": 'size'}).join(df.groupby(0).sum())
i = c.index.values.tolist()
print len(i)
m = c.as_matrix()
print len(m)

# if differt lens, fail it
if len(m) != len(i):
    sys.exit("failed since lengths were different")

# put into a normal python object
source_groups = []
q = 0
while q < len(m):
    out_row = [i[q],m[q][0],m[q][1]]
    # print out_row
    source_groups.append(out_row)
    q += 1
print len(source_groups)

# calc differnece and allocation numbers
source_adders = []
for row in source_groups:
    sid = row[0]
    count = row[1]
    total = float(row[2])
    dif = float(1 - total)
    allocator = dif / float(count)
    out_row = [sid,count,total,dif,allocator]
    source_adders.append(out_row)
print len(source_adders)

# add to weights of new crosswalk
new_cw = []
for cw in cw_in:
    for row in source_adders:
        if row[0] == cw[0]:
            if row[2] > 0.80:
                new_weight = cw[2] + row[4]
            else:
                new_weight = cw[2]
                neg_row = [cw[0],'-1',row[3]]
                new_cw.append(neg_row)
            out_row = [cw[0],cw[1],new_weight]
            new_cw.append(out_row)
            break
# print len(new_cw)
#
# # get source ids
# sids = []
# with open('ct_pop_totals/' + source_ids, 'r') as csvfile:
#     reader = csv.reader(csvfile)
#     for row in reader:
#         sids.append(row[1])
# print len(sids)
#
# tids = []
# with open('ct_pop_totals/' + target_ids, 'r') as csvfile:
#     reader = csv.reader(csvfile)
#     for row in reader:
#         tids.append(row[1])
# print len(tids)
#
# print "meow"

print len(new_cw)
print len(cw_neg)
final_cw = new_cw + cw_neg
print len(final_cw)

with open(out_cw, 'w') as csvfile:
    writer = csv.writer(csvfile)
    for row in final_cw:
        if row[2] < 2:
            writer.writerow(row)

# Works! - still need to add in any missing Source or Targets!

# new_new_cw = []
#
# for sid in sids:
#     for row in new_cw:
#         if si
#     # print c, row
#     if s not in sids:
#         new_new_cw.append([,'-1',1,'1'])
#     if row[1] not in tids:
#         new_new_cw.append(['-1',row[1],'-1','1'])
#     new_new_cw.append(new_cw)
#
# for row in new_new_cw:
#     if row[1] == '-1':
#         print row
#
