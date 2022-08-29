-- intial index creation and cleaning after inputting the boundaries

-- create spatial index on points
DROP INDEX IF EXISTS in_1951_ct_geom_idx; 
CREATE INDEX in_1951_ct_geom_idx ON in_1951_ct USING GIST (geom);


-- get CT population table

-- 
DROP TABLE IF EXISTS x_source_ct_clipped;
CREATE TABLE x_source_ct_clipped AS

