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


-- get minimal table of source blocks, and add a spatial index
DROP TABLE IF EXISTS x_source_blocks;
CREATE TABLE x_source_blocks AS (
    SELECT 
    id, 
    ctuid,
    geom 
    FROM in_1981_vor_ea
    ORDER BY ctuid);
DROP INDEX IF EXISTS x_source_blocks_geom_idx;
CREATE INDEX x_source_blocks_geom_idx
ON x_source_blocks
USING GIST (geom); 


-- clip the source blocks by the built up land layer, then union out any completly clipped away
DROP TABLE IF EXISTS x_source_blocks_clipped;
CREATE TABLE x_source_blocks_clipped AS (
    SELECT
    x_source_blocks.id,
    x_source_blocks.ctuid,
    ST_Union(ST_Intersection(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))) AS geom
    FROM x_source_blocks LEFT JOIN (SELECT * FROM in_built_up_1991 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(x_source_blocks.geom),ST_MakeValid(c.geom))
    WHERE x_source_blocks.geom && c.geom
    GROUP BY x_source_blocks.ctuid, x_source_blocks.id
);


DROP TABLE IF EXISTS x_source_blocks_clipped_all;
CREATE TABLE x_source_blocks_clipped_all AS (
    (SELECT * FROM x_source_blocks_clipped)
    UNION ALL
    (WITH J AS (SELECT 
        in_1981_vor_ea.id,
        x_source_blocks_clipped.id AS clipped_db,
        in_1981_vor_ea.ctuid,
        in_1981_vor_ea.geom 
        FROM in_1981_vor_ea
        LEFT JOIN x_source_blocks_clipped ON
        in_1981_vor_ea.id = x_source_blocks_clipped.id
        WHERE in_1981_vor_ea.ctuid IS NOT NULL)
    SELECT id, ctuid, geom FROM J WHERE clipped_db IS NULL)
);
