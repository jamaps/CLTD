-- intial index creation and cleaning after inputting the boundaries

DROP INDEX IF EXISTS in_1966_ct_geom_idx; 
CREATE INDEX in_1966_ct_geom_idx ON in_1966_ct USING GIST (geom);

DROP INDEX IF EXISTS in_1971_ct_geom_idx; 
CREATE INDEX in_1971_ct_geom_idx ON in_1971_ct USING GIST (geom);

--

