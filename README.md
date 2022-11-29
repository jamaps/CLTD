
# Canadian Longitudinal Tract Database (CLTD)

This repository includes code to bridge Canadian historical census tract data (every five years from 1951 to 2021) to a common set of geographic boundaries (2021).

Census tracts are geographic boundaries delineated by Statistics Canada used for publishing aggregate census data. They are analogous to neighbourhoods and typically pertain to 4,000 to 7,000 residents. 

Each census year, Statistics Canada re-draws (and often adds new) boundaries to account for shifting and growing populations. 

This makes it difficult to examine how the demographics of neighbourhoods have changed over time (i.e. cannot always compare on a one-to-one basis). 

As such, the goal of this project was to use areal interpolation methods to create a series of concordance tables indicating how boundaries from older years are spatially related to newer years. Specifically, these tables include a set of weights that indicate how to apportion data from a tract boundary in one year to boundaries in another year. 

Our work began in 2016, with the creation of concordance tables from 1971 to 2016. The data and a manual describing this original work is available on Dataverse: http://dx.doi.org/10.5683/SP/EUG3DT. A paper detailing the methods was published in The Canadian Geographer.

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

We have since updated this to include recently digitized historical tract boundaries for 1951, 1956, 1961, and 1966 - as well as linked all tracts to 2021 tracts.


### crosswalk_tables

A set of concordance tables (.csv) which link boundary identifiers between years using a set of apportionment weights. 

### examples

Example scripts that use these tables to apportion data linked to census tracts from a source year to a target year (e.g. from 1951 to 2021)

### src

Contains the code used to generate and validate the crosswalk tables. This utilizes a combination of population weighting, area weighting, and dasymetric mapping approaches to minimize error when boundaries change over time. Most of this was conducted in PostGIS, some Python too.

