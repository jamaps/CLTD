DROP TABLE IF EXISTS pop_ct_2016;
CREATE TABLE pop_ct_2016 AS (
WITH source_db_pop AS 
    (SELECT 
    "DBpop2016/IDpop2016" as db_pop,
    "DBtdwell2016/IDtlog2016" as db_dwe,
    "DBuid/IDidu"::varchar as dbuid
    FROM in_2016_gaf_pt)
SELECT
C.ctuid,
sum(source_db_pop.db_pop) AS ct_pop,
sum(source_db_pop.db_dwe) AS ct_dwe
FROM source_db_pop LEFT JOIN (SELECT dbuid, ctuid FROM in_2016_cbf_db) AS C
ON source_db_pop.dbuid = C.dbuid
GROUP BY C.ctuid
);

DROP TABLE IF EXISTS x_source_blocks;
CREATE TABLE x_source_blocks AS (
    SELECT 
    dbuid, 
    ctuid,
    cmauid,
    geom 
    FROM in_2016_cbf_db
    WHERE ctuid IS NOT NULL
    ORDER BY ctuid);

DROP INDEX IF EXISTS x_source_blocks_geom_idx;
CREATE INDEX x_source_blocks_geom_idx
ON x_source_blocks
USING GIST (geom);

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
        in_2016_cbf_db.dbuid,
        x_source_blocks_clipped.dbuid AS clipped_db,
        in_2016_cbf_db.ctuid,
        in_2016_cbf_db.geom 
        FROM in_2016_cbf_db
        LEFT JOIN x_source_blocks_clipped ON
        in_2016_cbf_db.dbuid = x_source_blocks_clipped.dbuid
        WHERE in_2016_cbf_db.ctuid IS NOT NULL)
    SELECT dbuid, ctuid, geom FROM J WHERE clipped_db IS NULL)
);

DROP TABLE IF EXISTS x_source_blocks_clipped_ready;
CREATE TABLE x_source_blocks_clipped_ready AS (
WITH db_pop AS 
    (SELECT 
    "DBpop2016/IDpop2016" as db_pop,
    "DBtdwell2016/IDtlog2016" as db_dwe,
    "DBuid/IDidu"::varchar as dbuid
    FROM in_2016_gaf_pt),
db_pop_ctuid AS 
    (SELECT
    C.ctuid,
    C.dbuid,
    db_pop.db_pop AS db_pop,
    db_pop.db_dwe AS db_dwe
    FROM db_pop LEFT JOIN (SELECT dbuid, ctuid FROM in_2016_cbf_db) AS C
    ON db_pop.dbuid = C.dbuid
    WHERE C.ctuid IS NOT NULL),
db_ct_op AS 
    (SELECT 
    db_pop_ctuid.ctuid,
    db_pop_ctuid.dbuid,
    db_pop_ctuid.db_pop,
    db_pop_ctuid.db_dwe,
    pop_ct_2016.ct_pop,
    pop_ct_2016.ct_dwe
    FROM db_pop_ctuid LEFT JOIN pop_ct_2016 
    ON db_pop_ctuid.ctuid = pop_ct_2016.ctuid
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

DROP TABLE IF EXISTS x_ct_2016_2021;
CREATE TABLE x_ct_2016_2021 AS (
    SELECT
    source_ctuid,
    target_ctuid,
    SUM((ST_AREA(x_source_target.geom::geography)::integer / db_area) * (db_pop / ct_pop)) AS w_pop,
    SUM((ST_AREA(x_source_target.geom::geography)::integer / db_area) * (db_dwe / ct_dwe)) AS w_dwe
    FROM x_source_target
    GROUP BY source_ctuid, target_ctuid
    ORDER BY source_ctuid, target_ctuid
);

SELECT ctuid FROM in_2021_dbf_ct WHERE ctuid NOT IN (SELECT target_ctuid FROM x_ct_2016_2021)
ORDER BY ctuid;

-- now, auto?
--- anything not in source and target, add in
--- remove slivers
--- re-balance to 1
--- make sure have both pop and dwe 