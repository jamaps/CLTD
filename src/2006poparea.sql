-- create CT population table
DROP TABLE IF EXISTS pop_ct_2006;
CREATE TABLE pop_ct_2006 AS (
WITH source_db_pop AS 
    (SELECT 
    (CASE WHEN dbpop~E'^\\d+$' THEN dbpop::integer ELSE 0 END) AS db_pop,
    (CASE WHEN dbdwell~E'^\\d+$' THEN dbdwell::integer ELSE 0 END) AS db_dwe,
    dbuid as dbuid
    FROM in_2006_gaf_pt)
SELECT
C.ctuid,
sum(source_db_pop.db_pop) AS ct_pop,
sum(source_db_pop.db_dwe) AS ct_dwe
FROM source_db_pop LEFT JOIN (SELECT dbuid, ctuid FROM in_2006_cbf_db) AS C
ON source_db_pop.dbuid = C.dbuid
GROUP BY C.ctuid
);


-- get minimal table of source blocks, and add a spatial index
DROP TABLE IF EXISTS x_source_blocks;
CREATE TABLE x_source_blocks AS (
    SELECT 
    dbuid, 
    ctuid,
    cmauid,
    geom 
    FROM in_2006_cbf_db
    WHERE ctuid IS NOT NULL
    ORDER BY ctuid);

DROP INDEX IF EXISTS x_source_blocks_geom_idx;
CREATE INDEX x_source_blocks_geom_idx
ON x_source_blocks
USING GIST (geom);


-- clip the source blocks by the built up land layer, then union out any completly clipped away
DROP TABLE IF EXISTS x_source_blocks_clipped;
CREATE TABLE x_source_blocks_clipped AS (
    SELECT
    x_source_blocks.dbuid,
    x_source_blocks.ctuid,
    ST_Union(ST_Intersection(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))) AS geom
    FROM x_source_blocks LEFT JOIN (SELECT * FROM in_built_up_2011 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))
    WHERE x_source_blocks.geom && c.geom
    GROUP BY ctuid, dbuid
);

DROP TABLE IF EXISTS x_source_blocks_clipped_all;
CREATE TABLE x_source_blocks_clipped_all AS (
    (SELECT * FROM x_source_blocks_clipped)
    UNION ALL
    (WITH J AS (SELECT 
        in_2011_cbf_db.dbuid,
        x_source_blocks_clipped.dbuid AS clipped_db,
        in_2011_cbf_db.ctuid,
        in_2011_cbf_db.geom 
        FROM in_2011_cbf_db
        LEFT JOIN x_source_blocks_clipped ON
        in_2011_cbf_db.dbuid = x_source_blocks_clipped.dbuid
        WHERE in_2011_cbf_db.ctuid IS NOT NULL)
    SELECT dbuid, ctuid, geom FROM J WHERE clipped_db IS NULL)
);


-- Add in the population and dwelling data to ready the blocks for join to target tracts
-- Also give it a spatial index
DROP TABLE IF EXISTS x_source_blocks_clipped_ready;
CREATE TABLE x_source_blocks_clipped_ready AS (
WITH db_pop AS 
    (SELECT 
    (CASE WHEN dbpop~E'^\\d+$' THEN dbpop::integer ELSE 0 END) AS db_pop,
    (CASE WHEN dbtdwell~E'^\\d+$' THEN dbtdwell::integer ELSE 0 END) AS db_dwe,
    dbuid as dbuid
    FROM in_2011_gaf_pt),
db_pop_ctuid AS 
    (SELECT
    C.ctuid,
    C.dbuid,
    db_pop.db_pop AS db_pop,
    db_pop.db_dwe AS db_dwe
    FROM db_pop LEFT JOIN (SELECT dbuid, ctuid FROM in_2011_cbf_db) AS C
    ON db_pop.dbuid = C.dbuid
    WHERE C.ctuid IS NOT NULL),
db_ct_op AS 
    (SELECT 
    db_pop_ctuid.ctuid,
    db_pop_ctuid.dbuid,
    db_pop_ctuid.db_pop,
    db_pop_ctuid.db_dwe,
    pop_ct_2011.ct_pop,
    pop_ct_2011.ct_dwe
    FROM db_pop_ctuid LEFT JOIN pop_ct_2011 
    ON db_pop_ctuid.ctuid = pop_ct_2011.ctuid
    ORDER BY ctuid)
SELECT
x_source_blocks_clipped_all.ctuid,
x_source_blocks_clipped_all.dbuid,
ST_AREA(x_source_blocks_clipped_all.geom::geography)::bigint as db_area,
db_ct_op.db_pop,
db_ct_op.db_dwe,
db_ct_op.ct_pop,
db_ct_op.ct_dwe,
x_source_blocks_clipped_all.geom
FROM x_source_blocks_clipped_all LEFT JOIN db_ct_op
ON x_source_blocks_clipped_all.dbuid = db_ct_op.dbuid
);

DROP INDEX IF EXISTS x_source_blocks_clipped_ready_geom_idx;
CREATE INDEX x_source_blocks_clipped_ready_geom_idx
ON x_source_blocks_clipped_ready
USING GIST (geom);

SELECT count(*) FROM x_source_blocks;
SELECT count(*) FROM x_source_blocks_clipped;
SELECT count(*) FROM x_source_blocks_clipped_all;
SELECT count(*) FROM x_source_blocks_clipped_ready;



-- join to the target tracts - this case to 2021
DROP TABLE IF EXISTS x_source_target;
CREATE TABLE x_source_target AS (
    SELECT
    x_source_blocks_clipped_ready.dbuid AS source_dbuid,
    x_source_blocks_clipped_ready.ctuid AS source_ctuid,
    in_2021_dbf_ct.ctuid AS target_ctuid,
    x_source_blocks_clipped_ready.db_pop,
    x_source_blocks_clipped_ready.db_dwe,
    x_source_blocks_clipped_ready.ct_pop + 0.001 AS ct_pop,
    x_source_blocks_clipped_ready.ct_dwe + 0.001 AS ct_dwe,
    x_source_blocks_clipped_ready.db_area + 0.001 AS db_area,
    ST_Intersection(ST_MakeValid(x_source_blocks_clipped_ready.geom),ST_MakeValid(in_2021_dbf_ct.geom)) AS geom
    FROM x_source_blocks_clipped_ready LEFT JOIN in_2021_dbf_ct
    ON ST_Intersects(ST_MakeValid(x_source_blocks_clipped_ready.geom),ST_MakeValid(in_2021_dbf_ct.geom))
    WHERE x_source_blocks_clipped_ready.geom && in_2021_dbf_ct.geom
);

DROP TABLE IF EXISTS x_ct_2011_2021;
CREATE TABLE x_ct_2011_2021 AS (
    ((SELECT
    source_ctuid,
    target_ctuid,
    SUM(((ST_AREA(x_source_target.geom::geography)::bigint + 1) / (db_area + 1)) * ((db_pop + 0.0001) / (ct_pop + 0.0001))) AS w_pop,
    SUM(((ST_AREA(x_source_target.geom::geography)::bigint + 1) / (db_area + 1)) * ((db_dwe + 0.0001) / (ct_dwe + 0.0001))) AS w_dwe
    FROM x_source_target
    GROUP BY source_ctuid, target_ctuid
    ORDER BY source_ctuid, target_ctuid)
    
    UNION
    
    (WITH x_diff_target AS (
    SELECT 
        ctuid AS target_ctuid,
        '-1' AS source_ctuid,
        -1 AS w_pop,
        -1 AS w_dwe,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_2011_cbf_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_2021_cbf_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe
    FROM x_diff_target_area WHERE area > 1000000))
    
    UNION
    
    (WITH x_diff_target AS (
    SELECT 
        '-1' AS target_ctuid,
        ctuid AS source_ctuid,
        0 AS w_pop,
        0 AS w_dwe,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_2021_cbf_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_2011_cbf_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe
    FROM x_diff_target_area WHERE area > 1000000)
);

    
-- join to the target tracts - this case to 2016
DROP TABLE IF EXISTS x_source_target;
CREATE TABLE x_source_target AS (
    SELECT
    x_source_blocks_clipped_ready.dbuid AS source_dbuid,
    x_source_blocks_clipped_ready.ctuid AS source_ctuid,
    in_2016_dbf_ct.ctuid AS target_ctuid,
    x_source_blocks_clipped_ready.db_pop,
    x_source_blocks_clipped_ready.db_dwe,
    x_source_blocks_clipped_ready.ct_pop + 0.001 AS ct_pop,
    x_source_blocks_clipped_ready.ct_dwe + 0.001 AS ct_dwe,
    x_source_blocks_clipped_ready.db_area + 0.001 AS db_area,
    ST_Intersection(ST_MakeValid(x_source_blocks_clipped_ready.geom),ST_MakeValid(in_2016_dbf_ct.geom)) AS geom
    FROM x_source_blocks_clipped_ready LEFT JOIN in_2016_dbf_ct
    ON ST_Intersects(ST_MakeValid(x_source_blocks_clipped_ready.geom),ST_MakeValid(in_2016_dbf_ct.geom))
    WHERE x_source_blocks_clipped_ready.geom && in_2016_dbf_ct.geom
);

DROP TABLE IF EXISTS x_ct_2011_2016;
CREATE TABLE x_ct_2011_2016 AS (
    ((SELECT
    source_ctuid,
    target_ctuid,
    SUM(((ST_AREA(x_source_target.geom::geography)::bigint + 1) / (db_area + 1)) * ((db_pop + 0.0001) / (ct_pop + 0.0001))) AS w_pop,
    SUM(((ST_AREA(x_source_target.geom::geography)::bigint + 1) / (db_area + 1)) * ((db_dwe + 0.0001) / (ct_dwe + 0.0001))) AS w_dwe
    FROM x_source_target
    GROUP BY source_ctuid, target_ctuid
    ORDER BY source_ctuid, target_ctuid)
    
    UNION
    
    (WITH x_diff_target AS (
    SELECT 
        ctuid AS target_ctuid,
        '-1' AS source_ctuid,
        -1 AS w_pop,
        -1 AS w_dwe,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_2011_cbf_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_2016_cbf_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe
    FROM x_diff_target_area WHERE area > 1000000))
    
    UNION
    
    (WITH x_diff_target AS (
    SELECT 
        '-1' AS target_ctuid,
        ctuid AS source_ctuid,
        0 AS w_pop,
        0 AS w_dwe,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_2016_cbf_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_2011_cbf_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_pop,
    w_dwe
    FROM x_diff_target_area WHERE area > 1000000)
);