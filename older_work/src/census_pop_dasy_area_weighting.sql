-- combined population and dasymetric areal weighting

-- clip boundary
CREATE INDEX wad_2011_built_gix ON wad_2011_built USING GIST (geom);
UPDATE wad_2011_built SET geom = ST_MakeValid(geom);

-- source blocks
CREATE INDEX x_2011_db_in_gix ON x_2011_db_in USING GIST (geom);
UPDATE x_2011_db_in SET geom = ST_MakeValid(geom);


-- xd_2011_db_just_ct
-- SELECT out the NULL ct blocks
drop table if exists xd_2011_db_in;
CREATE TABLE xd_2011_db_in AS (
SELECT * FROM x_2011_db_in
WHERE ctuid IS NOT NULL
);
CREATE INDEX xd_2011_db_in_gix ON xd_2011_db_in USING GIST (geom);


-- clip the source blocks
  drop table if exists xd_2011_db_clipped;
CREATE TABLE xd_2011_db_clipped AS
(
SELECT
xd_2011_db_in.ctuid AS ctuid,
xd_2011_db_in.dbuid AS dbuid,
cast(xd_2011_db_in.db_pop as double precision) as db_pop,
ST_Intersection(wad_2011_built.geom,xd_2011_db_in.geom) AS geom
FROM
xd_2011_db_in
INNER JOIN wad_2011_built ON ST_Intersects(wad_2011_built.geom,xd_2011_db_in.geom)
GROUP BY xd_2011_db_in.db_pop,xd_2011_db_in.dbuid,xd_2011_db_in.ctuid,wad_2011_built.geom,xd_2011_db_in.geom
);
-- took 30 mins or so


drop index if exists xd_2011_db_clipped_gix;
CREATE INDEX xd_2011_db_clipped_gix ON x_2011_db_in USING GIST (geom);


-- group the pieces by dbuid
drop table if exists xd_2011_db_clipped_grouped;
CREATE TABLE xd_2011_db_clipped_grouped AS
(
SELECT
xd_2011_db_clipped.ctuid,
xd_2011_db_clipped.dbuid,
CAST(xd_2011_db_clipped.db_pop AS double precision) as dp_pop,
ST_Union(xd_2011_db_clipped.geom) AS geom
FROM xd_2011_db_clipped GROUP BY xd_2011_db_clipped.dbuid, xd_2011_db_clipped.ctuid,xd_2011_db_clipped.db_pop
);

drop table if exists xd_2011_db_clipped;
drop index if exists xd_2011_db_clipped_gix;


-- select those outside and join
drop table if exists xd_2011_db_clipped_joined;
CREATE TABLE xd_2011_db_clipped_joined AS
(
  SELECT
  *
  FROM
  xd_2011_db_clipped_grouped
)
UNION
(
SELECT
xd_2011_db_in.ctuid AS ctuid,
xd_2011_db_in.dbuid AS dbuid,
CAST(xd_2011_db_in.db_pop AS double precision) as dp_pop,
xd_2011_db_in.geom AS geom
FROM
xd_2011_db_in
WHERE
xd_2011_db_in.dbuid NOT IN
(SELECT dbuid FROM xd_2011_db_clipped_grouped)
)
;

-- make sure counts are same
SELECT COUNT(*) FROM xd_2011_db_clipped_joined;
SELECT COUNT(*) FROM xd_2011_db_in;


-- set any 0 population with 0.0000001 to omit any non-zero outputs later (essentially a probability now)
UPDATE xd_2011_db_clipped_joined SET dp_pop = 0.0000001
WHERE dp_pop = 0;


-- aggregate db to ct summing pop
drop table if exists xd_2011_ct_db_dissolve;
create table xd_2011_ct_db_dissolve AS
  select
    ctuid as ctuid11,
    sum(dp_pop) as ct_pop
  from xd_2011_db_clipped_joined where ctuid != ''
  group by ctuid;

-- join back to db
drop table if exists xd_2011_db_with_ct_pop;
drop index if exists xd_2011_db_with_ct_pop_gix;
create table xd_2011_db_with_ct_pop AS
  select
  xd_2011_ct_db_dissolve.ctuid11 as ctuid11,
  xd_2011_db_clipped_joined.dbuid as dbuid,
  cast(xd_2011_db_clipped_joined.dp_pop as double precision) as db_pop,
  xd_2011_db_clipped_joined.geom as geom,
  xd_2011_ct_db_dissolve.ct_pop as ct_pop
  FROM xd_2011_db_clipped_joined, xd_2011_ct_db_dissolve
  WHERE xd_2011_db_clipped_joined.ctuid = xd_2011_ct_db_dissolve.ctuid11;



  --create ratio of DBpop / CTpop
  ALTER TABLE xd_2011_db_with_ct_pop ADD COLUMN db_ct_pop_ratio double precision;
  UPDATE xd_2011_db_with_ct_pop
  SET db_ct_pop_ratio = cast(db_pop as double precision) / cast(ct_pop as double precision);

  -- add area field
  ALTER TABLE xd_2011_db_with_ct_pop ADD COLUMN db_area double precision;
  Update xd_2011_db_with_ct_pop set db_area = ST_AREA(geom::geography);

  -- create spatial index for the blocks
  CREATE INDEX xd_2011_db_with_ct_pop_gix ON xd_2011_db_with_ct_pop USING GIST (geom);


  -- intersect blocks with target CT
  drop table if exists xd_2011_db_with_2016_ct;
  CREATE TABLE xd_2011_db_with_2016_ct AS
  (
  SELECT
    xd_2011_db_with_ct_pop.ctuid11,
    xd_2011_db_with_ct_pop.dbuid,
    xd_2011_db_with_ct_pop.db_ct_pop_ratio,
    xd_2011_db_with_ct_pop.db_area,
    in_2016_dbf_ct.ctuid AS ctuid_2016,
    ST_Intersection(ST_MakeValid(xd_2011_db_with_ct_pop.geom),ST_MakeValid(in_2016_dbf_ct.geom)) AS geom
  FROM xd_2011_db_with_ct_pop LEFT JOIN in_2016_dbf_ct
  ON ST_Intersects(ST_MakeValid(xd_2011_db_with_ct_pop.geom),ST_MakeValid(in_2016_dbf_ct.geom))
  WHERE xd_2011_db_with_ct_pop.geom && in_2016_dbf_ct.geom
  );


--
--
-- compute area ratio
ALTER TABLE xd_2011_db_with_2016_ct ADD COLUMN int_area double precision;
Update xd_2011_db_with_2016_ct set int_area = ST_AREA(geom::geography);

ALTER TABLE xd_2011_db_with_2016_ct ADD COLUMN area_ratio double precision;
UPDATE xd_2011_db_with_2016_ct SET area_ratio = cast(int_area as double precision) / cast(db_area as double precision);


-- update to 1 to remove weird precision differences
UPDATE xd_2011_db_with_2016_ct SET area_ratio = 1 where area_ratio > 1;


-- select target CT which are new
DROP index if exists w_2011_db_point_rest_gix;
CREATE INDEX w_2011_db_point_rest_gix ON w_2011_db_point_rest USING GIST (geom);
DROP index if exists in_2016_dbf_ct_gix;
CREATE INDEX in_2016_dbf_ct_gix ON in_2016_dbf_ct USING GIST (geom);

DROP TABLE if exists xd_2011_db_outside_2016;
CREATE TABLE xd_2011_db_outside_2016 AS (
WITH qqq AS (SELECT
CAST('-1'AS text) AS ct_11,
in_2016_dbf_ct.ctuid AS ct_16,
CAST(-1 AS double precision) AS weight,
CAST('1' as texT) AS f,
count(w_2011_db_point_rest.dbuid) as c
FROM
in_2016_dbf_ct
LEFT JOIN w_2011_db_point_rest
ON ST_Intersects(in_2016_dbf_ct.geom,w_2011_db_point_rest.geom)
GROUP BY ct_16
ORDER BY ct_16
)
SELECT
ct_11,ct_16,weight,f
FROM qqq
WHERE c > 0
);

--------
--------


-- create initial cw by combining ratios
drop table if exists cwxd_11_to_16_ct_t1;
CREATE TABLE cwxd_11_to_16_ct_t1 AS (

WITH qqq AS (

SELECT -- all blocks and their ratios
ctuid11 AS ct_11,
ctuid_2016 AS ct_16,
CONCAT(ctuid11,ctuid_2016) AS cat,
sum(area_ratio * db_ct_pop_ratio) AS weight
FROM
xd_2011_db_with_2016_ct
-- WHERE area_ratio > 0.1
GROUP BY ct_11, ct_16
ORDER BY ct_11, ct_16
), ppp AS
( -- just those with a an area ratio > 0.1
SELECT
ctuid11 AS ct_11,
ctuid_2016 AS ct_16,
CONCAT(ctuid11,ctuid_2016) AS cat,
CAST('1' as texT) AS f
FROM
xd_2011_db_with_2016_ct
WHERE area_ratio > 0.75
GROUP BY ct_11, ct_16
ORDER BY ct_11, ct_16
)
SELECT
qqq.ct_11,
qqq.ct_16,
qqq.weight,
ppp.f
FROM qqq
FULL OUTER JOIN ppp ON
qqq.cat = ppp.cat
)
;




-- checking feature counts
SELECT
COUNT(Distinct ct_11) from cwxd_11_to_16_ct_t1;
SELECT
COUNT(Distinct ct_16) from cwxd_11_to_16_ct_t1;


-- join with the outsiders:
drop table if exists cwxd_11_to_16_ct_t2;
CREATE TABLE cwxd_11_to_16_ct_t2 AS
(
select ct_11,ct_16,weight,f from cwxd_11_to_16_ct_t1
union
select ct_11,ct_16,weight,f from xd_2011_db_outside_2016
)
ORDER BY ct_11,ct_16;




-- remove slivers where the ct_16 count is greater than 1
-- and the weight is less than a threshold (e.g. 0.1)
drop table if exists cwxd_11_to_16_ct_t3;
CREATE TABLE cwxd_11_to_16_ct_t3 AS (
WITH qqq AS (
SELECT ct_16, count(ct_16) as ct_16_count
  FROM cwxd_11_to_16_ct_t2
GROUP by ct_16
), ppp AS (
SELECT
cwxd_11_to_16_ct_t2.*,
qqq.ct_16_count
FROM cwxd_11_to_16_ct_t2
INNER JOIN qqq ON
qqq.ct_16 = cwxd_11_to_16_ct_t2.ct_16
WHERE NOT ((qqq.ct_16_count > 1 AND (cwxd_11_to_16_ct_t2.weight < 0.1 AND cwxd_11_to_16_ct_t2.weight > -0.5)) AND f IS NULL)
ORDER BY ct_11, ct_16
)
SELECT ct_11,ct_16,weight
FROM ppp
);

-- remove slivers by threshold
-- drop table if exists cwxd_11_to_16_ct_t3;
-- CREATE TABLE cwxd_11_to_16_ct_t3 AS
-- SELECT
-- *
-- from cwxd_11_to_16_ct_t1
-- WHERE
-- weight > 0.005;


-- check counts again
SELECT
COUNT(Distinct ct_11) from cwxd_11_to_16_ct_t3;
SELECT
COUNT(Distinct ct_16) from cwxd_11_to_16_ct_t3;


-- add in non included CTs
drop table if exists cwxd_11_to_16_ct_t4;
CREATE TABLE cwxd_11_to_16_ct_t4 AS
(-- selecting source CTs which were not included!
SELECT
'-1'::TEXT AS ct_11,
in_2016_dbf_ct.ctuid AS ct_16,
-1 AS weight
-- count(*)
FROM in_2016_dbf_ct
WHERE in_2016_dbf_ct.ctuid NOT IN
(select distinct ct_16 from cwxd_11_to_16_ct_t3 WHERE ct_16 IS NOT NULL))
UNION
(-- selecting target CTs which were not included!
SELECT
  xd_2011_ct_db_dissolve.ctuid11 AS ct_11,
'-1'::TEXT AS ct_16,
-1 AS weight
-- count(*)
FROM xd_2011_ct_db_dissolve
WHERE xd_2011_ct_db_dissolve.ctuid11 NOT IN
(select distinct ct_11 from cwxd_11_to_16_ct_t3 WHERE ct_11 IS NOT NULL));



-- cobmine them
drop table if exists cwxd_11_to_16_ct;
CREATE TABLE cwxd_11_to_16_ct AS
(
select * from cwxd_11_to_16_ct_t3
union
select * from cwxd_11_to_16_ct_t4
);

-- save to file
\Copy (Select * From cwxd_11_to_16_ct ORDER BY ct_11, ct_16) To '/home/ja/Dropbox/work/census/revisions_work/cwpd_11_to_16_ct.csv' With CSV DELIMITER ',';



--
