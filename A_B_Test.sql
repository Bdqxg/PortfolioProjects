USE `demo`;
-- Generate mock data

drop table raw_experiment_events;
CREATE TEMPORARY TABLE raw_experiment_events (
    user_id INT,
    experiment_group CHAR(1),
    converted INT
);


INSERT INTO raw_experiment_events (user_id, experiment_group, converted)
SELECT user_id, experiment_group, converted
FROM (
    WITH RECURSIVE seq AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1 FROM seq WHERE n < 100
    )
    SELECT
        n AS user_id,
        IF(n <= 50, 'A', 'B') AS experiment_group,
        IF(n <= 50, IF(RAND() < 0.3, 1, 0), IF(RAND() < 0.2, 1, 0)) AS converted
    FROM seq
) AS tmp;



SELECT * 
FROM raw_experiment_events;

-- ---------------------- 
CREATE TEMPORARY TABLE user_level AS
SELECT 
    user_id,
    experiment_group,
    MAX(converted) AS converted
FROM raw_experiment_events
GROUP BY user_id, experiment_group;

CREATE TEMPORARY TABLE summary AS
SELECT
    experiment_group,
    COUNT(*) AS cnt,
    SUM(converted) AS conv,
    AVG(CAST(converted AS DECIMAL)) AS conv_rate
FROM user_level
GROUP BY experiment_group;

select *
From summary;
-- pivot table

CREATE TEMPORARY TABLE a_b AS
SELECT
    MAX(CASE WHEN experiment_group = 'A' THEN cnt END) AS nA,
    MAX(CASE WHEN experiment_group = 'B' THEN cnt END) AS nB,
    MAX(CASE WHEN experiment_group = 'A' THEN conv END) AS xA,
    MAX(CASE WHEN experiment_group = 'B' THEN conv END) AS xB,
    MAX(CASE WHEN experiment_group = 'A' THEN conv_rate END) AS pA,
    MAX(CASE WHEN experiment_group = 'B' THEN conv_rate END) AS pB
FROM summary;

select *
from a_B;


-- caculate the Z score
CREATE TEMPORARY TABLE z_calc AS
SELECT
    nA, nB, xA, xB, pA, pB,
    SQRT( (pA*(1-pA)/nA) + (pB*(1-pB)/nB) ) AS std_error,
    (pB - pA)/NULLIF(SQRT( (pA*(1-pA)/nA) + (pB*(1-pB)/nB) ),0) AS z_score
FROM a_b;

select *
from z_calc;


-- print the result

SELECT
    pA AS control_rate,
    pB AS treatment_rate,
    pB - pA AS diff,
    std_error,
    z_score
FROM z_calc;

