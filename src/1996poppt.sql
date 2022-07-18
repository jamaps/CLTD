-- create spatial index on points
DROP INDEX IF EXISTS in_1996_mypoints_all_geom_idx; 
CREATE INDEX in_1996_mypoints_all_geom_idx ON in_1996_mypoints_all USING GIST (geom);

