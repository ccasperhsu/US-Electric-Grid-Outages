/*
Data Cleaning Steps:
0. Import file into MySQL
1. Handle Null Values
2. Remove Duplicates
3. Create Categorical Variables
4. Remove Extremities and Incomplete Records
*/


/*
#0 IMPORT FILE INTO MYSQL:
*/
-- Creating a new database for this project.
CREATE DATABASE IF NOT EXISTS electricity_outage;

-- Creating the table.
CREATE TABLE IF NOT EXISTS outages (
    year INT,
    date_start DATE,
    time_start TIME,
    date_end DATE,
    time_end TIME,
    area_affected VARCHAR(750),
    NERC_reg VARCHAR(50),
    alert_criteria VARCHAR(500),
    event_type VARCHAR(500),
    demand_loss INT,
    num_affected INT
);


-- Importing the data from Excel as a text file with UTF8 encoding.
LOAD DATA LOCAL INFILE 'C:/Users/chsu/Desktop/Project 3/cleaned_DOE.txt' 
INTO TABLE electricity_outage.outages
FIELDS 
	TERMINATED BY '\t' 
	ENCLOSED BY '"'
LINES 
	TERMINATED BY '\r\n' 
IGNORE 2 LINES;


-- "Original" table with 3458 rows.
SELECT * FROM outages;


/*
#1 HANDLE NULL VALUES:
*/
-- Creating a staging table that removed all the incidents with unknown start/end date times. 
CREATE TABLE outages_staging AS
SELECT *
FROM outages
WHERE NULLIF(date_end, 0000-00-00) IS NOT NULL
    AND NULLIF(time_end, '00:00:00') IS NOT NULL
    AND NULLIF(date_start, 0000-00-00) IS NOT NULL
    AND NULLIF(time_start, '00:00:00') IS NOT NULL; 

-- The new staging table has 2974 records.
SELECT *
FROM outages_staging;



/*
#2 REMOVE DUPLICATES:
- Create a backup table that's identical to the current table.
- Clear all data in current table, then populate non duplicate data using backup table.
- Validate results.
- Remove backup table to declutter.
*/

-- Create backup table.
CREATE TABLE outages_staging_temp AS SELECT * FROM outages_staging;

-- Delete data from original table.
TRUNCATE TABLE outages_staging;

-- Populate original table using non duplicate data.
INSERT INTO outages_staging
SELECT year, date_start, time_start, date_end, time_end, area_affected, NERC_reg, alert_criteria, event_type, demand_loss, num_affected
FROM (
	SELECT *,
    ROW_NUMBER() OVER (PARTITION BY year, date_start, time_start, date_end, time_end, area_affected, event_type 
		ORDER BY demand_loss DESC) AS rn -- Ordering by demand loss so we keep the largest value.
    FROM outages_staging_temp) tb
WHERE rn = 1;

-- QA
SELECT COUNT(*)
FROM (
	SELECT *,
		COUNT(*) OVER (
			PARTITION BY date_start, time_start, date_end, time_end, area_affected, event_type) AS dup_count,
		ROW_NUMBER() OVER (
			PARTITION BY date_start, time_start, date_end, time_end, area_affected, event_type 
			ORDER BY demand_loss DESC) AS row_num
	FROM outages_staging_temp
	ORDER BY dup_count DESC
    ) tb
WHERE row_num > 1;
-- 25 rows flagged as duplicates.

-- Count number of rows in unclean table.
SELECT COUNT(*)
FROM outages_staging_temp;
-- 2974 rows 

-- Count number of rows in clean table.
SELECT COUNT(*)
FROM outages_staging;
-- 2949 rows

-- Remove backup table.
DROP TABLE outages_staging_temp;



/*
#3 CREATE CATEGORICAL VARIABLES
*/
-- Making a new column that will hold the high level categorization of event types.
ALTER TABLE outages_staging 
ADD COLUMN category VARCHAR(50);

-- Populate new column using CASE WHEN.
UPDATE outages_staging
SET category = CASE
	WHEN event_type LIKE '%cyber%' -- Checking cyber first to prevent cyber attack from falling into phsyical attack category.
		THEN 'CyberAttack'
	WHEN event_type LIKE '%physic%' 
		OR event_type LIKE '%attack%'
        OR event_type LIKE '%sabot%'
        OR event_type LIKE '%vandal%' 
        OR event_type LIKE '%theft%'
        OR event_type LIKE '%susp%' 
		THEN 'PhysicalAttack'
	WHEN event_type LIKE '%supply%' 
		OR event_type LIKE '%fuel%' 
        THEN 'SupplyEmergency'
	WHEN event_type LIKE '%appeal%'
		OR event_type LIKE 'public%'
		THEN 'PublicAppeal'
	WHEN event_type LIKE '%weather%' 
		OR event_type LIKE '%storm%' 
        OR event_type LIKE '%wind%'
        OR event_type LIKE '%rain%'
        OR event_type LIKE '%fire%'
        OR event_type LIke '%natural%'
        OR event_type LIke '%earthqua%'
		THEN 'Weather'
	WHEN event_type LIKE '%island%' 
		OR event_type LIKE '%separation%' 
        OR event_type LIKE '%shed%'
        THEN 'Islanding/Loadshed'
	WHEN event_type LIKE '%operation%'
		OR event_type LIKE '%transmis%'
        OR event_type LIKE '%malfunc%'
        OR event_type LIKE '%inade%'
		OR event_type LIKE '%failure%'
        OR event_type LIKE '%system%'
        OR event_type LIKE '%interrup%'
        OR event_type LIKE '%voltage%'
        THEN 'SystemOperations'
	ELSE 'Other'
END;

-- Sanity check to see if any event_type fell into the wrong category.
SELECT category,
	event_type,
    COUNT(*)
FROM outages_staging
GROUP BY category, 
	event_type
ORDER BY category, COUNT(*) DESC;

-- Count of all events within each category.
SELECT category,
	COUNT(*)
FROM outages_staging
GROUP BY 1
ORDER BY 2 DESC;

/*
#4 REMOVE EXTREMETIES AND INCOMPLETE RECORDS
*/
-- Calculate the outage time duration.
SELECT 
	TIMEDIFF(
		TIMESTAMP(date_end, time_end),
        TIMESTAMP(date_start, time_start)
        ) as timediff,
	TIMESTAMPDIFF(
		HOUR,
		TIMESTAMP(date_start, time_start),
        TIMESTAMP(date_end, time_end)
        ) as hourly_diff
FROM outages_staging
ORDER BY hourly_diff DESC;
/*
We see that the largest hourly difference is 578608, and its associated timediff is 838:59:59 (maximum expression for the function). In fact, 5 records all maxed out the timediff function. These events require further investigation to determine if they reflect actual data.
*/

-- We will add new columns for the hourly and days difference for ease of reference.
ALTER TABLE outages_staging 
ADD COLUMN elap_hour DECIMAL(10,2), -- We want to show more than just the integer precision for the hourly difference.
ADD COLUMN elap_days INT;

-- Populating elap_hour column.
UPDATE outages_staging
SET elap_hour = 
	TIMESTAMPDIFF(
		SECOND, -- this method allows us to get more precision 
		TIMESTAMP(date_start, time_start),
        TIMESTAMP(date_end, time_end)
        ) / 3600;

-- Populating elap_days column.
UPDATE outages_staging
SET elap_days = 
	TIMESTAMPDIFF(
		DAY, 
		TIMESTAMP(date_start, time_start),
        TIMESTAMP(date_end, time_end)
        );

-- Re-odering column positions.
ALTER TABLE outages_staging 
MODIFY COLUMN elap_hour DECIMAL(10,2) AFTER time_end,
MODIFY COLUMN elap_days INT AFTER elap_hour;

/*
Looking at the largest time elapsed records with the rest of the table data reveals that they are human errors during the form submission process.
We will remove those records since the real end date is unknown, similar to null/blank values in the original data downloaded from online.
*/
DELETE FROM outages_staging
WHERE elap_days < 0 
	OR elap_days > 150;



/*
The staging table contains events that, while having realistic start and end times, have no recorded demand loss and/or customers affected. For our EDA process, we'll make a new table that only contains records that recorded figures for the number of people affected or demand loss.
*/
CREATE TABLE IF NOT EXISTS impact_events AS
SELECT `year`,
	date_start,
	time_start,
	date_end,
    time_end,
    elap_days,
	category,
    alert_criteria,
    event_type,
    demand_loss,
    num_affected,
    area_affected,
	NERC_reg
FROM outages_staging
WHERE (num_affected > 0 OR demand_loss > 0);

-- The resulting table has 1428 records.
SELECT COUNT(*)
FROM impact_events;