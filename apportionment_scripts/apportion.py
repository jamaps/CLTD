# apportions data from source tracts to target tracts using an apportionment table

import csv
import sys
import math
import pandas as pd
import numpy

# the apportionment table
crosswalk_csv = 'cw_06_to_16_ct.csv'

# the csv with source tract data to apportioned
data_csv = "06_ct_in.csv"

# the name of the field pertaining to the ctuid in data_csv
ctuidcol = "ctuid"

# the field names of data to be apportioned, and their data type
# this example apportions a count of visible minority and average income variables
header = [
    ["total_pop",'t'],
    ["vis_min_pop", 'c'],
    ["avg_inc", 'a', 't'],
]
# t is a count, that connects an average, rate, precent, etc.
# c is a regular count
# a is an average, rate, precent, etc.


# inputting the apportionment table into a pandas data frame
cw = []
with open(crosswalk_csv, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        cw.append(row)
cwpanda = pd.DataFrame.from_records(cw, columns=['sct','tct','w','f'])

# create output dataframe = of just the target CTs
target = cwpanda.groupby(['tct'])

# grabbing a dataframe of the just the target ctuid for future joining
target_u = []
target_array = []
c = 0
for row in cw:
    if row[1] not in target_u:
        target_u.append(row[1])
        target_array.append([c,row[1]])
        c += 1
target = pd.DataFrame.from_records(target_array, columns=['c','tct'])
print target


# apportioning the data >
# loop over each variable that we want to apportion
for h in header:

    # for apportioning count data :)
    if h[1] == 'c' or h[1] == 't':
        apdata = []
        # grabbing dta to apportion
        with open(data_csv, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                try:
                    apdata.append([row[ctuidcol], float(row[h[0]])])
                except:
                    None
        # convert to dataframe
        toapp = pd.DataFrame.from_records(apdata, columns=['ctuid',h[0]])
        # grab apportion table
        cwwork = cwpanda
        # join with variable on source ct
        cwwork = cwwork.set_index('sct').join(toapp.set_index('ctuid'))
        # drop NAs
        cwwork = cwwork.dropna()
        # multiply variable by weight = e.g. y_s * w_s,t
        cwwork['wv'] = cwwork['w'].astype('float') * cwwork[h[0]].astype('int')
        # group by target ct, summing the weights
        cwwork = cwwork.groupby(['tct'])['wv'].sum()
        cwwork = cwwork.to_frame()
        # adding in the lable
        cwwork.columns=[h[0]]
        # join with the output target ct table
        target = target.join(cwwork, on='tct')
        print target

    # for apportioning averages, rates, percents, etc.
    if h[1] == 'a':
        # find the pop variable the average/percent refers to
        for ht in header:
            if ht[1] == 't':
                totvar = ht[0]
        # grabbing data to apportion
        apdata = []
        with open(data_csv, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # make sure grab the varirable and its count partner
                try:
                    apdata.append([row[ctuidcol], float(row[h[0]]), float(row[totvar])])
                except:
                    None
        # converting to a data frame
        toapp = pd.DataFrame.from_records(apdata, columns=['ctuid',h[0],totvar])
        # grabbing the apportionment table
        cwwork = cwpanda
        cwwork = cwwork.set_index('sct').join(toapp.set_index('ctuid'))
        # droping NA
        cwwork = cwwork.dropna()
        # compute the apportionment of the count p_s * w_st
        cwwork['wv'] = cwwork['w'].astype('float') * cwwork[totvar].astype('int')
        # compute the apporitonment of the total of the variable a_s * p_s * w_st
        cwwork['awv'] = cwwork['w'].astype('float') * cwwork[h[0]].astype('int') * cwwork[totvar].astype('int')
        # group by target tract summing the apporioned variables
        cwwork = cwwork.groupby(['tct'])['wv','awv'].sum()
        # divding to compute apportioned variable
        cwwork[h[0]] = cwwork['awv'].astype('float') / cwwork['wv'].astype('float')
        # drop unneeded columns
        cwwork = cwwork.drop('wv', axis=1)
        cwwork = cwwork.drop('awv', axis=1)
        # join to output file
        target = target.join(cwwork, on='tct')
        print target


# dropping na if you want, if not it will return every CT in Canada
target = target.dropna()
# drop unecessary column
target = target.drop('c', axis=1)
print target

# wrting to csv
target.to_csv('06_inc_vis_data.csv')


################
