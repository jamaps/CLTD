# Canadian Longitudinal Census Tract Database (CLTD)

This repository includes code to bridge Canadian historical census tract data to a common set of geographic boundaries.


### crosswalk_tables

A set of .csv tables which link boundary identifiers between years using a set of apportionment weights. Data is organized into four fields, the first is the ID of the source census tract, the second is the ID of the target census tract, the third is a weight indicating the amount of data that should be apportioned from the source to the target, and the forth is a flag indicating the relationship (1 = no change, 2 = merge, 3 = split, or 4 = many-to-many)


### apportionment_scripts

Example scripts that use these tables to apportion data linked to census tracts from a source year to a target year (e.g. from 1971 to 2016)


### src

Contains the code used to generate and validate the crosswalk tables. This utilizes a combination of population weighting, area weighting, and dasymetric mapping approaches to minimize error when boundaries change over time.


### Further Information

A paper detailing this work is currently being prepared for The Canadian Geographer (will add link once it is in press)

```
@article{allentaylor2018,
 author    = "Allen, Jeff and Taylor, Zack",
 title     = "A new tool for neighbourhood change research: The Canadian longitudinal census tract database, 1971–2016",
 journal   = "The Canadian Geographer"
 year      =  2018,
}
```
