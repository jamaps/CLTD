-- intial index creation and cleaning after inputting the boundaries
DROP INDEX IF EXISTS in_1961_ct_geom_idx; 
CREATE INDEX in_1961_ct_geom_idx ON in_1961_ct USING GIST (geom);


-- clip the source CT by the built up land layer, then union out any completly clipped away, also compute area
DROP TABLE IF EXISTS x_source_ct_clipped;
CREATE TABLE x_source_ct_clipped AS (
    SELECT
    in_1961_ct.geosid AS ctuid,
    ST_Union(ST_Intersection(ST_MakeValid(in_1961_ct.geom),ST_MakeValid(c.geom))) AS geom
    FROM in_1961_ct LEFT JOIN (SELECT * FROM in_built_up_1971 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(in_1961_ct.geom),ST_MakeValid(c.geom))
    WHERE in_1961_ct.geom && c.geom
    GROUP BY ctuid
);

DROP TABLE IF EXISTS x_source_ct_clipped_all;
CREATE TABLE x_source_ct_clipped_all AS (
    (SELECT
	ctuid,
	ST_AREA(x_source_ct_clipped.geom::geography)::bigint as ct_area,
	geom
	FROM x_source_ct_clipped)
    UNION ALL
    (SELECT 
	in_1961_ct.geosid AS ctuid,
	ST_AREA(in_1961_ct.geom::geography)::bigint as ct_area,
	in_1961_ct.geom AS geom
	FROM in_1961_ct
	WHERE in_1961_ct.geosid NOT IN (SELECT ctuid FROM x_source_ct_clipped)
	)
);

DROP INDEX IF EXISTS x_source_ct_clipped_all_geom_idx;
CREATE INDEX x_source_ct_clipped_all_geom_idx
ON x_source_ct_clipped_all
USING GIST (geom);


-- 1961 to 1966


	 

