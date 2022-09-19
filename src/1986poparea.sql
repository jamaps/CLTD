-- intial index creation and cleaning after inputting the boundaries
DROP INDEX IF EXISTS in_1986_cbf_ct_geom_idx; 
CREATE INDEX in_1986_cbf_ct_geom_idx ON in_1986_cbf_ct USING GIST (geom);

-- create CT population table
DROP TABLE IF EXISTS pop_ct_1986;
CREATE TABLE pop_ct_1986 AS (
	SELECT
	in_1986_gaf_pt_min.ctuid,
	sum(in_1986_gaf_pt_min.ea_pop::integer) AS ct_pop,
	sum(in_1986_gaf_pt_min.ea_dwe::integer) AS ct_dwe
	FROM in_1986_gaf_pt_min
	WHERE in_1986_gaf_pt_min.ctuid IN (SELECT geosid FROM in_1986_cbf_ct)
	GROUP BY in_1986_gaf_pt_min.ctuid 
);

-- get minimal table of source blocks, and add a spatial index
DROP TABLE IF EXISTS x_source_blocks;
CREATE TABLE x_source_blocks AS (
    SELECT 
    eauid, 
    ctuid,
    geom 
    FROM in_1986_vor_ea
    ORDER BY ctuid);

DROP INDEX IF EXISTS x_source_blocks_geom_idx;
CREATE INDEX x_source_blocks_geom_idx
ON x_source_blocks
USING GIST (geom);