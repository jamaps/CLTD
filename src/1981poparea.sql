-- intial index creation and cleaning after inputting the boundaries
DROP INDEX IF EXISTS in_1981_cbf_ct_geom_idx; 
CREATE INDEX in_1981_cbf_ct_geom_idx ON in_1981_cbf_ct USING GIST (geom);

DROP INDEX IF EXISTS in_1981_vor_ea_geom_idx; 
CREATE INDEX in_1981_vor_ea_geom_idx ON in_1981_vor_ea USING GIST (geom);

DROP INDEX IF EXISTS in_built_up_1991_geom_idx; 
CREATE INDEX in_built_up_1991_geom_idx ON in_built_up_1991 USING GIST (geom);


-- create CT population table
DROP TABLE IF EXISTS pop_ct_1981;
CREATE TABLE pop_ct_1981 AS (
	SELECT
	in_1981_cbf_ct.geosid AS ctuid,
	coalesce(sum(in_1981_gaf_pt.ea_pop::integer),0) AS ct_pop,
	coalesce(sum(in_1981_gaf_pt.pri_hhlds::integer),0) AS ct_dwe
	FROM in_1981_gaf_pt
	LEFT JOIN in_1981_cbf_ct ON in_1981_gaf_pt.ct_pct = in_1981_cbf_ct.ct_pct
	WHERE in_1981_cbf_ct.geosid  IS NOT NULL
	GROUP BY in_1981_cbf_ct.geosid 
);

