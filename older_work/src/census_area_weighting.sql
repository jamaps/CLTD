-- basic areal weighting procedure


-- example of 2011 to 2016
-------------------------------

-- get area of the source and put into new table
CREATE TABLE wa_2011_ct AS
(
SELECT
ctuid,
geom,
ST_AREA(geom::geography) as area
FROM
in_2011_cbf_ct
);


-- intersection with the target boundary
CREATE TABLE wa_2011_2016_int AS
(
SELECT
wa_2011_ct.ctuid AS ct_11,
in_2016_dbf_ct.ctuid AS ct_16,
wa_2011_ct.area AS area_full,
ST_Intersection(wa_2011_ct.geom,in_2016_dbf_ct.geom) AS geom
FROM
wa_2011_ct INNER JOIN in_2016_dbf_ct ON ST_Intersects(wa_2011_ct.geom,in_2016_dbf_ct.geom)
);



-- update area of intersected geoms
ALTER TABLE wa_2011_2016_int ADD COLUMN area_int double precision;
UPDATE wa_2011_2016_int SET area_int = ST_AREA(geom::geography);

ALTER TABLE wa_2011_2016_int ADD COLUMN area_ratio double precision;
UPDATE wa_2011_2016_int SET area_ratio = area_int / area_full;


-- grouping by ct - summing ratios
CREATE TABLE cwa_11_to_16_ct AS
(
SELECT
ct_11,
ct_16,
sum(area_ratio) AS weight
FROM
wa_2011_2016_int
GROUP BY ct_11, ct_16
ORDER BY ct_11, ct_16
);

-- write to file
\Copy (Select * From cwa_11_to_16_ct ORDER BY ct_11, ct_16) To '/home/ja/Dropbox/work/census/cwa_11_to_16_ct.csv' With CSV DELIMITER ',';
