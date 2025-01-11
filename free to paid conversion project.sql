/*Retrieve the columns one by one as listed in the task. Use the MIN aggregate
function to find the first-time engagement and purchase dates.
Apply the DATEDIFF function to see the difference in the respective days. */
SELECT 
    i.student_id,
    i.date_registere,  
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(DAY, i.date_registere, MIN(e.date_watched)) AS date_diff_reg_watch,
    DATEDIFF(DAY, MIN(e.date_watched), MIN(p.date_purchased)) AS date_diff_watch_purch
FROM 
    student_info i
LEFT JOIN 
    student_engagement e ON i.student_id = e.student_id
LEFT JOIN 
    student_purchases p ON i.student_id = p.student_id
GROUP BY 
    i.student_id, i.date_registere;


--- Next, consider how to join the three tables to retrieve the highlighted records in the Venn diagram.
	SELECT 
    i.student_id,
    i.date_registere,
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(DAY, i.date_registere, MIN(e.date_watched)) AS date_diff_reg_watch,
    DATEDIFF(DAY, MIN(e.date_watched), MIN(p.date_purchased)) AS date_diff_watch_purch
FROM 
    student_info i
LEFT JOIN 
    student_engagement e ON i.student_id = e.student_id  -- Students who have watched at least one lecture
LEFT JOIN 
    student_purchases p ON i.student_id = p.student_id    -- Students who have made a purchase
GROUP BY 
    i.student_id, i.date_registere
HAVING 
    MIN(e.date_watched) <= MIN(p.date_purchased)  -- Ensure the first engagement happens before or on the first purchase
    OR MIN(p.date_purchased) IS NULL;  -- Include students who never made a purchase


---Applying the MIN aggregate function in the previous step requires grouping the results appropriately.
	SELECT 
    i.student_id,
    i.date_registere,
    MIN(e.date_watched) AS first_date_watched,        -- Get the first date watched for each student
    MIN(p.date_purchased) AS first_date_purchased,    -- Get the first date purchased for each student
    DATEDIFF(DAY, i.date_registere, MIN(e.date_watched)) AS date_diff_reg_watch,  -- Calculate difference between registration and first engagement
    DATEDIFF(DAY, MIN(e.date_watched), MIN(p.date_purchased)) AS date_diff_watch_purch  -- Calculate difference between first engagement and first purchase
FROM 
    student_info i
LEFT JOIN 
    student_engagement e ON i.student_id = e.student_id  -- Join to get students who watched at least one lecture
LEFT JOIN 
    student_purchases p ON i.student_id = p.student_id    -- Join to get students who made at least one purchase
GROUP BY 
    i.student_id, i.date_registere  -- Group by student_id and date_registered to calculate first engagement and first purchase for each student
HAVING 
    MIN(e.date_watched) <= MIN(p.date_purchased)  -- Ensure first engagement happens on or before first purchase
    OR MIN(p.date_purchased) IS NULL;  -- Include students who never made a purchase


--- Filter the data to exclude the records where the date of first-time engagement comes later than the date of first-time purchase. Remember to keep the students who have never made a purchase.
	SELECT 
    i.student_id,
    i.date_registere,
    MIN(e.date_watched) AS first_date_watched,        -- First-time engagement date
    MIN(p.date_purchased) AS first_date_purchased,    -- First-time purchase date
    DATEDIFF(DAY, i.date_registere, MIN(e.date_watched)) AS date_diff_reg_watch,  -- Difference between registration and first engagement
    DATEDIFF(DAY, MIN(e.date_watched), MIN(p.date_purchased)) AS date_diff_watch_purch  -- Difference between first engagement and first purchase
FROM 
    student_info i
LEFT JOIN 
    student_engagement e ON i.student_id = e.student_id  -- Join to include engagement data
LEFT JOIN 
    student_purchases p ON i.student_id = p.student_id    -- Join to include purchase data
GROUP BY 
    i.student_id, i.date_registere  -- Group by student_id and registration date to aggregate the data
HAVING 
    -- Keep students whose first engagement happens before or on the same day as their first purchase
    (MIN(e.date_watched) <= MIN(p.date_purchased) OR MIN(p.date_purchased) IS NULL);



	SELECT 
    -- Free-to-Paid Conversion Rate
    ROUND(
        (COUNT(CASE WHEN first_date_watched <= first_date_purchased OR first_date_purchased IS NULL THEN 1 END) * 100.0) 
        / NULLIF(COUNT(first_date_watched), 0), 2
    ) AS conversion_rate,

    -- Average Duration Between Registration and First-Time Engagement
    ROUND(
        SUM(DATEDIFF(DAY, date_registere, first_date_watched)) 
        / NULLIF(COUNT(first_date_watched), 0), 2
    ) AS av_reg_watch,

    -- Average Duration Between First-Time Engagement and First-Time Purchase
    ROUND(
        SUM(DATEDIFF(DAY, first_date_watched, first_date_purchased)) 
        / NULLIF(COUNT(first_date_purchased), 0), 2
    ) AS av_watch_purch

FROM (
    -- Your previous subquery
    SELECT 
        i.student_id,
        i.date_registere,
        MIN(e.date_watched) AS first_date_watched,
        MIN(p.date_purchased) AS first_date_purchased
    FROM 
        student_info i
    LEFT JOIN 
        student_engagement e ON i.student_id = e.student_id
    LEFT JOIN 
        student_purchases p ON i.student_id = p.student_id
    GROUP BY 
        i.student_id, i.date_registere
    HAVING 
        MIN(e.date_watched) <= MIN(p.date_purchased) OR MIN(p.date_purchased) IS NULL
) AS a;


---When did a student with ID 268727 first watch a lecture?
	SELECT 
    i.student_id,
    i.date_registere,
    MIN(e.date_watched) AS first_date_watched,        -- First-time engagement date
    MIN(p.date_purchased) AS first_date_purchased,    -- First-time purchase date
    DATEDIFF(DAY, i.date_registere, MIN(e.date_watched)) AS date_diff_reg_watch,  -- Difference between registration and first engagement
    DATEDIFF(DAY, MIN(e.date_watched), MIN(p.date_purchased)) AS date_diff_watch_purch  -- Difference between first engagement and first purchase
FROM 
    student_info i
LEFT JOIN 
    student_engagement e ON i.student_id = e.student_id  -- Join to include engagement data
LEFT JOIN 
    student_purchases p ON i.student_id = p.student_id    -- Join to include purchase data
where 
	i.student_id = 268727
GROUP BY 
    i.student_id, i.date_registere  -- Group by student_id and registration date to aggregate the data
HAVING 
    -- Keep students whose first engagement happens before or on the same day as their first purchase
    (MIN(e.date_watched) <= MIN(p.date_purchased) OR MIN(p.date_purchased) IS NULL);

---Regarding the same student's first subscription purchase, which statement is accurate?
SELECT 
    i.student_id,
    i.date_registere,
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased
FROM 
    student_info i
LEFT JOIN 
    student_engagement e ON i.student_id = e.student_id
LEFT JOIN 
    student_purchases p ON i.student_id = p.student_id
GROUP BY 
    i.student_id, i.date_registere
HAVING 
    (MIN(e.date_watched) <= MIN(p.date_purchased) OR MIN(p.date_purchased) IS NULL);


	SELECT 
    ROUND(
        (COUNT(CASE WHEN p.date_purchased IS NOT NULL AND p.date_purchased >= e.date_watched THEN 1 END) * 100.0) 
        / COUNT(DISTINCT e.student_id), 2
    ) AS conversion_rate
FROM 
    student_info i
LEFT JOIN 
    student_engagement e ON i.student_id = e.student_id
LEFT JOIN 
    student_purchases p ON i.student_id = p.student_id
WHERE 
    e.date_watched IS NOT NULL;



	SELECT 
    ROUND(
        (COUNT(DISTINCT CASE WHEN p.date_purchased IS NOT NULL AND p.date_purchased >= e.date_watched THEN e.student_id END) * 100.0) 
        / COUNT(DISTINCT e.student_id), 2
    ) AS conversion_rate
FROM 
    student_engagement e
LEFT JOIN 
    student_purchases p ON e.student_id = p.student_id
WHERE 
    e.date_watched IS NOT NULL;


	SELECT 
    ROUND(AVG(DATEDIFF(day, e.date_watched, i.date_registere)), 2) AS avg_duration_reg_watch
FROM 
    student_engagement e
INNER JOIN 
    student_info i ON e.student_id = i.student_id
WHERE 
    e.date_watched IS NOT NULL;


SELECT 
    ROUND(AVG(DATEDIFF(day, p.date_purchased, e.date_watched)), 2) AS avg_duration_watch_purch
FROM 
    student_engagement e
INNER JOIN 
    student_purchases p ON e.student_id = p.student_id
WHERE 
    e.date_watched IS NOT NULL 
    AND p.date_purchased IS NOT NULL;
