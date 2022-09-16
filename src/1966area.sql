-- intial index creation and cleaning after inputting the boundaries

DROP INDEX IF EXISTS in_1966_ct_geom_idx; 
CREATE INDEX in_1966_ct_geom_idx ON in_1966_ct USING GIST (geom);

DROP INDEX IF EXISTS in_1971_cbf_ct_geom_idx; 
CREATE INDEX in_1971_cbf_ct_geom_idx ON in_1971_cbf_ct USING GIST (geom);

--

-- clip the source CT by the built up land layer, then union out any completly clipped away, also compute area
DROP TABLE IF EXISTS x_source_ct_clipped;
CREATE TABLE x_source_ct_clipped AS (
    SELECT
    in_1966_ct.geosid AS ctuid,
    ST_Union(ST_Intersection(ST_MakeValid(in_1966_ct.geom),ST_MakeValid(c.geom))) AS geom
    FROM in_1966_ct LEFT JOIN (SELECT * FROM in_built_up_1971 WHERE code = 21) as c
    ON ST_Intersects(ST_MakeValid(in_1966_ct.geom),ST_MakeValid(c.geom))
    WHERE in_1966_ct.geom && c.geom
    GROUP BY ctuid
);
