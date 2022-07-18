-- create spatial index on points
DROP INDEX IF EXISTS in_1996_mypoints_all_geom_idx; 
CREATE INDEX in_1996_mypoints_all_geom_idx ON in_1996_mypoints_all USING GIST (geom);

-- create CT population table
DROP TABLE IF EXISTS pop_ct_2011;
CREATE TABLE pop_ct_2011 AS (
WITH source_db_pop AS 
    (SELECT 
    (CASE WHEN dbpop~E'^\\d+$' THEN dbpop::integer ELSE 0 END) AS db_pop,
    (CASE WHEN dbtdwell~E'^\\d+$' THEN dbtdwell::integer ELSE 0 END) AS db_dwe,
    dbuid as dbuid
    FROM in_2011_gaf_pt)
SELECT
C.ctuid,
sum(source_db_pop.db_pop) AS ct_pop,
sum(source_db_pop.db_dwe) AS ct_dwe
FROM source_db_pop LEFT JOIN (SELECT dbuid, ctuid FROM in_2011_cbf_db) AS C
ON source_db_pop.dbuid = C.dbuid
GROUP BY C.ctuid
);