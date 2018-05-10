# Canadian Longitudinal Tract Database (CLTD)

This repository includes code to bridge Canadian historical census tract data to a common set of geographic boundaries.

The data and a manual describing its use is available on Dataverse: http://dx.doi.org/10.5683/SP/EUG3DT

A paper detailing this work has recently been published in The Canadian Geographer

```
@article{allentaylor2018,
  title={A new tool for neighbourhood change research: The Canadian Longitudinal Census Tract Database, 1971--2016},
  author={Allen, Jeff and Taylor, Zack},
  journal={The Canadian Geographer/Le G{\'e}ographe canadien},
  year={2018},
  publisher={Wiley Online Library},
  url={https://doi.org/10.1111/cag.12467}
}
```


### apportionment_scripts

Example scripts that use these tables to apportion data linked to census tracts from a source year to a target year (e.g. from 1971 to 2016)

### src

Contains the code used to generate and validate the crosswalk tables. This utilizes a combination of population weighting, area weighting, and dasymetric mapping approaches to minimize error when boundaries change over time.

### crosswalk_tables

A set of .csv tables which link boundary identifiers between years using a set of apportionment weights. Data is organized into four fields, the first is the ID of the source census tract, the second is the ID of the target census tract, the third is a weight indicating the amount of data that should be apportioned from the source to the target, and the forth is a flag indicating the relationship (1 = no change, 2 = merge, 3 = split, or 4 = many-to-many)

