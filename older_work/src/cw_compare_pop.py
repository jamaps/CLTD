# reads crosswalk file
# and computes the total population
# from data and from crosswalk

# the above 2 sums should be equal
# if not, investigate!

import csv

crosswalk_csv = 'cwxd_16_to_01_ct.csv'
ct_pop_from_csv = 'ct_pop_totals/ct_2016_pop.csv'

# adding the above into arrays
crosswalk = []
ct_pop_from = []

ct_from_count = []

with open(crosswalk_csv, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        crosswalk.append(row)
        if row[0] not in ct_from_count:
            ct_from_count.append(row[0])

with open(ct_pop_from_csv, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        ct_pop_from.append([row[0],row[1]]) # should be pop, ct

# print the length of each table for fun
print len(crosswalk), "crosswalk length"
print len(ct_pop_from), "number of source CT"
print len(ct_from_count), "crosswalk source CT"

# summing the total CT pop from
ct_from_total = 0
for ct in ct_pop_from:
    #print ct
    try:
        ct_from_total = ct_from_total + float(ct[0])
    except:
        None
        #print ct[1]
print ct_from_total

# summing the total CT pop using the weights in the crosswalk
s = float(0)
for row in crosswalk:
    if row[0] != '-1':
        for ct in ct_pop_from:
            if str(row[0]) == str(ct[1]) and ct[0] != '':
                s = s + float(ct[0]) * float(row[2])
            

print s
