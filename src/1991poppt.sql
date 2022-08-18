-- intial index creation and cleaning after inputting the point file

-- create spatial index on points
DROP INDEX IF EXISTS in_1991_mypoints_all_geom_idx; 
CREATE INDEX in_1991_mypoints_all_geom_idx ON in_1991_mypoints_all USING GIST (geom);


-- only 

-- updating ST Johns
UPDATE in_1991_mypoints_all
SET ctuid = '00' || ctuid WHERE cmaca_code = '1';

-- updating Alberta?
UPDATE in_1991_mypoints_all
SET ctuid = ctuid || '.00' WHERE LENGTH(ctuid) = 7;
SELECT ctuid FROM in_1991_mypoints_all WHERE LENGTH(ctuid) = 7;

UPDATE in_1991_mypoints_all
SET ctuid = ctuid || '0' WHERE LENGTH(ctuid) = 9;
SELECT ctuid FROM in_1991_mypoints_all WHERE LENGTH(ctuid) = 9;

UPDATE in_1991_mypoints_all
SET ctuid = ROUND(ctuid::numeric,2)::varchar WHERE LENGTH(ctuid) > 10;
SELECT ctuid FROM in_1991_mypoints_all WHERE LENGTH(ctuid) > 10;

-- remove X
DELETE FROM in_1991_mypoints_all
WHERE ctuid = 'x';



-- create CT population table
DROP TABLE IF EXISTS pop_ct_1991;
CREATE TABLE pop_ct_1991 AS (
WITH source_ea_pop AS 
    (SELECT 
    coalesce(ea_pop::integer,0) AS ea_pop,
    coalesce(ea_pri_dwe::integer,0) AS ea_dwe,
	RIGHT('00' || prov, 2) || RIGHT('000' || fed, 3) || RIGHT('000' || ea, 3) as eauid,
    RIGHT('000' || cma_ca::varchar, 3) || RIGHT('000' || ROUND(ct_pct_nam::numeric, 2)::varchar, 7) as ctuid
    FROM in_1991_gaf_pt
    WHERE cma_ca != '0')
SELECT
ctuid,
sum(ea_pop) AS ct_pop,
sum(ea_dwe) AS ct_dwe
FROM source_ea_pop 
WHERE ctuid IN (SELECT ctuid FROM in_1991_cbf_ct_moved)
GROUP BY ctuid
ORDER BY ctuid
);


-- join target to block face points, then group by to create weights
DROP TABLE IF EXISTS x_ct_1991_1996;
CREATE TABLE x_ct_1991_1996 AS (
WITH blocks_with_target AS (
	SELECT 
	in_1991_mypoints_all.ctuid AS source_ctuid,
	in_1996_dbf_ct_moved.ctuid AS target_ctuid,
	in_1991_mypoints_all.pop_count + 0.001 AS bf_pop,
	in_1991_mypoints_all.dwe_count + 0.001 AS bf_dwe
	FROM
	in_1991_mypoints_all
	LEFT JOIN 
	in_1996_dbf_ct_moved ON ST_Intersects(in_1991_mypoints_all.geom, in_1996_dbf_ct_moved.geom)
	WHERE in_1991_mypoints_all.geom && in_1996_dbf_ct_moved.geom	
),
ct_sums AS (
	SELECT 
	source_ctuid AS source_ctuid,
	SUM(bf_pop) AS source_ct_pop,
	SUM(bf_dwe) AS source_ct_dwe
	FROM blocks_with_target
	GROUP BY source_ctuid
	ORDER BY source_ctuid
), 
x_diff_target AS (
	SELECT 	
		'-1' AS source_ctuid,
		geosid AS target_ctuid,
		-1 AS w_pop,
		-1 AS w_dwe,
			ST_Difference(
			ST_MakeValid(f.geom),
			(
				SELECT ST_Union(ST_MakeValid(l.geom))
				FROM in_1991_cbf_ct_moved_clipped l 
				WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
			)
		) as geom
	FROM in_1996_cbf_ct_moved_clipped f),
x_diff_target_area AS (
	SELECT
	source_ctuid,
	target_ctuid,
	w_pop,
	w_dwe,
	ST_Area(geom::geography) AS area
	FROM x_diff_target),
x_diff_source AS (
	SELECT 
		geosid AS source_ctuid,
		'-1' AS target_ctuid,
		0 AS w_pop,
		0 AS w_dwe,
			ST_Difference(
			ST_MakeValid(f.geom),
			(
				SELECT ST_Union(ST_MakeValid(l.geom))
				FROM in_1996_cbf_ct_moved_clipped l 
				WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
			)
		) as geom
	FROM in_1991_cbf_ct_moved_clipped f),
x_diff_source_area AS (
	SELECT
	source_ctuid,
	target_ctuid,
	w_pop,
	w_dwe,
	ST_Area(geom::geography) AS area
	FROM x_diff_source),
x_diff AS (
	SELECT 
	source_ctuid,
	target_ctuid,
	w_pop,
	w_dwe
	FROM x_diff_source_area WHERE area > 1000000

	UNION
	
	SELECT 
	source_ctuid,
	target_ctuid,
	w_pop,
	w_dwe
	FROM x_diff_target_area WHERE area > 1000000
)
(SELECT * FROM x_diff)
UNION
(SELECT
blocks_with_target.source_ctuid,
blocks_with_target.target_ctuid,
SUM(blocks_with_target.bf_pop / ct_sums.source_ct_pop) AS w_pop,
SUM(blocks_with_target.bf_dwe / ct_sums.source_ct_dwe) AS w_dwe
FROM
blocks_with_target LEFT JOIN ct_sums
ON blocks_with_target.source_ctuid = ct_sums.source_ctuid
GROUP BY blocks_with_target.source_ctuid, blocks_with_target.target_ctuid
ORDER BY blocks_with_target.source_ctuid, blocks_with_target.target_ctuid)
);

-- UPDATE x_ct_1991_1996
-- SET target_ctuid = '5350009.00' WHERE source_ctuid = '5350009.00';





-- join target to block face points, then group by to create weights
DROP TABLE IF EXISTS x_ct_1996_2021;
CREATE TABLE x_ct_1996_2021 AS (
WITH blocks_with_target AS (
	SELECT 
	in_1996_mypoints_all.ctuid AS source_ctuid,
	in_2021_dbf_ct.ctuid AS target_ctuid,
	in_1996_mypoints_all.pop_count + 0.001 AS bf_pop,
	in_1996_mypoints_all.dwe_count + 0.001 AS bf_dwe
	FROM
	in_1996_mypoints_all
	LEFT JOIN 
	in_2021_dbf_ct ON ST_Intersects(in_1996_mypoints_all.geom, in_2021_dbf_ct.geom)
	WHERE in_1996_mypoints_all.geom && in_2021_dbf_ct.geom	
),
ct_sums AS (
	SELECT 
	source_ctuid AS source_ctuid,
	SUM(bf_pop) AS source_ct_pop,
	SUM(bf_dwe) AS source_ct_dwe
	FROM blocks_with_target
	GROUP BY source_ctuid
	ORDER BY source_ctuid
), 
x_diff_target AS (
	SELECT 	
		'-1' AS source_ctuid,
		ctuid AS target_ctuid,
		-1 AS w_pop,
		-1 AS w_dwe,
			ST_Difference(
			ST_MakeValid(f.geom),
			(
				SELECT ST_Union(ST_MakeValid(l.geom))
				FROM in_1996_cbf_ct_moved l 
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
	FROM x_diff_target),
x_diff_source AS (
	SELECT 
		ctuid AS source_ctuid,
		'-1' AS target_ctuid,
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
	FROM in_1996_cbf_ct_moved f),
x_diff_source_area AS (
	SELECT
	source_ctuid,
	target_ctuid,
	w_pop,
	w_dwe,
	ST_Area(geom::geography) AS area
	FROM x_diff_source),
x_diff AS (
	SELECT 
	source_ctuid,
	target_ctuid,
	w_pop,
	w_dwe
	FROM x_diff_source_area WHERE area > 1000000

	UNION
	
	SELECT 
	source_ctuid,
	target_ctuid,
	w_pop,
	w_dwe
	FROM x_diff_target_area WHERE area > 1000000
)
(SELECT * FROM x_diff)
UNION
(SELECT
blocks_with_target.source_ctuid,
blocks_with_target.target_ctuid,
SUM(blocks_with_target.bf_pop / ct_sums.source_ct_pop) AS w_pop,
SUM(blocks_with_target.bf_dwe / ct_sums.source_ct_dwe) AS w_dwe
FROM
blocks_with_target LEFT JOIN ct_sums
ON blocks_with_target.source_ctuid = ct_sums.source_ctuid
GROUP BY blocks_with_target.source_ctuid, blocks_with_target.target_ctuid
ORDER BY blocks_with_target.source_ctuid, blocks_with_target.target_ctuid)
);
