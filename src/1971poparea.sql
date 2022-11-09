-- intial index creation and cleaning after inputting the boundaries
DROP INDEX IF EXISTS in_1971_cbf_ct_geom_idx; 
CREATE INDEX in_1971_cbf_ct_geom_idx ON in_1971_cbf_ct USING GIST (geom);

DROP INDEX IF EXISTS in_1971_ea_jct_geom_idx; 
CREATE INDEX in_1971_ea_jct_geom_idx ON in_1971_ea_jct USING GIST (geom);


-- generate random ea points
DROP TABLE IF EXISTS in_1971_ea_rand_pts;
CREATE TABLE in_1971_ea_rand_pts AS
(	
	WITH pts AS (
		(SELECT 
		 pop_71::double precision / 20 as pop_w, 
		 dwl_71::double precision / 20 as dwe_w, 
		 (ST_Dump(ST_GeneratePoints(geom, 20))).geom
		FROM in_1971_ea_jct
		UNION
		SELECT
		0.1 as pop_w,
		0.1 as dwe_w,
		(ST_Dump(ST_GeneratePoints(geom, 20))).geom
		FROM in_1971_cbf_ct)
		UNION
		SELECT 
		0.1 as pop_w,
		0.1 as dwe_w,
		(ST_Dump(ST_GeneratePoints(geom, 5))).geom
		FROM in_2021_cbf_ct
	)
	SELECT
	pts.pop_w,
	pts.dwe_w,
	pts.geom,
	in_1971_cbf_ct.geosid AS ctuid
	FROM pts
	LEFT JOIN 
	in_1971_cbf_ct ON ST_Intersects(pts.geom, in_1971_cbf_ct.geom)
	WHERE pts.geom && in_1971_cbf_ct.geom	
);

DROP INDEX IF EXISTS in_1971_ea_rand_pts_geom_idx; 
CREATE INDEX in_1971_ea_rand_pts_geom_idx ON in_1971_ea_rand_pts USING GIST (geom);


									   
-- create CT population table (fake for Sarnia and SSM)
DROP TABLE IF EXISTS pop_ct_1971;
CREATE TABLE pop_ct_1971 AS (
	SELECT
	in_1971_ea_rand_pts.ctuid AS ctuid,
	coalesce(sum(in_1971_ea_rand_pts.pop_w::integer),0) AS ct_pop,
	coalesce(sum(in_1971_ea_rand_pts.dwe_w::integer),0) AS ct_dwe
	FROM in_1971_ea_rand_pts
	GROUP BY in_1971_ea_rand_pts.ctuid 
);



-- join target to block face points, then group by to create weights
DROP TABLE IF EXISTS x_ct_1971_2021;
CREATE TABLE x_ct_1971_2021 AS (
WITH blocks_with_target AS (
	SELECT 
	in_1971_ea_rand_pts.ctuid AS source_ctuid,
	in_2021_dbf_ct.ctuid AS target_ctuid,
	in_1971_ea_rand_pts.pop_w + 0.001 AS bf_pop,
	in_1971_ea_rand_pts.dwe_w + 0.001 AS bf_dwe
	FROM
	in_1971_ea_rand_pts
	LEFT JOIN 
	in_2021_dbf_ct ON ST_Intersects(in_1971_ea_rand_pts.geom, in_2021_dbf_ct.geom)
	WHERE in_1971_ea_rand_pts.geom && in_2021_dbf_ct.geom	
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
				FROM in_1971_cbf_ct l 
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
		geosid AS source_ctuid,
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
	FROM in_1971_cbf_ct f),
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




-- join target to block face points, then group by to create weights
DROP TABLE IF EXISTS x_ct_1971_1976;
CREATE TABLE x_ct_1971_1976 AS (
WITH blocks_with_target AS (
	SELECT 
	in_1971_ea_rand_pts.ctuid AS source_ctuid,
	in_1976_cbf_ct.geosid AS target_ctuid,
	in_1971_ea_rand_pts.pop_w + 0.001 AS bf_pop,
	in_1971_ea_rand_pts.dwe_w + 0.001 AS bf_dwe
	FROM
	in_1971_ea_rand_pts
	LEFT JOIN 
	in_1976_cbf_ct ON ST_Intersects(in_1971_ea_rand_pts.geom, in_1976_cbf_ct.geom)
	WHERE in_1971_ea_rand_pts.geom && in_1976_cbf_ct.geom	
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
				FROM in_1971_cbf_ct l 
				WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
			)
		) as geom
	FROM in_1976_cbf_ct f),
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
				FROM in_1976_cbf_ct l 
				WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
			)
		) as geom
	FROM in_1971_cbf_ct f),
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


