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


-- join target to block face points, then group by to create weights
WITH blocks_with_target AS (
	SELECT 
	in_1996_mypoints_all.ctuid AS source_ctuid,
	in_2001_dbf_ct.ctuid AS target_ctuid,
	in_1996_mypoints_all.pop_count + 0.001 AS bf_pop,
	in_1996_mypoints_all.dwe_count + 0.001 AS bf_dwe
	FROM
	in_1996_mypoints_all
	LEFT JOIN 
	in_2001_dbf_ct ON ST_Intersects(in_1996_mypoints_all.geom, in_2001_dbf_ct.geom)
	WHERE in_1996_mypoints_all.geom && in_2001_dbf_ct.geom	
),
ct_sums AS (
	SELECT 
	source_ctuid AS source_ctuid,
	SUM(bf_pop) AS source_ct_pop,
	SUM(bf_dwe) AS source_ct_dwe
	FROM blocks_with_target
	GROUP BY source_ctuid
	ORDER BY source_ctuid
)
SELECT
blocks_with_target.source_ctuid,
blocks_with_target.target_ctuid,
SUM(blocks_with_target.bf_pop / ct_sums.source_ct_pop) AS w_pop,
SUM(blocks_with_target.bf_dwe / ct_sums.source_ct_dwe) AS w_dwe
FROM
blocks_with_target LEFT JOIN ct_sums
ON blocks_with_target.source_ctuid = ct_sums.source_ctuid
GROUP BY blocks_with_target.source_ctuid, blocks_with_target.target_ctuid
ORDER BY blocks_with_target.source_ctuid, blocks_with_target.target_ctuid;
