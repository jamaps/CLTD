# generates flags for crosswalk / apportionment tables
# also updates some weights and ids from blanks to -1s

# these are the flags that will be generated
###########################
# 1 - no change (includes renaming CT (e.g. 1971 to 1976/81))
# 2 - many to 1 - combined
# 3 - 1 to many - split
# 4 - many to many
###########################

import csv
import sys
from operator import itemgetter

# input crosswalk csv file
crosswalk_csv = 'cwxd_16_to_01_ct_fixed.csv'
out_flag_crosswalk = 'cwxd_16_to_01_ct.csv'

# open csv and add into an array for pythoning
crosswalk = []
with open(crosswalk_csv, 'r') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        a = row[0]
        b = row[1]
        c = row[2]
        # some returned blanks, update these to '-1'
        if row[0] == '':
            a = "-1"
        if row[1] == '':
            b = "-1"
        if row[2] == '':
            c = "-1"
        crosswalk.append([a,b,c])

# checking if each pair is unqiue
unique_pairs = []
for row in crosswalk:
    unique_pairs.append(row[0] + row[1])
pip = ''
for ip in unique_pairs:
    if ip == pip:
        print ip
        raise ValueError('more than one unique pair')
    pip = ip
    # if prints, then bad, there are more than one pairs

# print crosswalk length for reference
print "-------------------"
print "crosswalk length : ", len(crosswalk)
print "-------------------"

# get list of all sources and target identifiers
source_all = []
target_all = []
for row in crosswalk:
    source_all.append(row[0])
    target_all.append(row[1])

# grabbing lists of unique source identifiers and the occurance of each
source_unique = []
source_count = []
for source in source_all:
    if source not in source_unique:
        source_unique.append(source)
        source_count.append([source,source_all.count(source)])

# should be the same, the total feature count + 1 of the boundary dataset
print "source count plus '-1' : ", len(source_unique)

# grabbing lists of unique source identifiers and the occurance of each
target_unique = []
target_count = []
for target in target_all:
    if target not in target_unique:
        target_unique.append(target)
        target_count.append([target,target_all.count(target)])

# should be the same, the total feature count + 1 of the boundary dataset
print "target count plus '-1' : ", len(target_unique)

print "-------------------"

#
# updating crosswalk table to include proper weights (0 to 1 on singles) and remove no needing 0s on others
crosswalk_update = []
# counts for '-1' in the source anad target
sn = tn = 0
for row in crosswalk:

    # setting variables for each row
    source = row[0]
    target = row[1]
    weight = float(row[2])

    # output row
    qqrow = []
    # new weight if will update
    new_weight = -1

    # loop over source w/ counts
    for s in source_count:

        # matching the loops - if the source uids are equal
        if s[0] == source:

            # if there are multiple source zones
            if s[1] > 1:

                # loop over target w/ counts
                for t in target_count:

                    # matching loops - if target uids are equal
                    if t[0] == target:

                        # if there is only 1 target count
                        if t[1] == 1:

                            # if the weight of the row is 0
                            if weight == 0:

                                # then inlude in the output
                                qqrow = row

            # if there is only 1 source zone
            elif s[1] == 1:

                # now lets loop the target counts
                for t in target_count:

                    # matching the loops
                    if t[0] == target:

                        if target == '-1':

                            if weight < 1:
                                # if the pop was 0, it will return a weight 0, so this updates this to 1
                                # also if it returns 0.99999...999 it'll round to 1 - fixing this postgres data artifact
                                new_weight = 1

                        # if only one target - a 1 to 1 join
                        if t[1] == 1:

                            if weight < 1:
                                # if the pop was 0, it will have weight 0, so this updates to 1
                                # also, if it returns 0.99999...999 it'll round to 1
                                new_weight = 1

                        if t[1] > 1:

                            None
                            # wt = 0
                            # for r in crosswalk:
                            #
                            #     if r[0] == s[0] and r[1] == t[0]:
                            #
                            #         if r[2] != '-1':
                            #             wt = wt + float(r[2])
                            #
                            # if wt == 0:
                            #     print row


                        break

            else:
                raise ValueError('somehow returned count less than 1')

            break

    # whether or not to add an updated weight in the output
    # and update the crosswalk array
    if new_weight == 1:
        crosswalk_update.append([row[0],row[1],'1'])
    else:
        crosswalk_update.append(row)

    # counting neg -1 occurances for reference
    if source == '-1':
        sn += 1
    if target == '-1':
        tn += 1

# print neg -1 occurance counts
print "'-1' source count : ", sn
print "'-1' target count : ", tn
# print reduced crosswalk length
print "reduced crosswalk length : ", len(crosswalk_update)

print "-------------------"
print "-------------------"


# removing rows with weights of 0 - not sure about this yet!
# cwu = []
# for row in crosswalk_update:
#     if row[2] == '0':
#         None
#     else:
#         cwu.append(row)
#
# crosswalk_update = cwu




####################

# re checking source and target lists with the updated crosswalk table - these should have the same counts as before

# checking if each pair is unqiue
unique_pairs = []
for row in crosswalk_update:
    unique_pairs.append(row[0] + row[1])
pip = ''
for ip in unique_pairs:
    if ip == pip:
        print ip
        raise ValueError('more than one unique pair')
    pip = ip
    # if prints, then bad, there are more than one pairs

# check if any arnt in the og source lists
source_ui = source_unique
target_ui = target_unique

# get list of sources and target identifiers
source_all = []
target_all = []
for row in crosswalk_update:
    source_all.append(row[0])
    target_all.append(row[1])

# grabbing lists of unique source identifiers and the occurance of each
source_unique = []
source_count = []
for source in source_all:
    if source not in source_unique:
        source_unique.append(source)
        source_count.append([source,source_all.count(source)])

# should be the same, the total feature count + 1 of the boundary dataset
print "source count plus '-1' : ", len(source_unique)


# grabbing lists of unique source identifiers and the occurance of each
target_unique = []
target_count = []
for target in target_all:
    if target not in target_unique:
        target_unique.append(target)
        target_count.append([target,target_all.count(target)])

# should be the same, the total feature count + 1 of the boundary dataset
print "target count plus '-1' : ", len(target_unique)


# if not counts equal to previous iteration, print which and quit
if len(source_ui) != len(source_unique):
    print 's'
    for s in source_ui:
        if s not in source_unique:
            print s
    sys.exit("source counts not equal!")
if len(target_ui) != len(target_unique):
    print 't'
    for t in target_ui:
        if t not in target_unique:
            print t
    sys.exit("target counts not equal!")

# print a line break !
print "-------------------"



################
## okay, the crosswalk is good now, lets start adding in the flags!
crosswalk_flag_v1 = []
for row in crosswalk_update:

    # set up variables
    source = row[0]
    target = row[1]
    weight = float(row[2])
    flag = -1

    if source != '-1' and target != '-1':

        for t in target_count:

            if t[0] == target:

                for s in source_count:

                    if s[0] == source:

                        if t[1] == 1:

                            if s[1] == 1:

                                ########
                                flag = 1 # NO CHANGE
                                ########

                            elif s[1] > 1:

                                u = 0

                                for r in crosswalk_update:

                                    if source == r[0]:

                                        for ut in target_count:

                                            if ut[0] == r[1]:

                                                if ut[1] > 1 or r[2] == '-1':

                                                    u = 1


                                if u == 0:

                                    ########
                                    flag = 3 # SPLIT
                                    ########

                                else:

                                    ########
                                    flag = 4 # M to M
                                    ########


                            else:
                                raise ValueError('ERROR Source count less than one')


                        elif t[1] > 1:

                            if s[1] == 1:

                                u = 0

                                for r in crosswalk_update:

                                    if target == r[1]:

                                        for us in source_count:

                                            if us[0] == r[0]:

                                                if us[1] > 1:

                                                    u = 1


                                if u == 0:

                                    ########
                                    flag = 2 # MERGE
                                    ########

                                else:

                                    ########
                                    flag = 4 # MANY TO MANY
                                    ########

                            elif s[1] > 1:

                                ########
                                flag = 4 # MANY TO MANY
                                ########

                            else:
                                raise ValueError('ERROR Source count less than one')

                        else:
                            raise ValueError('ERROR Target count less than one')


    elif source == '-1':

        ########
        flag = 1 # NEW NEW
        ########

    elif target == '-1':

        ########
        flag = 1 # REMOVED
        ########


    # checking if flag did not wave
    if flag == -1:
        raise ValueError('ERROR Target count less than one')

    crosswalk_flag_v1.append(row + [flag])




print "flags iter 1 crosswalk length : ", len(crosswalk_flag_v1)
print "-------------------"




# grab a list of the just the sources and their assoicated flags
source_flag_combos = []
for row in crosswalk_flag_v1:
    sf_combo = [row[0],row[3]]
    source_flag_combos.append(sf_combo)

# sort that list so it goes by id, then 1,2,3,4
source_flag_combos = sorted(source_flag_combos, key=itemgetter(0,1))

# print it
print "source-flag list length : ", len(source_flag_combos)
print "-------------------"

# for row in source_flag_combos:
#     print row

# trimming down the source-flag table to unique sources
# also removes any pseudo non-many-to-many outputs
source_flag_trim = []
source_just = []
for row in source_flag_combos:
    if row[0] not in source_just:
        source_just.append(row[0])
        source_flag_trim.append(row)
    else:
        # delete the previous and add the updated, e.g. many to many will be last!
        del source_flag_trim[-1]
        source_flag_trim.append(row)

# lengths should be the same as og source list
print "source trim lengths : ", len(source_just), len(source_flag_trim)



# updating crosswalk with properer flags from source trim list
crosswalk_flag_v2 = []
for row in crosswalk_update:

    for sf in source_flag_trim:

        if row[0] == sf[0]:

            flag = sf[1]

            break

    crosswalk_flag_v2.append(row + [flag])


print "flags iter 2 crosswalk length : ", len(crosswalk_flag_v2)
print "-------------------"



# updating the source so source == -1 as not all areas to not all be 3, some could have expanded, etc.
crosswalk_flag_v3 = []

for row in crosswalk_flag_v2:

    new_flag = 0

    if row[0] == '-1':

        for t in target_count:

            if row[1] == t[0]:

                if t[1] == 1:

                    new_flag = 1

                else:

                    u = 0

                    # if it just expands

                    for r in crosswalk_update:

                        if row[1] == r[1]:

                            if r[2] == '1':

                                u = u + 1


                    if u > 0:

                        ########
                        new_flag = 2 # MERGE
                        ########

                    # if its part of a many to many

                    else:

                        ########
                        new_flag = 4 # MANY TO MANY
                        ########



    if new_flag == 0:

        new_flag = row[3]

    crosswalk_flag_v3.append([row[0],row[1],row[2], new_flag])


source_final = []
final_flags = []

# grab list of final flags for non -1 rows
for row in crosswalk_flag_v3:
    if row[0] not in source_final and row[0] != '-1':
        source_final.append(row[0])
        final_flags.append(row[3])

# grab list of new targets -1 and their flags
new_targets = []
new_target_flags = []
for row in crosswalk_flag_v3:
    if row[0] == '-1':
        new_targets.append(row[0])
        new_target_flags.append(row[3])

not_fully_new_target = []
for row in crosswalk_flag_v3:
    if (row[3] != 1) and row[0] == '-1':
        not_fully_new_target.append(row)

# #
# crosswalk_flag_v4 = []
# for row in crosswalk_flag_v3:
#     for nfnt in not_fully_new_target:
#         if row[1] == nfnt[1]:
#             print row


# print final counts
print "final source count : ", len(source_final), len(final_flags)
print "flags iter 3 crosswalk length : ", len(crosswalk_flag_v3)
print "-------------------"

# and number of flags for each
print 1, final_flags.count(1)
print 2, final_flags.count(2)
print 3, final_flags.count(3)
print 4, final_flags.count(4)
print "=", len(final_flags)
print "-------------------"

print "completely new count : ", len(new_targets) - len(not_fully_new_target)

print "-------------------"

#write it!
with open(out_flag_crosswalk, 'w') as csvfile:
    writer = csv.writer(csvfile)
    for row in crosswalk_flag_v3:
        writer.writerow(row)


###########################
# fin
