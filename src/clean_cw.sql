
WITH sum_source_pop AS (SELECT 
    source_ctuid,
    COUNT(*) AS source_count,
    SUM(w_pop) AS sum_w_pop
    FROM x_ct_2016_2021
    GROUP BY source_ctuid
    ORDER BY sum_w_pop DESC, source_ctuid),
sum_source_pop_join AS (SELECT 
    x_ct_2016_2021.*,
    sum_source_pop.sum_w_pop,
    x_ct_2016_2021.w_pop / sum_source_pop.sum_w_pop AS w_pop_1,
    sum_source_pop.source_count
    FROM x_ct_2016_2021
    LEFT JOIN sum_source_pop
    ON x_ct_2016_2021.source_ctuid = sum_source_pop.source_ctuid),
x_ct_reduce AS (SELECT 
    source_ctuid,
    target_ctuid,
    ROUND(w_pop_1, 8) AS w_pop_1
    FROM sum_source_pop_join 
    WHERE source_count = 1 OR w_pop_1 > 0.005),
sum_source_pop_1 AS (SELECT 
    source_ctuid,
    SUM(w_pop_1) AS sum_w_pop
    FROM x_ct_reduce
    GROUP BY source_ctuid
    ORDER BY sum_w_pop DESC, source_ctuid),
x_ct_ready AS (SELECT 
    x_ct_reduce.source_ctuid,
    x_ct_reduce.target_ctuid,
    ROUND(x_ct_reduce.w_pop_1 / sum_source_pop_1.sum_w_pop, 8) AS w_pop
    FROM x_ct_reduce
    LEFT JOIN sum_source_pop_1
    ON x_ct_reduce.source_ctuid = sum_source_pop_1.source_ctuid)
SELECT 
'-1' AS source_ctuid,
ctuid AS target_ctuid,
1 AS w_pop
FROM in_2021_cbf_ct
WHERE ctuid NOT IN (SELECT DISTINCT target_ctuid FROM x_ct_ready)
ORDER BY ctuid;





--

-- round the weights
-- then, get sum of source weights

SELECT * FROM x_ct_2016_2021
WHERE source_ctuid = '0010110.00';

SELECT * FROM x_ct_2016_2021 ORDER BY source_ctuid; 

SELECT * FROM x_source_target WHERE source_ctuid = '4620732.03';

SELECT * FROM pop_ct_2016 ORDER BY ct_pop DESC;
    
--
