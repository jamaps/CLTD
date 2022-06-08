ogr2ogr in_2021_dbf_ct.shp -t_srs "EPSG:4269" lct_000a21a_e.shp

shp2pgsql -I -s 4269 -W "latin1" in_2021_cbf_ct.shp in_2021_cbf_ct | psql -U postgres -d census