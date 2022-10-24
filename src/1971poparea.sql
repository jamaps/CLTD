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
		SELECT 
		 pop_71::double precision / 20 as pop_w, 
		 dwl_71::double precision / 20 as dwe_w, 
		 (ST_Dump(ST_GeneratePoints(geom, 20))).geom
		FROM in_1971_ea_jct
		UNION
		SELECT
		0.1 as pop_w,
		0.1 as dwe_w,
		(ST_Dump(ST_GeneratePoints(geom, 20))).geom
		FROM in_1971_cbf_ct
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


