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
    ST_Union(ST_Intersection(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))) AS geom
    FROM x_source_blocks LEFT JOIN (SELECT * FROM in_built_up_2011 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))
    WHERE x_source_blocks.geom && c.geom
    GROUP BY ctuid, dbuid
);

DROP TABLE IF EXISTS x_source_blocks_clipped_ready;


-- join in block and ct pop

-- get total area of block, join in

-- final block file should have:
-- dbuid, ctuid, db_pop, db_area, ct_pop


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
    WHERE C.ctuid IS NOT NULL)
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
x_source_blocks_clipped.dbuid,
x_source_blocks_clipped.dbuid,
ST_AREA(x_source_blocks_clipped.geom::geography) as db_area,
db_pop.db_pop,
db_pop.db_dwe,
db_pop.ct_pop,
db_pop.ct_dwe
x_source_blocks_clipped.geom
FROM x_source_blocks_clipped LEFT JOIN db_pop
ON x_source_blocks_clipped.dbuid = db_pop.dbuid;


SELECT
	*
FROM
	information_schema.columns
WHERE
	table_schema = 'public'
	AND table_name = 'in_2016_gaf_pt';
