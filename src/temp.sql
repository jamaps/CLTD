SELECT * FROM ct_1976_2021 WHERE target_ctuid = '5350422.04'

SELECT 
source_ctuid,
SUM(w_pop) as s
FROM ct_1976_2021
GROUP BY source_ctuid
ORDER BY s DESC

DROP TABLE IF EXISTS temp_to_insert;
CREATE TABLE temp_to_insert AS
WITH target_count AS (SELECT 
	target_ctuid,
	COUNT(*) AS target_count 
	FROM ct_1976_2021
	GROUP BY target_ctuid
	ORDER BY target_ctuid), 
possible_holes AS (
	SELECT * FROM ct_1976_2021
	WHERE source_ctuid = '-1'
	AND target_ctuid IN (SELECT target_ctuid FROM target_count WHERE target_count = 1)
),
area_intersection AS (
	SELECT 
	in_1976_cbf_ct.geosid AS source_ctuid,
	in_2021_cbf_ct.ctuid AS target_ctuid,
	ST_Area(ST_Intersection(ST_MakeValid(in_1976_cbf_ct.geom),ST_MakeValid(in_2021_cbf_ct.geom))::geography) AS area
	FROM in_1976_cbf_ct LEFT JOIN in_2021_cbf_ct
    ON ST_Intersects(ST_MakeValid(in_1976_cbf_ct.geom),ST_MakeValid(in_2021_cbf_ct.geom))
    WHERE in_1976_cbf_ct.geom && in_2021_cbf_ct.geom
	AND in_2021_cbf_ct.ctuid IN (SELECT target_ctuid FROM possible_holes)
),
area_intersection_reduce AS (SELECT 
    source_ctuid,
    target_ctuid,
    area
	FROM area_intersection g1
	WHERE area = ( SELECT MAX( g2.area )
				  FROM area_intersection g2
				  WHERE g1.target_ctuid = g2.target_ctuid )
	ORDER BY target_ctuid
),
source_union as (
	SELECT ST_Union(geom) as geom FROM in_1976_cbf_ct
),
target_contained AS (
	SELECT in_2021_cbf_ct.ctuid as target_ctuid
	FROM in_2021_cbf_ct, source_union
	WHERE ST_Within(in_2021_cbf_ct.geom, source_union.geom)
	ORDER BY in_2021_cbf_ct.ctuid
)
SELECT
	source_ctuid,
	target_ctuid,
	0.000000001 AS w_pop,
	0.000000001 AS w_dwe
	FROM area_intersection_reduce
	WHERE target_ctuid IN (SELECT target_ctuid FROM target_contained);

INSERT INTO ct_1976_2021
SELECT * FROM temp_to_insert;

DELETE FROM ct_1976_2021
WHERE source_ctuid = '-1'
AND target_ctuid IN (SELECT target_ctuid FROM temp_to_insert);

UPDATE ct_1976_2021
SET w_pop = ROUND(w_pop, 9);

UPDATE ct_1976_2021
SET w_dwe = ROUND(w_dwe, 9);



