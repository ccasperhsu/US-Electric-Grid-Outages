/*
EDA Questions:
-- What's the trend of number of outages and total demand loss across time?
-- Explore the 5 most impactful events for each of the three years with the highest annual total loss.
-- Which category had the largest share of total loss?
-- What category had the largest share of event count?
-- What's the average loss for each category.
-- What were the most common causes within the most frequently occurred category?
-- Which NERC region has had the most reported outages?
-- Exploring the specific outage events with the greatest number of people affected.
-- Exploring the specific outage events with the largest demand losses.
-- What's the trend in the duration of outages? 
*/

-- What's the trend of number of outages and total demand loss across time?
SELECT `year`,
	COUNT(*),
    SUM(demand_loss) `total annual loss`
FROM impact_events
GROUP BY `year`
ORDER BY 3 DESC;


-- Explore the 5 most impactful events for each of the three years with the highest annual total loss.
-- Defining 2 CTEs to rank each year's total loss as well as each individual events during each year.
WITH rankings AS (
	SELECT `year`,
		event_type,
		num_affected,
        NERC_reg,
		demand_loss, 
		DENSE_RANK() OVER (PARTITION BY `year` ORDER BY demand_loss DESC) AS`rank`,
		SUM(demand_loss) OVER (PARTITION BY `year`) AS total_annual_loss
	FROM impact_events
    ),
annual_ranking AS (
	SELECT *,
		DENSE_RANK() OVER (ORDER BY total_annual_loss DESC) annual_loss_ranking
	FROM rankings
    )
SELECT `year`,
	event_type,
    demand_loss,
    NERC_reg,
    `rank`,
    total_annual_loss
FROM annual_ranking
WHERE `rank` <= 5 AND
	annual_loss_ranking <= 3;
-- Unfortunately a lot of records don't show anything beyond "Severe Weather". More details can be found online since the dataset contains area affected and dates occurred. 


-- Which category had the largest share of total loss?
SELECT *,
    loss_total/SUM(loss_total) OVER () * 100 AS total_loss_pct
FROM (
	SELECT category, 
		COUNT(*) count,
		SUM(demand_loss) loss_total
	FROM impact_events
	GROUP BY 1
    ORDER BY 2 DESC
    ) t1
ORDER BY total_loss_pct DESC;

-- What category had the largest share of event count?
SELECT *,
	count/SUM(count) OVER () * 100 AS 'count %'
FROM (
	SELECT category, 
		COUNT(*) count
	FROM impact_events
	GROUP BY 1
    ORDER BY 2 DESC
    ) t1;

-- What's the average loss for each category.
SELECT *,
	loss_total/count AS avg_loss
FROM (
	SELECT category, 
		COUNT(*) count,
		SUM(demand_loss) loss_total
	FROM impact_events
	GROUP BY 1
    ORDER BY 2 DESC
    ) t1
ORDER BY avg_loss DESC;


-- What were the most common causes within the most frequently occurred category?
SELECT *,
	count/SUM(count) OVER () * 100 pct_count,
    SUM(count) OVER () total_count
FROM (
	SELECT category,
	event_type,
    SUM(demand_loss),
    COUNT(*) count
	FROM impact_events
	WHERE category = 'Weather'
	GROUP BY 1, 2
	ORDER BY 3 DESC
) t1;
-- The type of weather that led to the outage is not specified the majority of the time.


-- Which NERC region has had the most reported outages?
SELECT NERC_reg,
	COUNT(*)
FROM impact_events
GROUP BY NERC_reg
ORDER BY 2 DESC;
-- RFC == RF
-- FRCC == SERC
-- SPP == MRO


-- Exploring the specific outage events with the greatest number of people affected.
SELECT date_start,
	elap_days,
    demand_loss,
    num_affected,
    area_affected,
    NERC_reg,
    event_type,
    alert_criteria
FROM impact_events
ORDER BY num_affected DESC
LIMIT 3 ;

-- Exploring the specific outage events with the largest demand losses.
SELECT date_start,
	elap_days,
    demand_loss,
    num_affected,
    area_affected,
    NERC_reg,
    event_type,
    alert_criteria
FROM impact_events
ORDER BY demand_loss DESC
LIMIT 3;


-- What's the trend in the duration of outages? 
SELECT elap_days,
	COUNT(*) count,
    ROUND(AVG(demand_loss),2) avg_loss,
    MAX(demand_loss) max_loss,
    MIN(demand_loss) min_loss,
	COUNT(*)/SUM(COUNT(*)) OVER () *100 pct_count
FROM impact_events
GROUP BY 1 ORDER BY 1;