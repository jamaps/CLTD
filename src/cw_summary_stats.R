# summary statistics for crosswalk tables

setwd("~/Dropbox/work/census/revisions_work")

in_cw <- read.csv("out_cw_v4/cwf_96_to_01_ct.csv", header = FALSE)
in_area_pop_data <- read.csv("ct_pop_totals/year_area_pop/1996_area_pop.csv")
cmaid <- read.csv("ct_pop_totals/year_area_pop/cma_id.csv")


# data frame of cma, ct, flag
df <- in_cw[,c("V1", "V4")]
df <- unique(df)
df <- subset(df, df$V1 > -1)
df$cma <- floor(df$V1 / 10000)
colnames(df) <- c("ctuid","flag","cma")
table(df$flag) # check for merge

# summarizing ct counts by type and cma
dfs <- as.data.frame.matrix(table(df$cma,df$flag))
dfs <- rbind(dfs,colSums(dfs))
colnames(dfs) <- c("count_ct_nochange","count_ct_split","count_ct_manytomany")


dfsp <- dfs / rowSums(dfs)
colnames(dfsp) <- c("percent_ct_nochange","percent_ct_split","percent_ct_manytomany")
dfsp$percent_nochange = round(as.numeric(dfsp$percent_ct_nochange), digits = 2)
dfsp$percent_split = round(dfsp$percent_ct_split, digits = 2)
dfsp$percent_manytomany = round(dfsp$percent_ct_manytomany, digits = 2)


# joining area to table
d <- merge(df, in_area_pop_data)
dfa <- as.data.frame.matrix(xtabs(area~cma+flag, d))
dfa <- rbind(dfa,colSums(dfa))
dfa$sum <- rowSums(dfa)
dfa$`1` = round(dfa$`1` / dfa$sum, digits = 2)
dfa$`3` = round(dfa$`3` / dfa$sum, digits = 2)
dfa$`4` = round(dfa$`4` / dfa$sum, digits = 2)
colnames(dfa) <- c("perc_area_nochange","perc_area_split","perc_area_manytomany","sum")
dfa <- dfa[,c("perc_area_nochange","perc_area_split","perc_area_manytomany")]


# population to table
d <- merge(df, in_area_pop_data)
dfp <- as.data.frame.matrix(xtabs(pop~cma+flag, d))
dfp <- rbind(dfp,colSums(dfp))
dfp$sum <- rowSums(dfp)
dfp$`1` = round(dfp$`1` / dfp$sum, digits = 2)
dfp$`3` = round(dfp$`3` / dfp$sum, digits = 2)
dfp$`4` = round(dfp$`4` / dfp$sum, digits = 2)
colnames(dfp) <- c("perc_pop_nochange","perc_pop_split","perc_pop_manytomany","sum")
dfp <- dfp[,c("perc_pop_nochange","perc_pop_split","perc_pop_manytomany")]


###
dfo <- cbind(dfs,dfsp,dfp,dfa)

dfo <- merge(cmaid, dfo, by.x = "CMAUID", by.y = "row.names", all.y = TRUE)



dfo$CMANAME <- as.character(dfo$CMANAME)
dfo$CMANAME[is.na(dfo$CMANAME)] <- "TOTAL"
dfo$CMAUID[dfo$CMANAME == "TOTAL"] <- 0
dfo <- dfo[with(dfo, order(CMAUID)), ]

write.csv(dfo, file = "out_cw_summary_tables/summary_96_to_01.csv", row.names = FALSE)

#
