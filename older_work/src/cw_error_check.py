# script for validating crosswalk files
# by checking apportioned population counts with adjusted counts
# and estimating error

import csv
from operator import itemgetter
import sys
import math

# inputs
crosswalk_csv = 'out_cw_v5/cw_91_to_96_ct.csv' #'out_cw_v4/cwf_11_to_16_ct.csv'
pairs_csv = 'ct_pop_totals/pairs_1991_to_1996.csv'
ct_pop_from_csv = 'ct_pop_totals/ct_1991_pop.csv'

# arrays for storing data and analysis
ct_pop_from = [] # source boundaries with population
crosswalk = [] # crosswalk table
pairs = [] # target boundaries with source & target population

print crosswalk_csv
print "----------------------"
print "----------------------"

# add in three files

# add in the crosswalk
with open(crosswalk_csv, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        crosswalk.append(row)

# open up pairs and append
with open(pairs_csv, 'r') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        # remove the cma summary rows
        if '0000.00' not in row['ctuid96']:
            pairs.append([row['ctuid96'],row['pop1991'],row['pop1996']])

# add in pop counts for source CT (pop,ctuid)
with open(ct_pop_from_csv, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:

        try:
            popctfrom = int(float(row[0]))

            ct_pop_from.append([popctfrom,row[1]])
        except:
            ct_pop_from.append([0,row[1]])

# print len of each
print "crosswalk length : ", len(crosswalk)
print "target count : ", len(pairs)
print "source count : ", len(ct_pop_from)



# new lists for anlaysis
pre_dissolve = [] # will not include newly formed tracts
# in form of [population/data, target uid]

from_total_pop = []
to_total = []
no_from_ct = []
from_total = []
gid = 1
# loop over the crosswalk - multiplying data by the weight
for row in crosswalk:
    # if the target zone or the weight is '-1'
    if row[2] != '-1' or row[1] != '-1':
        # loop over the source census tract-pop array

        for ct in ct_pop_from:

            # if the source census tracts are equal
            if row[0] == ct[1]:

                # create unique ID
                gid += 1
                # compute population to be allocated to target
                pop = float(row[2]) * float(ct[0])

                # append that to the target, and include a unique ID
                pre_dissolve.append([pop, row[1],gid])
                from_total_pop.append(pop)
    if row[1] not in to_total and row[1] != '-1':
        to_total.append(row[1])
    if row[0] not in from_total and row[0] != '-1':
        from_total.append(row[0])
    if row[1] not in no_from_ct and row[0] == '-1':
        no_from_ct.append(row[1])

# print lenght of crosswalk outputs
print "----------------------"
print "cw pre dissolve length : ", len(pre_dissolve)
print "(will be lower because of CT expansion)"
print "cw target total : ", len(to_total)
print "cw source total : ", len(from_total)

# confirming pop counts
print "----------------------"
# these should be the same:
pt = 0
for pp in from_total_pop:
    pt = pt + pp
print "cw source pop total : ", pt

pt = 0
for pp in ct_pop_from:
    pt = pt + int(pp[0])
print "source pop total : ", pt
print "----------------------"
# okay

# sort that list by the id of target - used for setting up dissolving
pre_dissolve = sorted(pre_dissolve,key=itemgetter(1))

# nifty function for finding items before or after while looping http://stackoverflow.com/questions/1011938/python-previous-and-next-values-inside-a-loop
def prenext(l,v) :
   i=l.index(v)
   return l[i-1] if i>0 else None,l[i+1] if i<len(l)-1 else None

# print prenext(pre_dissolve,pre_dissolve[0])[0][0]


# dissolving the crosswalk by target id
post_dissolve = [] # output dissolved values
earlier = 'Dr. NULL' # an empty string
i = 0 # counter
elses = 0 # count of incorectomungos
imax = len(pre_dissolve) # maximum length of loop
c = 0 # variable for summing data
for row in pre_dissolve:

    pop = int(row[0]) # pop for current row
    ct = row[1] # ctuid for current row

    # any of the 'middle' rows
    if i > 0 and i < imax-1:

        # grab values for pervious and next ctuid and population in the array
        pre_ct = prenext(pre_dissolve,pre_dissolve[i])[0][1]
        pos_ct = prenext(pre_dissolve,pre_dissolve[i])[1][1]
        pre_pop = prenext(pre_dissolve,pre_dissolve[i])[0][0]
        pos_pop = prenext(pre_dissolve,pre_dissolve[i])[1][0]

        # if a unique uid, no need to dissolve
        if ct != pre_ct and ct != pos_ct:
            post_dissolve.append(row)
            # reset data variable
            c = 0

        # if equal to previous, does not equal to next
        elif ct == pre_ct and ct != pos_ct:
            # sum data and append
            c = c + pre_pop + pop
            post_dissolve.append([c,ct])

        # not equal to previous, and equals next
        elif ct != pre_ct and ct == pos_ct:
            # reset counter
            c = 0

        # equals previous and next
        elif ct == pre_ct and ct == pos_ct:
            # add pre_pop to counter
            c = c + pre_pop

        # if something didn't work, count it!
        else:
            elses += 1

    # for the first and last rows
    else:
        post_dissolve.append(row)

    i += 1
    # if i > 50:
    #     break

# printing some results
print "error count : ", elses
print "length of post dissolve to target : ", len(post_dissolve)
print "(should be less than target count because of new CTs)"
print "----------------------"

# the output (post dissolve) can be written to csv if needed!




# here we compute percent errors for each

w = 0
neg = 0 # count of negative target rows (i.e. disappearing CTs)
percent_list = []
dif_list = []
dif_list_squared = []
# loop over final output (i.e. post dissolve)
print "dif, int pop, SC pop"
for row in post_dissolve:

    ct = row[1]


    # loop over the target CTs from stats can with adjusted population
    for pair in pairs:

        # the second if is comparing with -1 source cts
        if pair[0] == ct and ct not in no_from_ct:
            w += 1
            try:
                stat_can_pop = float(pair[1])
            except:
                stat_can_pop = 0
            my_pop = float(row[0])
            dif = stat_can_pop - my_pop
            dif_list.append(dif)
            dif_list_squared.append(dif ** 2)

            if dif > 500:
                print dif, row[0], stat_can_pop, row[1]
            #print '-----------------'
            #print ct
            if stat_can_pop > 0:
                #print (my_pop - stat_can_pop) / stat_can_pop
                # append ctuid and percent error
                percent_list.append([ct,(my_pop - stat_can_pop) / stat_can_pop])
            elif stat_can_pop == 0 and my_pop == 0:
                #print 0
                # both 0, so percent error is 0
                percent_list.append([ct,0])
            else:
                #print (my_pop - stat_can_pop) / my_pop
                percent_list.append(percent_list.append([ct,1]))
            break
    # instances where population is joined to untracted area
    if ct == '-1':
        neg += 1

# these should total len(post_dissolve)
print "----------------------"
print "count of pairs matched : ", w
print "(should be same as target count)"
print "count of disappearing CTs : ", neg
print "----------------------"


abs_percent_list = []
for val in percent_list:
    try:
        abs_percent_list.append(abs(val[1]))
    except:
        None



print "average error for all targets : ", sum(abs_percent_list)/len(abs_percent_list)
print "----------------------"


# binning errors by frequency - could probably set this up via sorting by flags as well!
val_0 = []
val_0_1 = []
val_1_3 = []
val_3_5 = []
val_5_10 = []
val_10 = []
# for val in abs_percent_list:
#     if val < 0.0001:
#         val_0.append(val)
#     elif val >= 0.0001 and val < 1:
#         val_0_1.append(val)
#     elif val >= 1 and val < 3:
#         val_1_3.append(val)
#     elif val >= 3 and val < 5:
#         val_3_5.append(val)
#     elif val >= 5 and val < 10:
#         val_5_10.append(val)
#     else:
#         val_10.append(val)

for val in abs_percent_list:
    if val < 0.0001:
        val_0.append(val)
    elif val >= 0.0001 and val < 0.01:
        val_0_1.append(val)
    elif val >= 0.01 and val < 0.03:
        val_1_3.append(val)
    elif val >= 0.03 and val < 0.05:
        val_3_5.append(val)
    elif val >= 0.05 and val < 0.1:
        val_5_10.append(val)
    else:
        val_10.append(val)

# printing above bins
print '0 ---', float(len(val_0)) / float(len(abs_percent_list))
print '0 to 1 ---', float(len(val_0_1)) / float(len(abs_percent_list))
print '1 to 3 ---', float(len(val_1_3)) / float(len(abs_percent_list))
print '3 to 5 ---', float(len(val_3_5)) / float(len(abs_percent_list))
print '5 to 10 ---', float(len(val_5_10)) / float(len(abs_percent_list))
print '10 +  ---', float(len(val_10)) / float(len(abs_percent_list))

# making sure the above sum to 1 !
print float(len(val_0)) / float(len(abs_percent_list)) + float(len(val_0_1)) / float(len(abs_percent_list)) + float(len(val_1_3)) / float(len(abs_percent_list)) + float(len(val_3_5)) / float(len(abs_percent_list)) + float(len(val_5_10)) / float(len(abs_percent_list)) + float(len(val_10)) / float(len(abs_percent_list))


print "----------------------"
val_0 = []
val_1_5 = []
val_6_25 = []
val_26_100 = []
val_101_499 = []
val_500 = []
val_ext = []
for val in dif_list:
    q = abs(round(val))
    if q == 0:
        val_0.append(val)
    elif q >= 1 and q <= 5:
        val_1_5.append(q)
    elif q >= 6 and q <= 25:
        val_6_25.append(q)
    elif q >= 26 and q <= 100:
        val_26_100.append(q)
    elif q >= 101 and q < 500:
        val_101_499.append(q)
    elif q >= 500:
        val_500.append(val)
    else:
        val_ext.append(val)

# printing above bins
print '0 ---', float(len(val_0)) / float(len(dif_list))
print '1 to 5 ---', float(len(val_1_5)) / float(len(dif_list))
print '6 to 25 ---', float(len(val_6_25)) / float(len(dif_list))
print '26 to 100 ---', float(len(val_26_100)) / float(len(dif_list))
print '101 to 499 ---', float(len(val_101_499)) / float(len(dif_list))
print '500 +  ---', float(len(val_500)) / float(len(dif_list))
print 'extra  ---', float(len(val_ext)) / float(len(dif_list))


print "----------------------"
print 'RMSE'
print math.sqrt(sum(dif_list_squared)/len(dif_list_squared))
