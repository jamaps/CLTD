-- intial index creation and cleaning after inputting the boundaries
DROP INDEX IF EXISTS in_1951_ct_geom_idx; 
CREATE INDEX in_1951_ct_geom_idx ON in_1951_ct USING GIST (geom);


-- clip the source CT by the built up land layer, then union out any completly clipped away
DROP TABLE IF EXISTS x_source_ct_clipped;
CREATE TABLE x_source_ct_clipped AS (
    SELECT
    in_1951_ct.geosid AS ctuid,
    ST_Union(ST_Intersection(ST_MakeValid(in_1951_ct.geom),ST_MakeValid(c.geom))) AS geom
    FROM in_1951_ct LEFT JOIN (SELECT * FROM in_built_up_1971 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(in_1951_ct.geom),ST_MakeValid(c.geom))
    WHERE in_1951_ct.geom && c.geom
    GROUP BY ctuid
);

DROP TABLE IF EXISTS x_source_ct_clipped_all;
CREATE TABLE x_source_ct_clipped_all AS (
    (SELECT * FROM x_source_ct_clipped)
    UNION ALL
    (SELECT 
	in_1951_ct.geosid AS ctuid,
	in_1951_ct.geom AS geom
	FROM in_1951_ct
	WHERE in_1951_ct.geosid NOT IN (SELECT ctuid FROM x_source_ct_clipped)
	)
);


