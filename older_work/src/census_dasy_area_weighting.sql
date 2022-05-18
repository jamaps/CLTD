-- dasymetric areal interpolation procedure for 2011 to 2016

-- Dasymetric Clipping:
-----------------------------------

-- select CBF count
SELECT count(*) FROM wa_2011_ct;
--

-- clip boundary
CREATE TABLE wad_2011_built AS
(
SELECT
code,
ST_MakeValid(geom) as geom
FROM in_built_up_2011
WHERE code = 21
);

-- check geoms
SELECT ctuid FROM wa_2011_ct WHERE NOT ST_IsValid(geom);
SELECT code FROM wad_2011_built WHERE NOT ST_IsValid(geom);


-- intersection clip boundary
CREATE TABLE wad_2011_clipped AS
(
SELECT
wa_2011_ct.ctuid AS ct_11,
ST_Intersection(wad_2011_built.geom,wa_2011_ct.geom) AS geom
FROM
wa_2011_ct
INNER JOIN wad_2011_built ON ST_Intersects(wad_2011_built.geom,wa_2011_ct.geom)
GROUP BY wa_2011_ct.ctuid,wad_2011_built.geom,wa_2011_ct.geom
);


-- group the pieces by ct_11
CREATE TABLE wad_2011_clipped_grouped AS
(
SELECT
wad_2011_clipped.ct_11,
ST_Union(wad_2011_clipped.geom) AS geom
FROM wad_2011_clipped GROUP BY wad_2011_clipped.ct_11
);


-- select those outside the clip
CREATE TABLE wad_2011_clip_joined AS
(
  SELECT
  *
  FROM
  wad_2011_clipped_grouped
)
UNION
(
  SELECT
  wa_2011_ct.ctuid AS ct_11,
  wa_2011_ct.geom AS geom
  FROM
  wa_2011_ct
  WHERE
  wa_2011_ct.ctuid NOT IN
  (SELECT ct_11 FROM wad_2011_clipped_grouped)
)
;



-- add in area
ALTER TABLE wad_2011_clip_joined ADD COLUMN area double precision;
UPDATE wad_2011_clip_joined SET area = ST_AREA(geom::geography);




--- join to 2016

-- fix the geom if need
UPDATE in_2016_dbf_ct SET geom = ST_MakeValid(geom);

-- checking the geom validtiy
SELECT ct_11 FROM wad_2011_clip_joined WHERE NOT ST_IsValid(geom);

-- hello!
SELECT ctuid FROM in_2016_dbf_ct WHERE NOT ST_IsValid(geom);




CREATE TABLE wad_2011_2016_int AS
(
SELECT
wad_2011_clip_joined.ct_11 AS ct_11,
in_2016_dbf_ct.ctuid AS ct_16,
wad_2011_clip_joined.area AS area_full,
ST_Intersection(wad_2011_clip_joined.geom,in_2016_dbf_ct.geom) AS geom
FROM
wad_2011_clip_joined INNER JOIN in_2016_dbf_ct ON ST_Intersects(wad_2011_clip_joined.geom, in_2016_dbf_ct.geom)
WHERE wad_2011_clip_joined.geom && in_2016_dbf_ct.geom
);



-- update area of intersected geoms - and compute ratio
ALTER TABLE wad_2011_2016_int ADD COLUMN area_int double precision;
UPDATE wad_2011_2016_int SET area_int = ST_AREA(geom::geography);

ALTER TABLE wad_2011_2016_int ADD COLUMN area_ratio double precision;
UPDATE wad_2011_2016_int SET area_ratio = area_int / area_full;


-- grouping by ct - summing ratios
drop table if exists cwad_11_to_16_ct_t1;
CREATE TABLE cwad_11_to_16_ct_t1 AS
(
SELECT
ct_11,
ct_16,
sum(area_ratio) AS weight
FROM
wad_2011_2016_int
WHERE area_ratio > 0.00999 OR area_int > 999
GROUP BY ct_11, ct_16
ORDER BY ct_11, ct_16
);

drop table if exists cwad_11_to_16_ct_t2;
CREATE TABLE cwad_11_to_16_ct_t2 AS
(-- selecting target CTs which were not included!
SELECT
'-1'::TEXT AS ct_11,
in_2016_dbf_ct.ctuid AS ct_16,
-1 AS weight
-- count(*)
FROM in_2016_dbf_ct
WHERE in_2016_dbf_ct.ctuid NOT IN
(select distinct ct_16 from cwad_11_to_16_ct_t1 WHERE ct_16 IS NOT NULL))
UNION
(-- selecting target CTs which were not included!
SELECT
wa_2011_ct.ctuid AS ct_11,
'-1'::TEXT AS ct_16,
-1 AS weight
-- count(*)
FROM wa_2011_ct
WHERE wa_2011_ct.ctuid NOT IN
(select distinct ct_11 from cwad_11_to_16_ct_t1 WHERE ct_16 IS NOT NULL));

drop table if exists cwad_11_to_16_ct;
CREATE TABLE cwad_11_to_16_ct AS
(
select * from cwad_11_to_16_ct_t1
union
select * from cwad_11_to_16_ct_t2
);

-- write to csv
\Copy (Select * From cwad_11_to_16_ct ORDER BY ct_11, ct_16) To '/home/ja/Dropbox/work/census/cwad_11_to_16_ct.csv' With CSV DELIMITER ',';
