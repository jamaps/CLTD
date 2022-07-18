-- create spatial index on points
DROP INDEX IF EXISTS in_1996_mypoints_all_geom_idx; 
CREATE INDEX in_1996_mypoints_all_geom_idx ON in_1996_mypoints_all USING GIST (geom);


-- create CT population table
DROP TABLE IF EXISTS pop_ct_1996;
CREATE TABLE pop_ct_1996 AS (
WITH source_ea_pop AS 
    (SELECT 
    coalesce(ea_pop::integer,0) AS ea_pop,
    coalesce(cc_pri_dwe::integer,0) AS ea_dwe,
    eauid as eauid,
    cacode || ct_name as ctuid
    FROM in_1996_gaf_pt
    WHERE ct_name IS NOT NULL)
SELECT
ctuid,
sum(ea_pop) AS ct_pop,
sum(ea_dwe) AS ct_dwe
FROM source_ea_pop 
GROUP BY ctuid
ORDER BY ctuid
);
