DROP TABLE IF EXISTS x_source_blocks;
CREATE TABLE x_source_blocks AS (
    SELECT 
    dbuid, 
    ctuid,
    cmauid,
    -- ST_AREA(geom::geography)::integer AS db_area,
    geom 
    FROM in_2016_cbf_db
    WHERE ctuid IS NOT NULL
    AND cmauid = '535'
    ORDER BY ctuid)
    LIMIT 1000;

DROP INDEX IF EXISTS x_source_blocks_geom_idx;
CREATE INDEX x_source_blocks_geom_idx
ON x_source_blocks
USING GIST (geom);

DROP TABLE IF EXISTS x_source_blocks_clipped;
CREATE TABLE x_source_blocks_clipped AS (
    SELECT
    x_source_blocks.dbuid,
    x_source_blocks.ctuid,
    ST_Intersection(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom)) AS geom
    FROM x_source_blocks LEFT JOIN (SELECT * FROM in_built_up_2011 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))
    WHERE x_source_blocks.geom && c.geom                      
);


