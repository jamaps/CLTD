-- 2021


-- 2016


-- 2011
SELECT * FROM ct_2011_2021 WHERE source_ctuid = '7050101.01';
UPDATE ct_2011_2021 SET w_pop = 0.99999995 WHERE source_ctuid = '7050101.01' AND target_ctuid = '7050101.01';
UPDATE ct_2011_2021 SET w_dwe = 0.99999995 WHERE source_ctuid = '7050101.01' AND target_ctuid = '7050101.01';
UPDATE ct_2011_2021 SET w_pop = 0.00000005 WHERE source_ctuid = '7050101.01' AND target_ctuid = '-1';
UPDATE ct_2011_2021 SET w_dwe = 0.00000005 WHERE source_ctuid = '7050101.01' AND target_ctuid = '-1';

SELECT * FROM ct_2016_2021 WHERE source_ctuid = '7050101.01';
UPDATE ct_2016_2021 SET w_pop = 0.99999995 WHERE source_ctuid = '7050101.01' AND target_ctuid = '7050101.01';
UPDATE ct_2016_2021 SET w_dwe = 0.99999995 WHERE source_ctuid = '7050101.01' AND target_ctuid = '7050101.01';
INSERT INTO ct_2016_2021 VALUES ('7050101.01', '-1', 0.00000005, 0.00000005)

SELECT * FROM ct_2011_2021 WHERE target_ctuid = '-1'

-- 2006
SELECT * FROM ct_2006_2021 WHERE source_ctuid = '7050101.00';
UPDATE ct_2006_2021 SET w_pop = 0.00000006 WHERE source_ctuid = '7050101.00' AND target_ctuid = '-1';
UPDATE ct_2006_2021 SET w_dwe = 0.00000007 WHERE source_ctuid = '7050101.00' AND target_ctuid = '-1';
UPDATE ct_2006_2021 SET w_pop = 0.00000001 WHERE source_ctuid = '7050101.00' AND target_ctuid = '7050104.00';
UPDATE ct_2006_2021 SET w_dwe = 0.00000001 WHERE source_ctuid = '7050101.00' AND target_ctuid = '7050104.00';

-- 2001
SELECT * FROM ct_2001_2021 WHERE source_ctuid = '7050101.00';
UPDATE ct_2001_2021 SET w_pop = 0.00000070 WHERE source_ctuid = '7050101.00' AND target_ctuid = '-1';
UPDATE ct_2001_2021 SET w_dwe = 0.00000090 WHERE source_ctuid = '7050101.00' AND target_ctuid = '-1';
UPDATE ct_2001_2021 SET w_pop = 0.00000006 WHERE source_ctuid = '7050101.00' AND target_ctuid = '7050104.00';
UPDATE ct_2001_2021 SET w_dwe = 0.00000003 WHERE source_ctuid = '7050101.00' AND target_ctuid = '7050104.00';

SELECT * FROM x_ct_2001_2021 WHERE source_ctuid = '5750102.00'
SELECT * FROM ct_2001_2021 WHERE source_ctuid = '5750102.00'
UPDATE ct_2001_2021 SET w_pop = 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_2001_2021 SET w_dwe = 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_2001_2021 SET w_pop = 1 - 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';
UPDATE ct_2001_2021 SET w_dwe = 1 - 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';

SELECT * FROM ct_2001_2006 WHERE source_ctuid = '5750102.00';
SELECT * FROM x_ct_2001_2006 WHERE source_ctuid = '5750102.00';
DELETE FROM ct_2001_2006 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750016.00';
DELETE FROM ct_2001_2006 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750017.00';
UPDATE ct_2001_2006 SET w_pop = 1 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';
UPDATE ct_2001_2006 SET w_dwe = 1 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';

SELECT * FROM ct_2001_2006 WHERE source_ctuid = '4330113.00';
UPDATE ct_2001_2006 SET w_pop = 0.94 WHERE source_ctuid = '4330113.00' AND target_ctuid = '4330113.00';
UPDATE ct_2001_2006 SET w_dwe = 0.94 WHERE source_ctuid = '4330113.00' AND target_ctuid = '4330113.00';
UPDATE ct_2001_2006 SET w_pop = 1 - 0.94 WHERE source_ctuid = '4330113.00' AND target_ctuid = '-1';
UPDATE ct_2001_2006 SET w_dwe = 1 - 0.94 WHERE source_ctuid = '4330113.00' AND target_ctuid = '-1';


-- 2001



SELECT 
source_ctuid,
SUM(w_dwe) AS s
FROM
ct_2001_2006
GROUP BY source_ctuid
ORDER BY s ASC








SELECT * FROM x_ct_2016_2021 WHERE source_ctuid = '4620832.00'


SELECT * FROM x_ct_2006_2021 WHERE source_ctuid = '6020052.00'

SELECT * FROM ct_2001_2006 WHERE source_ctuid = '4620832.00'

SELECT * FROM x_ct_2001_2021 WHERE source_ctuid = '5750102.00'
SELECT * FROM ct_2001_2021 WHERE source_ctuid = '5750102.00'

SELECT * FROM x_ct_2011_2021 WHERE target_ctuid = '-1'
SELECT * FROM x_ct_2001_2021 WHERE source_ctuid = '0010110.00'

SELECT * FROM ct_2001_2006 ORDER BY source_ctuid, target_ctuid


SELECT * FROM pop_ct_2001 WHERE ctuid = '4620832.00'