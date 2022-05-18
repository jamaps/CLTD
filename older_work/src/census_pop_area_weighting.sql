-- 2011 to 2016 interpolation
-- combination of areal and population based weighting

-- w = sum (P_k / P_s)(A_kint / A_t)




-------- set up source data

-- set up source blocks table with source ctuid
drop table if exists x_2011_db_in;
CREATE TABLE x_2011_db_in AS (
SELECT
dbuid,
dauid,
ctuid,
cmauid,
cast(dbpop as double precision) as db_pop,
geom
FROM w_2011_db_min
);

-- set any 0 population with 0.0000001 to omit any non-zero outputs later (essentially a probability now)
UPDATE x_2011_db_in SET db_pop = 0.0000001
WHERE db_pop = 0;

-- aggregate db to ct summing pop
drop table if exists x_2011_ct_db_dissolve;
create table x_2011_ct_db_dissolve AS
  select
    ctuid as ctuid11,
    sum(db_pop) as ct_pop
  from x_2011_db_in  where ctuid != ''
  group by ctuid;

-- join back to db
drop table if exists x_2011_db_with_ct_pop;
drop index if exists x_2011_db_with_ct_pop_gix;
create table x_2011_db_with_ct_pop AS
  select
  x_2011_ct_db_dissolve.ctuid11 as ctuid11,
  x_2011_db_in.dbuid as dbuid,
  cast(x_2011_db_in.db_pop as double precision) as db_pop,
  x_2011_db_in.geom as geom,
  x_2011_ct_db_dissolve.ct_pop as ct_pop
  FROM x_2011_db_in, x_2011_ct_db_dissolve
  WHERE x_2011_db_in.ctuid = x_2011_ct_db_dissolve.ctuid11;


--create ratio of DBpop / CTpop
ALTER TABLE x_2011_db_with_ct_pop ADD COLUMN db_ct_pop_ratio double precision;
UPDATE x_2011_db_with_ct_pop
SET db_ct_pop_ratio = cast(db_pop as double precision) / cast(ct_pop as double precision);

-- add area field
ALTER TABLE x_2011_db_with_ct_pop ADD COLUMN db_area double precision;
Update x_2011_db_with_ct_pop set db_area = ST_AREA(geom::geography);


-- create spatial index for the blocks
CREATE INDEX x_2011_db_with_ct_pop_gix ON x_2011_db_with_ct_pop USING GIST (geom);



------- now its target time !

-- intersect blocks with target CT
drop table if exists x_2011_db_with_2016_ct;
CREATE TABLE x_2011_db_with_2016_ct AS
(
SELECT
  x_2011_db_with_ct_pop.ctuid11,
  x_2011_db_with_ct_pop.dbuid,
  x_2011_db_with_ct_pop.db_ct_pop_ratio,
  x_2011_db_with_ct_pop.db_area,
  in_2016_dbf_ct.ctuid AS ctuid_2016,
  ST_Intersection(ST_MakeValid(x_2011_db_with_ct_pop.geom),ST_MakeValid(in_2016_dbf_ct.geom)) AS geom
FROM x_2011_db_with_ct_pop LEFT JOIN in_2016_dbf_ct
ON ST_Intersects(ST_MakeValid(x_2011_db_with_ct_pop.geom),ST_MakeValid(in_2016_dbf_ct.geom))
WHERE x_2011_db_with_ct_pop.geom && in_2016_dbf_ct.geom
);


-- compute area of inter eas - and then compute area ratio

ALTER TABLE x_2011_db_with_2016_ct ADD COLUMN int_area double precision;
Update x_2011_db_with_2016_ct set int_area = ST_AREA(geom::geography);

ALTER TABLE x_2011_db_with_2016_ct ADD COLUMN area_ratio double precision;
UPDATE x_2011_db_with_2016_ct SET area_ratio = cast(int_area as double precision) / cast(db_area as double precision);


-- update to 1 to remove weird precision differences
UPDATE x_2011_db_with_2016_ct SET area_ratio = 1 where area_ratio > 1;


-- create initial cw by combining ratios
drop table if exists cwX_11_to_16_ct_t1;
CREATE TABLE cwX_11_to_16_ct_t1 AS
(
SELECT
ctuid11 AS ct_11,
ctuid_2016 AS ct_16,
sum(area_ratio * db_ct_pop_ratio) AS weight
FROM
x_2011_db_with_2016_ct
-- WHERE area_ratio > 0.0199
GROUP BY ct_11, ct_16
ORDER BY ct_11, ct_16
);


-- checking feature counts
SELECT
COUNT(Distinct ct_11) from cwX_11_to_16_ct_t1;
SELECT
COUNT(Distinct ct_16) from cwX_11_to_16_ct_t1;



-- remove slivers by threshold
drop table if exists cwX_11_to_16_ct_t3;
CREATE TABLE cwX_11_to_16_ct_t3 AS
SELECT
*
from cwX_11_to_16_ct_t1
WHERE
weight > 0.01;


-- check counts again
SELECT
COUNT(Distinct ct_11) from cwX_11_to_16_ct_t3;
SELECT
COUNT(Distinct ct_16) from cwX_11_to_16_ct_t3;


-- add in non included CTs
drop table if exists cwX_11_to_16_ct_t2;
CREATE TABLE cwX_11_to_16_ct_t2 AS
(-- selecting source CTs which were not included!
SELECT
'-1'::TEXT AS ct_11,
in_2016_dbf_ct.ctuid AS ct_16,
-1 AS weight
-- count(*)
FROM in_2016_dbf_ct
WHERE in_2016_dbf_ct.ctuid NOT IN
(select distinct ct_16 from cwX_11_to_16_ct_t3 WHERE ct_16 IS NOT NULL))
UNION
(-- selecting target CTs which were not included!
SELECT
  x_2011_ct_db_dissolve.ctuid11 AS ct_11,
'-1'::TEXT AS ct_16,
-1 AS weight
-- count(*)
FROM x_2011_ct_db_dissolve
WHERE x_2011_ct_db_dissolve.ctuid11 NOT IN
(select distinct ct_11 from cwX_11_to_16_ct_t3 WHERE ct_11 IS NOT NULL));


-- cobmine them
drop table if exists cwX_11_to_16_ct;
CREATE TABLE cwX_11_to_16_ct AS
(
select * from cwX_11_to_16_ct_t2
union
select * from cwX_11_to_16_ct_t3
);

-- save to file
\Copy (Select * From cwX_11_to_16_ct ORDER BY ct_11, ct_16) To '/home/ja/Dropbox/work/census/revisions_work/cw_11_to_16_ct.csv' With CSV DELIMITER ',';



--
--
-- -- --
--
