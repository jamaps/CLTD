DROP TABLE IF EXISTS pop_ct_2016;
CREATE TABLE pop_ct_2016 AS (
WITH source_db_pop AS 
    (SELECT 
    "DBpop2016/IDpop2016" as db_pop,
    "DBtdwell2016/IDtlog2016" as db_dwe,
    "DBuid/IDidu"::varchar as dbuid
    FROM in_2016_gaf_pt WHERE "CTuid/SRidu" IS NOT NULL)
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
    ST_Intersection(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom)) AS geom
    FROM x_source_blocks LEFT JOIN (SELECT * FROM in_built_up_2011 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))
    WHERE x_source_blocks.geom && c.geom                      
);

-- join in block and ct pop

-- get total area of block, join in

-- final block file should have:
-- dbuid, ctuid, db_pop, db_area, ct_pop





SELECT
	*
FROM
	information_schema.columns
WHERE
	table_schema = 'public'
	AND table_name = 'in_2016_gaf_pt';
