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

-- union source and target tracts

DROP TABLE IF EXISTS x_source_target;
CREATE TABLE x_source_target AS (
    SELECT
    x_source_ct_clipped_all.ctuid AS source_ctuid,
    in_1971_cbf_ct.geosid AS target_ctuid,
	x_source_ct_clipped_all.ct_area AS source_area,
    ST_Intersection(ST_MakeValid(x_source_ct_clipped_all.geom),ST_MakeValid(in_1971_cbf_ct.geom)) AS geom
    FROM x_source_ct_clipped_all LEFT JOIN in_1971_cbf_ct
    ON ST_Intersects(ST_MakeValid(x_source_ct_clipped_all.geom),ST_MakeValid(in_1971_cbf_ct.geom))
    WHERE x_source_ct_clipped_all.geom && in_1971_cbf_ct.geom
);


-- create initial crosswalk

DROP TABLE IF EXISTS x_ct_1966_1971;
CREATE TABLE x_ct_1966_1971 AS (
    ((SELECT
    source_ctuid,
    target_ctuid,
    SUM((ST_AREA(x_source_target.geom::geography) + 1) / source_area) AS w_area
    FROM x_source_target
    GROUP BY source_ctuid, target_ctuid
    ORDER BY source_ctuid, target_ctuid)
	 
	 UNION
    
    (WITH x_diff_target AS (
    SELECT 
        geosid AS target_ctuid,
        '-1' AS source_ctuid,
        -1 AS w_area,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_1966_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_1971_cbf_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
	w_area,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_area
    FROM x_diff_target_area WHERE area > 1000000))
    
    UNION
    
    (WITH x_diff_target AS (
    SELECT 
        '-1' AS target_ctuid,
        geosid AS source_ctuid,
        0 AS w_area,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_1971_cbf_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_1966_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
    w_area,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_area
    FROM x_diff_target_area WHERE area > 1000000)
);






-- 1961 to 2021

-- union source and target tracts

DROP TABLE IF EXISTS x_source_target;
CREATE TABLE x_source_target AS (
    SELECT
    x_source_ct_clipped_all.ctuid AS source_ctuid,
    in_2021_dbf_ct.ctuid AS target_ctuid,
	x_source_ct_clipped_all.ct_area AS source_area,
    ST_Intersection(ST_MakeValid(x_source_ct_clipped_all.geom),ST_MakeValid(in_2021_dbf_ct.geom)) AS geom
    FROM x_source_ct_clipped_all LEFT JOIN in_2021_dbf_ct
    ON ST_Intersects(ST_MakeValid(x_source_ct_clipped_all.geom),ST_MakeValid(in_2021_dbf_ct.geom))
    WHERE x_source_ct_clipped_all.geom && in_2021_dbf_ct.geom
);


-- create initial crosswalk

DROP TABLE IF EXISTS x_ct_1966_2021;
CREATE TABLE x_ct_1966_2021 AS (
    ((SELECT
    source_ctuid,
    target_ctuid,
    SUM((ST_AREA(x_source_target.geom::geography) + 1) / source_area) AS w_area
    FROM x_source_target
    GROUP BY source_ctuid, target_ctuid
    ORDER BY source_ctuid, target_ctuid)
	 
	 UNION
    
    (WITH x_diff_target AS (
    SELECT 
        ctuid AS target_ctuid,
        '-1' AS source_ctuid,
        -1 AS w_area,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_1966_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_2021_dbf_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
	w_area,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_area
    FROM x_diff_target_area WHERE area > 1000000))
    
    UNION
    
    (WITH x_diff_target AS (
    SELECT 
        '-1' AS target_ctuid,
        geosid AS source_ctuid,
        0 AS w_area,
            ST_Difference(
            ST_MakeValid(f.geom),
            (
                SELECT ST_Union(ST_MakeValid(l.geom))
                FROM in_2021_dbf_ct l 
                WHERE ST_Intersects(ST_MakeValid(l.geom),ST_MakeValid(l.geom))
            )
        ) as geom
    FROM in_1966_ct f),
    x_diff_target_area AS (
    SELECT
    source_ctuid,
    target_ctuid,
    w_area,
    ST_Area(geom::geography) AS area
    FROM x_diff_target)
    SELECT 
    source_ctuid,
    target_ctuid,
    w_area
    FROM x_diff_target_area WHERE area > 1000000)
);
	 
	 

