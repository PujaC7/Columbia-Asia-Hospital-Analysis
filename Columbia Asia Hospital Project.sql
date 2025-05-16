-- 15.  
SELECT 
    `Doctor ID`,
    `Doctor Name`,
    COUNT(DISTINCT patient_id) AS patient_count,
    SUM(`Total Bill`) AS total_revenue
FROM
    sheet1
GROUP BY `Doctor ID` , `Doctor Name`
ORDER BY total_revenue DESC , patient_count ASC
LIMIT 5;

-- 16.
WITH monthly_avg AS (
  SELECT department_referral,
         DATE_FORMAT(date, '%Y-%m') AS month,
         AVG(patient_waittime) AS avg_wait
  FROM hospital_er
  GROUP BY department_referral, month
),
ordered_avg AS (
  SELECT *, 
         LAG(avg_wait, 1) OVER (PARTITION BY department_referral ORDER BY month) AS prev1,
         LAG(avg_wait, 2) OVER (PARTITION BY department_referral ORDER BY month) AS prev2
  FROM monthly_avg
)
SELECT DISTINCT department_referral
FROM ordered_avg
WHERE prev2 IS NOT NULL
  AND prev2 > prev1 AND prev1 > avg_wait;

-- 17. 
SELECT 
    dp.`Doctor ID`,
    dp.`Doctor Name`,
    SUM(CASE WHEN he.patient_gender = 'M' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN he.patient_gender = 'F' THEN 1 ELSE 0 END) AS female_count,
    ROUND(
        IFNULL(SUM(CASE WHEN he.patient_gender = 'M' THEN 1 ELSE 0 END) /
               NULLIF(SUM(CASE WHEN he.patient_gender = 'F' THEN 1 ELSE 0 END), 0), 0), 2
    ) AS male_female_ratio
FROM sheet1 dp
JOIN hospital_er he ON dp.patient_id = he.patient_id
GROUP BY dp.`Doctor ID`, dp.`Doctor Name`
ORDER BY male_female_ratio DESC;

-- 18. 
SELECT 
    dp.`Doctor ID`,
    dp.`Doctor Name`,
    ROUND(AVG(he.patient_sat_score), 2) AS avg_satisfaction
FROM sheet1 dp
JOIN hospital_er he ON dp.patient_id = he.patient_id
WHERE he.patient_sat_score IS NOT NULL
GROUP BY dp.`Doctor ID`, dp.`Doctor Name`;

-- 19. 
SELECT 
    dp.`Doctor ID`,
    dp.`Doctor Name`,
    COUNT(DISTINCT he.patient_race) AS race_diversity
FROM sheet1 dp
JOIN hospital_er he ON dp.patient_id = he.patient_id
GROUP BY dp.`Doctor ID`, dp.`Doctor Name`
HAVING race_diversity > 1
ORDER BY race_diversity DESC;

-- 20. 
SELECT 
    dp.department_referral,
    ROUND(SUM(CASE WHEN he.patient_gender = 'M' THEN dp.`Total Bill` ELSE 0 END) /
          NULLIF(SUM(CASE WHEN he.patient_gender = 'F' THEN dp.`Total Bill` ELSE 0 END), 0), 2) AS male_female_bill_ratio
FROM sheet1 dp
JOIN hospital_er he ON dp.patient_id = he.patient_id
GROUP BY dp.department_referral;

-- 21. 
UPDATE hospital_er
SET patient_sat_score = LEAST(patient_sat_score + 2, 10)
WHERE department_referral = 'General Practice'
  AND patient_waittime > 30
  AND patient_sat_score IS NOT NULL;






 