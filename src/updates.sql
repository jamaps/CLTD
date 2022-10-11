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
INSERT INTO ct_2016_2021 VALUES ('7050101.01', '-1', 0.00000005, 0.00000005);


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

SELECT * FROM x_ct_2001_2021 WHERE source_ctuid = '5750102.00';
SELECT * FROM ct_2001_2021 WHERE source_ctuid = '5750102.00';
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


-- 1996

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5050202.00';
UPDATE ct_1996_2001 SET w_pop = 1 WHERE source_ctuid = '5050202.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 WHERE source_ctuid = '5050202.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5050185.00';
UPDATE ct_1996_2001 SET w_pop = 1 WHERE source_ctuid = '5050185.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 WHERE source_ctuid = '5050185.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5050185.00';
UPDATE ct_1996_2021 SET w_pop = 1 WHERE source_ctuid = '5050185.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_dwe = 1 WHERE source_ctuid = '5050185.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5050186.00';
UPDATE ct_1996_2001 SET w_pop = 1 WHERE source_ctuid = '5050186.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 WHERE source_ctuid = '5050186.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5050186.00';
UPDATE ct_1996_2021 SET w_pop = 1 WHERE source_ctuid = '5050186.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_dwe = 1 WHERE source_ctuid = '5050186.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5220100.00';
UPDATE ct_1996_2001 SET w_pop = 1 WHERE source_ctuid = '5220100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 WHERE source_ctuid = '5220100.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5220100.00';
UPDATE ct_1996_2021 SET w_pop = 1 WHERE source_ctuid = '5220100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_dwe = 1 WHERE source_ctuid = '5220100.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5220101.00';
UPDATE ct_1996_2001 SET w_pop = 1 WHERE source_ctuid = '5220101.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 WHERE source_ctuid = '5220101.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5220101.00';
UPDATE ct_1996_2021 SET w_pop = 1 WHERE source_ctuid = '5220101.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_dwe = 1 WHERE source_ctuid = '5220101.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5290104.00';
UPDATE ct_1996_2001 SET w_pop = 0.1 WHERE source_ctuid = '5290104.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 0.1 WHERE source_ctuid = '5290104.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_pop = 0.95600305 - 0.08 WHERE source_ctuid = '5290104.00' AND target_ctuid = '5290104.00';
UPDATE ct_1996_2001 SET w_dwe = 0.95600305 - 0.08 WHERE source_ctuid = '5290104.00' AND target_ctuid = '5290104.00';
UPDATE ct_1996_2001 SET w_pop = 0.04399695 - 0.02 WHERE source_ctuid = '5290104.00' AND target_ctuid = '5290102.01';
UPDATE ct_1996_2001 SET w_dwe = 0.04399695 - 0.02 WHERE source_ctuid = '5290104.00' AND target_ctuid = '5290102.01';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5500100.00';
UPDATE ct_1996_2001 SET w_pop = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_pop = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';
UPDATE ct_1996_2001 SET w_dwe = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';

SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5500100.00';
UPDATE ct_1996_2021 SET w_pop = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_dwe = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_pop = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';
UPDATE ct_1996_2021 SET w_dwe = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5430110.00';
UPDATE ct_1996_2001 SET w_pop = 1 WHERE source_ctuid = '5430110.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 WHERE source_ctuid = '5430110.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5430100.00';
SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5430100.00';
SELECT * FROM x_ct_1996_2001 WHERE source_ctuid = '5430100.00';
UPDATE ct_1996_2001 SET w_pop = 0.910 WHERE source_ctuid = '5430100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 0.910 WHERE source_ctuid = '5430100.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_pop = 0.015 WHERE source_ctuid = '5430100.00' AND target_ctuid = '5430002.00';
UPDATE ct_1996_2001 SET w_dwe = 0.015 WHERE source_ctuid = '5430100.00' AND target_ctuid = '5430002.00';
UPDATE ct_1996_2001 SET w_pop = 0.075 WHERE source_ctuid = '5430100.00' AND target_ctuid = '5430003.00';
UPDATE ct_1996_2001 SET w_dwe = 0.075 WHERE source_ctuid = '5430100.00' AND target_ctuid = '5430003.00';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5430102.00';
SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5430102.00';
UPDATE ct_1996_2001 SET w_pop = 0.75600305 WHERE source_ctuid = '5430102.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 0.75600305 WHERE source_ctuid = '5430102.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_pop = 1 - 0.75600305 WHERE source_ctuid = '5430102.00' AND target_ctuid = '5430004.00';
UPDATE ct_1996_2001 SET w_dwe = 1 - 0.75600305 WHERE source_ctuid = '5430102.00' AND target_ctuid = '5430004.00';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5430101.00';
SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5430101.00';
UPDATE ct_1996_2001 SET w_pop = 1 - 0.04670824 WHERE source_ctuid = '5430101.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 - 0.06704272 WHERE source_ctuid = '5430101.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_pop = 0.04670824 WHERE source_ctuid = '5430101.00' AND target_ctuid = '5430011.01';
UPDATE ct_1996_2001 SET w_dwe = 0.06704272 WHERE source_ctuid = '5430101.00' AND target_ctuid = '5430011.01';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5590155.00';
UPDATE ct_1996_2001 SET w_pop = 1 WHERE source_ctuid = '5590155.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 WHERE source_ctuid = '5590155.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '5590150.00';
SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5590150.00';
UPDATE ct_1996_2001 SET w_pop = 1 - 0.14233344 WHERE source_ctuid = '5590150.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 1 - 0.12599437 WHERE source_ctuid = '5590150.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_pop = 0.14233344 WHERE source_ctuid = '5590150.00' AND target_ctuid = '5590140.00';
UPDATE ct_1996_2001 SET w_dwe = 0.12599437 WHERE source_ctuid = '5590150.00' AND target_ctuid = '5590140.00';

SELECT * FROM ct_1996_2021 WHERE source_ctuid = '5750102.00';
SELECT * FROM ct_2001_2021 WHERE source_ctuid = '5750102.00';
UPDATE ct_1996_2021 SET w_pop = 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_1996_2021 SET w_dwe = 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_1996_2021 SET w_pop = 1 - 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_dwe = 1 - 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '6020600.00';
SELECT * FROM ct_1996_2021 WHERE source_ctuid = '6020600.00';
UPDATE ct_1996_2001 SET w_pop = 1 - 0.00000372 WHERE source_ctuid = '6020600.00' AND target_ctuid = '6020600.00';
UPDATE ct_1996_2001 SET w_dwe = 1 - 0.00001180 WHERE source_ctuid = '6020600.00' AND target_ctuid = '6020600.00';
UPDATE ct_1996_2001 SET w_pop = 0.00000372 WHERE source_ctuid = '6020600.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 0.00001180 WHERE source_ctuid = '6020600.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2001 WHERE source_ctuid = '9380018.00';
UPDATE ct_1996_2001 SET w_pop = 1 - 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '9380004.00';
UPDATE ct_1996_2001 SET w_dwe = 1 - 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '9380004.00';
UPDATE ct_1996_2001 SET w_pop = 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '-1';
UPDATE ct_1996_2001 SET w_dwe = 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '-1';

SELECT * FROM ct_1996_2021 WHERE source_ctuid = '9380018.00';
UPDATE ct_1996_2021 SET w_pop = 1 - 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '9380001.04';
UPDATE ct_1996_2021 SET w_dwe = 1 - 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '9380001.04';
UPDATE ct_1996_2021 SET w_pop = 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '-1';
UPDATE ct_1996_2021 SET w_dwe = 0.99999992 WHERE source_ctuid = '9380018.00' AND target_ctuid = '-1';


--1991
SELECT * FROM ct_1991_1996 WHERE source_ctuid = '0010303.00';
UPDATE ct_1991_1996 SET w_pop = 0.02000000 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1';
UPDATE ct_1991_1996 SET w_dwe = 0.02000000 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1';
UPDATE ct_1991_1996 SET w_pop = 0.14388852 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010017.00';
UPDATE ct_1991_1996 SET w_dwe = 0.15158689 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010017.00';
UPDATE ct_1991_1996 SET w_pop = 0.83611148 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';
UPDATE ct_1991_1996 SET w_dwe = 0.82841311 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';

SELECT * FROM ct_1991_2021 WHERE source_ctuid = '0010303.00';
UPDATE ct_1991_2021 SET w_pop = 0.03000000 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1';
UPDATE ct_1991_2021 SET w_dwe = 0.03000000 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1';
UPDATE ct_1991_2021 SET w_pop = 0.17276342 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010017.00';
UPDATE ct_1991_2021 SET w_dwe = 0.19057334 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010017.00';
UPDATE ct_1991_2021 SET w_pop = 0.74518059 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';
UPDATE ct_1991_2021 SET w_dwe = 0.71860577 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';
INSERT INTO ct_1991_2021 VALUES ('0010303.00', '0010202.10', 0.05205600, 0.06082088);

SELECT * FROM ct_1991_2021 WHERE source_ctuid = '5500100.00';
UPDATE ct_1991_2021 SET w_pop = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1991_2021 SET w_dwe = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1991_2021 SET w_pop = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';
UPDATE ct_1991_2021 SET w_dwe = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';

SELECT * FROM ct_1991_2021 WHERE source_ctuid = '5750102.00';
UPDATE ct_1991_2021 SET w_pop = 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_1991_2021 SET w_dwe = 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_1991_2021 SET w_pop = 1 - 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';
UPDATE ct_1991_2021 SET w_dwe = 1 - 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';



-- 1986
SELECT * FROM ct_1986_2021 WHERE source_ctuid = '0010303.00';
UPDATE ct_1986_2021 SET w_pop = 0.03000000 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_dwe = 0.03000000 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_pop = 0.17276342 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010017.00';
UPDATE ct_1986_2021 SET w_dwe = 0.19057334 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010017.00';
UPDATE ct_1986_2021 SET w_pop = 0.74518059 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';
UPDATE ct_1986_2021 SET w_dwe = 0.71860577 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';
UPDATE ct_1986_2021 SET w_pop = 0.05205600 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010202.10';
UPDATE ct_1986_2021 SET w_dwe = 0.06082088 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010202.10';

SELECT * FROM ct_1986_1991 WHERE source_ctuid = '5350482.00';
SELECT * FROM ct_1986_2021 WHERE source_ctuid = '5350482.00';
UPDATE ct_1986_1991 SET w_pop = 0.07340002 + 0.09597109  WHERE source_ctuid = '5350482.00' AND target_ctuid = '-1';
UPDATE ct_1986_1991 SET w_dwe = 0.08371100 + 0.09913767  WHERE source_ctuid = '5350482.00' AND target_ctuid = '-1';
UPDATE ct_1986_1991 SET w_pop = 1 - 0.07340002 - 0.09597109 WHERE source_ctuid = '5350482.00' AND target_ctuid = '5350482.00';
UPDATE ct_1986_1991 SET w_dwe = 1 - 0.08371100 - 0.09913767 WHERE source_ctuid = '5350482.00' AND target_ctuid = '5350482.00';

SELECT * FROM ct_1986_2021 WHERE source_ctuid = '5500100.00';
UPDATE ct_1986_2021 SET w_pop = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_dwe = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_pop = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';
UPDATE ct_1986_2021 SET w_dwe = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';
DELETE FROM ct_1986_2021 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500101.00';

SELECT * FROM ct_1986_2021 WHERE source_ctuid = '5750102.00';
UPDATE ct_1986_2021 SET w_pop = 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_1986_2021 SET w_dwe = 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '5750120.00';
UPDATE ct_1986_2021 SET w_pop = 1 - 0.52120000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_dwe = 1 - 0.53860000 WHERE source_ctuid = '5750102.00' AND target_ctuid = '-1';

SELECT * FROM ct_1986_1991 WHERE source_ctuid = '8350157.00';
UPDATE ct_1986_1991 SET w_pop = 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '8350157.00';
UPDATE ct_1986_1991 SET w_dwe = 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '8350157.00';
UPDATE ct_1986_1991 SET w_pop = 1 - 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '-1';
UPDATE ct_1986_1991 SET w_dwe = 1 - 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '-1';

SELECT * FROM ct_1986_2021 WHERE source_ctuid = '8350157.00';
UPDATE ct_1986_2021 SET w_pop = 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '8350157.00';
UPDATE ct_1986_2021 SET w_dwe = 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '8350157.00';
UPDATE ct_1986_2021 SET w_pop = 1 - 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_dwe = 1 - 0.52424242 WHERE source_ctuid = '8350157.00' AND target_ctuid = '-1'

SELECT * FROM ct_1986_1991 WHERE source_ctuid = '8350166.00';
UPDATE ct_1986_1991 SET w_pop = 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '8350166.00';
UPDATE ct_1986_1991 SET w_dwe = 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '8350166.00';
UPDATE ct_1986_1991 SET w_pop = 1 - 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '-1';
UPDATE ct_1986_1991 SET w_dwe = 1 - 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '-1'

SELECT * FROM ct_1986_2021 WHERE source_ctuid = '8350166.00';
UPDATE ct_1986_2021 SET w_pop = 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '8350166.02';
UPDATE ct_1986_2021 SET w_dwe = 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '8350166.02';
UPDATE ct_1986_2021 SET w_pop = 1 - 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_dwe = 1 - 0.62424242 WHERE source_ctuid = '8350166.00' AND target_ctuid = '-1'

SELECT * FROM ct_1986_1991 WHERE source_ctuid = '8350167.00';
UPDATE ct_1986_1991 SET w_pop = 1 WHERE source_ctuid = '8350167.00' AND target_ctuid = '-1';
UPDATE ct_1986_1991 SET w_dwe = 1 WHERE source_ctuid = '8350167.00' AND target_ctuid = '-1';

SELECT * FROM ct_1986_2021 WHERE source_ctuid = '8350167.00';
UPDATE ct_1986_2021 SET w_pop = 1 WHERE source_ctuid = '8350167.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_dwe = 1 WHERE source_ctuid = '8350167.00' AND target_ctuid = '-1';

SELECT * FROM ct_1986_1991 WHERE source_ctuid = '9350156.00';
UPDATE ct_1986_1991 SET w_pop = 0.27079959 - 0.05 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.01';
UPDATE ct_1986_1991 SET w_dwe = 0.29982419 - 0.05 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.01';
UPDATE ct_1986_1991 SET w_pop = 0.72920041 - 0.05 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.02';
UPDATE ct_1986_1991 SET w_dwe = 0.70017581 - 0.05 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.02';
UPDATE ct_1986_1991 SET w_pop = 0.10000000 WHERE source_ctuid = '9350156.00' AND target_ctuid = '-1';
UPDATE ct_1986_1991 SET w_dwe = 0.10000000 WHERE source_ctuid = '9350156.00' AND target_ctuid = '-1'

SELECT * FROM ct_1986_2021 WHERE source_ctuid = '9350156.00';
UPDATE ct_1986_2021 SET w_pop = 0.17391251 - 0.00 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.01';
UPDATE ct_1986_2021 SET w_dwe = 0.19309257 - 0.00 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.01';
UPDATE ct_1986_2021 SET w_pop = 0.25250819 - 0.03 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.04';
UPDATE ct_1986_2021 SET w_dwe = 0.26454609 - 0.03 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.04';
UPDATE ct_1986_2021 SET w_pop = 0.00032845 - 0.00 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.05';
UPDATE ct_1986_2021 SET w_dwe = 0.00030309 - 0.00 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.05';
UPDATE ct_1986_2021 SET w_pop = 0.33325826 - 0.04 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.07';
UPDATE ct_1986_2021 SET w_dwe = 0.31805569 - 0.04 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.07';
UPDATE ct_1986_2021 SET w_pop = 0.23999260 - 0.03 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.08';
UPDATE ct_1986_2021 SET w_dwe = 0.22400256 - 0.03 WHERE source_ctuid = '9350156.00' AND target_ctuid = '9350156.08';
UPDATE ct_1986_2021 SET w_pop = 0.10000000 WHERE source_ctuid = '9350156.00' AND target_ctuid = '-1';
UPDATE ct_1986_2021 SET w_dwe = 0.10000000 WHERE source_ctuid = '9350156.00' AND target_ctuid = '-1'



-- 1981

SELECT * FROM ct_1981_2021 WHERE source_ctuid = '0010303.00';
SELECT * FROM ct_1981_1986 WHERE source_ctuid = '0010303.00';
UPDATE ct_1981_2021 SET w_pop = 0.99999999 - 0.12424242 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';
UPDATE ct_1981_2021 SET w_dwe = 0.99999999 - 0.12424242 WHERE source_ctuid = '0010303.00' AND target_ctuid = '0010110.00';
UPDATE ct_1981_2021 SET w_pop = 0.12424242 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1';
UPDATE ct_1981_2021 SET w_dwe = 0.12424242 WHERE source_ctuid = '0010303.00' AND target_ctuid = '-1'

SELECT * FROM ct_1981_2021 WHERE source_ctuid = '5500100.00';
UPDATE ct_1981_2021 SET w_pop = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1981_2021 SET w_dwe = 0.1 WHERE source_ctuid = '5500100.00' AND target_ctuid = '-1';
UPDATE ct_1981_2021 SET w_pop = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';
UPDATE ct_1981_2021 SET w_dwe = 0.9 WHERE source_ctuid = '5500100.00' AND target_ctuid = '5500100.00';
DELETE FROM ct_1981_2021 WHERE source_ctuid = '5500100.00' AND target_ctuid = '55001626.00';

SELECT * FROM ct_1981_1986 WHERE source_ctuid = '5590155.00';
UPDATE ct_1981_1986 SET w_pop = 1 - 0.92312432 WHERE source_ctuid = '5590155.00' AND target_ctuid = '-1';
UPDATE ct_1981_1986 SET w_dwe = 1 - 0.92312432 WHERE source_ctuid = '5590155.00' AND target_ctuid = '-1';
UPDATE ct_1981_1986 SET w_pop = 0.92312432 WHERE source_ctuid = '5590155.00' AND target_ctuid = '5590155.00';
UPDATE ct_1981_1986 SET w_dwe = 0.92312432 WHERE source_ctuid = '5590155.00' AND target_ctuid = '5590155.00';






SELECT 
source_ctuid,
SUM(w_dwe) AS s
FROM
ct_1986_2021
GROUP BY source_ctuid
ORDER BY s ASC

