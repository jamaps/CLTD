-- intial index creation and cleaning after inputting the boundaries
DROP INDEX IF EXISTS in_1981_cbf_ct_geom_idx; 
CREATE INDEX in_1981_cbf_ct_geom_idx ON in_1981_cbf_ct USING GIST (geom);

DROP INDEX IF EXISTS in_1981_vor_ea_geom_idx; 
CREATE INDEX in_1981_vor_ea_geom_idx ON in_1981_vor_ea USING GIST (geom);

DROP INDEX IF EXISTS in_built_up_1991_geom_idx; 
CREATE INDEX in_built_up_1991_geom_idx ON in_built_up_1991 USING GIST (geom);