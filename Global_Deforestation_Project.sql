/* Queries to explore global deforestion */


CREATE VIEW forestation AS
SELECT f.country_code AS f_countrycode, 
       f.country_name AS f_countryname, 
       f.year AS f_year, 
       ROUND(f.forest_area_sqkm::numeric, 2) AS forest_area_sqkm, 
       ROUND((f.forest_area_sqkm/(l.total_area_sq_mi * 2.59)*100)::numeric,2) AS forest_percentage, 
       l.country_code AS l_countrycode, 
       l.country_name AS l_countryname, 
       l.year AS l_year, 
       ROUND((l.total_area_sq_mi * 2.59)::numeric, 2) AS land_area_sqkm, 
       r.country_name AS r_countryname, 
       r.country_code AS r_countrycode, 
       r.region, 
       r.income_group
FROM forest_area AS f
JOIN land_area AS l
ON f.country_code = l.country_code AND f.year = l.year
JOIN regions AS r
ON r.country_code = f.country_code;

-- Created a view to combine tables and convert units to match 



/* 1. Queries to explore the global situation */

SELECT forest_area_sqkm, r_countryname, f_year
FROM forestation
WHERE r_countryname = 'World' AND f_year = '1990';

-- Checking for the global forest area in 1990
-- Total forest area of the world was 41,282,694.90 sqkm in 1990


SELECT forest_area_sqkm, r_countryname, f_year
FROM forestation
WHERE r_countryname = 'World' AND f_year = '2016';

-- Checking for the global forest area in 2016
-- Total forest area of the world fell to 39,958,245.90 sqkm in 2016


WITH world_forest_area_1990 AS 
	(SELECT forest_area_sqkm AS first_area_sqkm, r_countryname, f_year
	FROM forestation
	WHERE r_countryname = 'World' AND f_year = '1990'
	),
world_forest_area_2016 AS
	(SELECT forest_area_sqkm AS second_area_sqkm, r_countryname, f_year
	FROM forestation
	WHERE r_countryname = 'World' AND f_year = '2016'
	)
SELECT (wfa90.first_area_sqkm - wfa16.second_area_sqkm) AS area_sqkm_diff, wfa16.r_countryname
FROM world_forest_area_1990 AS wfa90
JOIN world_forest_area_2016 AS wfa16
ON wfa90.r_countryname = wfa16.r_countryname;

-- Total loss of forest area was 1,324,449.00 sqkm


WITH world_forest_area_1990 AS 
	(SELECT forest_area_sqkm AS first_area_sqkm, r_countryname, f_year
	FROM forestation
	WHERE r_countryname = 'World' AND f_year = '1990'
	),
world_forest_area_2016 AS
	(SELECT forest_area_sqkm AS second_area_sqkm, r_countryname, f_year
	FROM forestation
	WHERE r_countryname = 'World' AND f_year = '2016'
	),
world_forest_area_diff AS 
	(SELECT (wfa90.first_area_sqkm - wfa16.second_area_sqkm) AS area_sqkm_diff, wfa16.r_countryname
	FROM world_forest_area_1990 AS wfa90
	JOIN world_forest_area_2016 AS wfa16
	ON wfa90.r_countryname = wfa16.r_countryname)
SELECT (wfadiff.area_sqkm_diff/wfa90.first_area_sqkm * 100) AS area_sqkm_diff_percent, wfa90.r_countryname
FROM world_forest_area_1990 AS wfa90
JOIN world_forest_area_diff AS wfadiff
ON wfa90.r_countryname = wfadiff.r_countryname;

-- Total loss of forest area in percentage was 3.21%


WITH world_forest_area_1990 AS 
	(SELECT forest_area_sqkm AS first_area_sqkm, r_countryname, f_year
	FROM forestation
	WHERE r_countryname = 'World' AND f_year = '1990'
	),
world_forest_area_2016 AS
	(SELECT forest_area_sqkm AS second_area_sqkm, r_countryname, f_year
	FROM forestation
	WHERE r_countryname = 'World' AND f_year = '2016'
	),
world_forest_area_diff AS 
	(SELECT (wfa90.first_area_sqkm - wfa16.second_area_sqkm) AS forest_area_diff, wfa16.r_countryname
	FROM world_forest_area_1990 AS wfa90
	JOIN world_forest_area_2016 AS wfa16
	ON wfa90.r_countryname = wfa16.r_countryname)
SELECT forestation.l_countryname, forestation.land_area_sqkm,  ABS(forestation.land_area_sqkm - wfadiff.forest_area_diff)
FROM forestation, world_forest_area_diff AS wfadiff
WHERE f_year = 2016
ORDER BY 3 
LIMIT 1;

-- Finding the land area in 2016 that is closest to the amount of forest area that has been lost between 1990 and 2016
-- Peru has a total land area of 1,279,999.99 sqkm, which is closest to the forest area(1,324,449.00 sqkm) that have been lost throughout the years



/* 2. Queries to explore the regional outlook */

WITH forest_percent_1990 AS
	(SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percent_1990, f_year
	FROM forestation                                           
	WHERE f_year = '1990'
    GROUP BY 1, 3),
forest_percentage_2016 AS 
     (SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percentage_2016, f_year
      FROM forestation                                         
      WHERE f_year = '2016'
      GROUP BY 1, 3),                      
joined_1990_2016 AS
	(SELECT fp90.region AS region, fp90.forest_percent_1990 AS forest_90, fp16.forest_percentage_2016 AS forest_16
	FROM forest_percent_1990 AS fp90
	JOIN forest_percentage_2016 AS fp16
	ON fp90.region = fp16.region)
SELECT region, forest_16
FROM joined_1990_2016 AS joined
WHERE region = 'World';

-- The percentage of land area designated as forest in 2016 was 31.38%


WITH forest_percent_1990 AS
	(SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percent_1990, f_year
	FROM forestation                                           
	WHERE f_year = '1990'
    GROUP BY 1, 3),
forest_percentage_2016 AS 
     (SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percentage_2016, f_year
      FROM forestation                                         
      WHERE f_year = '2016'
      GROUP BY 1, 3),                      
joined_1990_2016 AS
	(SELECT fp90.region AS region, fp90.forest_percent_1990 AS forest_90, fp16.forest_percentage_2016 AS forest_16
	FROM forest_percent_1990 AS fp90
	JOIN forest_percentage_2016 AS fp16
	ON fp90.region = fp16.region)
SELECT region, MAX(forest_16)
FROM joined_1990_2016 AS joined
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- The region with the highest relative forestation in 2016 was Latin America & Carribean, with 46.16%


WITH forest_percent_1990 AS
	(SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percent_1990, f_year
	FROM forestation                                           
	WHERE f_year = '1990'
    GROUP BY 1, 3),
forest_percentage_2016 AS 
     (SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percentage_2016, f_year
      FROM forestation                                         
      WHERE f_year = '2016'
      GROUP BY 1, 3),                      
joined_1990_2016 AS
	(SELECT fp90.region AS region, fp90.forest_percent_1990 AS forest_90, fp16.forest_percentage_2016 AS forest_16
	FROM forest_percent_1990 AS fp90
	JOIN forest_percentage_2016 AS fp16
	ON fp90.region = fp16.region)
SELECT region, MIN(forest_16)
FROM joined_1990_2016 AS joined
GROUP BY 1
ORDER BY 2
LIMIT 1;

-- The region with the lowest relative forestation in 2016 was Middle East & North Africa, with 2.07%


WITH forest_percent_1990 AS
	(SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percent_1990, f_year
	FROM forestation                                           
	WHERE f_year = '1990'
    GROUP BY 1, 3),
forest_percentage_2016 AS 
     (SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percentage_2016, f_year
      FROM forestation                                         
      WHERE f_year = '2016'
      GROUP BY 1, 3),                      
joined_1990_2016 AS
	(SELECT fp90.region AS region, fp90.forest_percent_1990 AS forest_90, fp16.forest_percentage_2016 AS forest_16
	FROM forest_percent_1990 AS fp90
	JOIN forest_percentage_2016 AS fp16
	ON fp90.region = fp16.region)
SELECT region, forest_90
FROM joined_1990_2016 AS joined
WHERE region = 'World';

-- The percentage of land area designated as forest in 1990 was 32.42%


WITH forest_percent_1990 AS
	(SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percent_1990, f_year
	FROM forestation                                           
	WHERE f_year = '1990'
    GROUP BY 1, 3),
forest_percentage_2016 AS 
     (SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percentage_2016, f_year
      FROM forestation                                         
      WHERE f_year = '2016'
      GROUP BY 1, 3),                      
joined_1990_2016 AS
	(SELECT fp90.region AS region, fp90.forest_percent_1990 AS forest_90, fp16.forest_percentage_2016 AS forest_16
	FROM forest_percent_1990 AS fp90
	JOIN forest_percentage_2016 AS fp16
	ON fp90.region = fp16.region)
SELECT region, MAX(forest_90)
FROM joined_1990_2016 AS joined
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- The region with the higest relative forestation in 1990 was Latin America & Carribean, with 51.03%


WITH forest_percent_1990 AS
	(SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percent_1990, f_year
	FROM forestation                                           
	WHERE f_year = '1990'
    GROUP BY 1, 3),
forest_percentage_2016 AS 
     (SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percentage_2016, f_year
      FROM forestation                                         
      WHERE f_year = '2016'
      GROUP BY 1, 3),                      
joined_1990_2016 AS
	(SELECT fp90.region AS region, fp90.forest_percent_1990 AS forest_90, fp16.forest_percentage_2016 AS forest_16
	FROM forest_percent_1990 AS fp90
	JOIN forest_percentage_2016 AS fp16
	ON fp90.region = fp16.region)
SELECT region, MIN(forest_90)
FROM joined_1990_2016 AS joined
GROUP BY 1
ORDER BY 2
LIMIT 1;

-- The region with the lowest relative forestation in 1990 was Middle East & North Africa, with 1.78%


WITH forest_percent_1990 AS
	(SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percent_1990, f_year
	FROM forestation                                           
	WHERE f_year = '1990'
    GROUP BY 1, 3),
forest_percentage_2016 AS 
     (SELECT region, ROUND((SUM(forest_area_sqkm)/SUM(land_area_sqkm)*100)::numeric, 2) AS forest_percentage_2016, f_year
      FROM forestation                                         
      WHERE f_year = '2016'
      GROUP BY 1, 3),                      
joined_1990_2016 AS
	(SELECT fp90.region AS region, fp90.forest_percent_1990 AS forest_90, fp16.forest_percentage_2016 AS forest_16
	FROM forest_percent_1990 AS fp90
	JOIN forest_percentage_2016 AS fp16
	ON fp90.region = fp16.region)
SELECT region, forest_90, forest_16
FROM joined_1990_2016 AS joined
ORDER BY region;

-- Comparing the percentage of forest area in 1990 and in 2016 by region


/* 3. Queries to explore the country-level details */

WITH forest_area_1990 AS 
	(SELECT f_countryname, forest_area_sqkm, region, f_year
	FROM forestation 
	WHERE f_year = 1990), 
forest_area_2016 AS 
	(SELECT f_countryname, forest_area_sqkm, f_year
	FROM forestation 
	WHERE f_year = 2016),
joined_1990_2016 AS 
	(SELECT fa90.f_countryname AS f_countryname, fa90.region AS region, fa90.forest_area_sqkm AS forest_area_sqkm_90, fa90.f_year AS year_90, fa16.forest_area_sqkm AS forest_area_sqkm_16, fa16.f_year AS year_16
  	FROM forest_area_1990 AS fa90
  	JOIN forest_area_2016 AS fa16
  	ON fa90.f_countryname = fa16.f_countryname)
SELECT 
	f_countryname,
	(forest_area_sqkm_16-forest_area_sqkm_90) AS forest_area_increase
FROM joined_1990_2016
WHERE forest_area_sqkm_90 < forest_area_sqkm_16
ORDER BY 2 DESC;

-- Checking for countries that have increased in forest area per sqkm from 1990 to 2016
-- China has the highest forest area increase of 527,229.06 sqkm
-- The next largest increase of forest area was the US with a rise of 79,200.00 sqkm

WITH forest_area_percent_1990 AS
	(SELECT f_countryname, f.forest_percentage AS forest_percent_1990
     FROM forestation f
     WHERE f_year = '1990'),
forest_percentage_2016 AS
	(SELECT f_countryname, f.forest_percentage AS forest_percent_2016
    FROM forestation f
    WHERE f_year ='2016'),
joined_1990_2016 AS
	(SELECT fp90.f_countryname AS country_name, fp90.forest_percent_1990 AS forest_percent_1990, fp16.forest_percent_2016 AS forest_percent_2016
     FROM forest_area_percent_1990 AS fp90
     JOIN forest_percentage_2016 AS fp16
     ON fp90.f_countryname = fp16.f_countryname)
SELECT 
	country_name, 
    	ROUND(((forest_percent_2016 - forest_percent_1990)/forest_percent_1990 *100)::numeric, 2) AS percent_increase,
    	forest_percent_1990,
    	forest_percent_2016	
FROM joined_1990_2016
WHERE forest_percent_2016 > forest_percent_1990
ORDER BY 2 DESC;

-- Checking for the percentage of forest areas that have increased from 1990 to 2016
-- The largest percent increase of forest areas goes to Iceland with 212.50%
-- The land mass of China and the US are large compared to Iceland, which result in the smaller country to have a higher percentage of increase


WITH forest_area_1990 AS (
  SELECT f_countryname,  forest_area_sqkm, region, f_year
 FROM forestation 
 WHERE f_year = 1990), 
forest_area_2016 AS ( 
  SELECT f_countryname, forest_area_sqkm, f_year
  FROM forestation 
  WHERE f_year = 2016),
joined_1990_2016 AS (
  SELECT fa90.f_countryname, fa90.region, fa90.forest_area_sqkm AS forest_area_sqkm_90, fa90.f_year AS year_90, fa16.forest_area_sqkm AS forest_area_sqkm_16, fa16.f_year AS year_16
  FROM forest_area_1990 AS fa90
  JOIN forest_area_2016 AS fa16
  ON fa90.f_countryname = fa16.f_countryname) 
SELECT f_countryname AS country, region, ABS((forest_area_sqkm_90 - forest_area_sqkm_16)) AS
    abs_forest_area_change, forest_area_sqkm_90, forest_area_sqkm_16
FROM joined_1990_2016
WHERE forest_area_sqkm_16 < 
      forest_area_sqkm_90 AND f_countryname != 'World'
ORDER BY 3 DESC
LIMIT 5;

-- Checking for the top 5 countries with the largest forest area decrease from 1990 to 2016


WITH forest_area_percent_1990 AS
	(SELECT f_countryname, f.forest_percentage AS forest_percent_1990, region
     	FROM forestation AS f
     	WHERE f_year = '1990'),
forest_percentage_2016 AS
	(SELECT f_countryname, f.forest_percentage AS forest_percent_2016
   	 FROM forestation AS f
    	WHERE f_year ='2016'),
joined_1990_2016 AS
	(SELECT fp90.f_countryname AS country_name, fp90.forest_percent_1990 AS forest_percent_1990, fp16.forest_percent_2016 AS forest_percent_2016, fp90.region AS region
     	FROM forest_area_percent_1990 AS fp90
     	JOIN forest_percentage_2016 AS fp16
    	 ON fp90.f_countryname = fp16.f_countryname)
SELECT country_name, 
	ROUND(((forest_percent_1990 - forest_percent_2016)/forest_percent_1990) *100::numeric,2) AS percent_change, region, forest_percent_1990, forest_percent_2016
FROM joined_1990_2016
WHERE forest_percent_1990 > forest_percent_2016
ORDER BY 2 DESC
LIMIT 5;

-- Checking for the top 5 countries with the largest percentage of forest area decrease from 1990 to 2016


SELECT  
	CASE
	WHEN forest_percentage <= 25 THEN '0-25' 
   	WHEN forest_percentage > 25 AND forest_percentage <=50 THEN '25-50' 
	WHEN forest_percentage > 50 AND forest_percentage <=75 THEN '50-75'
   	WHEN forest_percentage > 75 AND forest_percentage <=100 THEN'75-100'
    	ELSE 'NULL'
	END AS quartiles,
    	COUNT(f_countryname) AS num_of_countries
FROM forestation
WHERE f_year = 2016 AND f_countryname != 'World'
GROUP BY quartiles
ORDER BY quartiles;

-- Created a table with quartiles to check for the number of countries within each quartiles


SELECT  
	CASE
	WHEN forest_percentage <= 25 THEN '0-25' 
    	WHEN forest_percentage > 25 AND forest_percentage <=50 THEN '25-50' 
	WHEN forest_percentage > 50 AND forest_percentage <=75 THEN '50-75'
   	WHEN forest_percentage > 75 AND forest_percentage <=100 THEN'75-100'
   	ELSE 'NULL'
	END AS quartiles,
    	f_countryname,
   	forest_percentage,
    	region
FROM forestation
WHERE f_year = 2016 AND forest_percentage > 75 AND forest_percentage <=100
GROUP BY quartiles, f_countryname, forest_percentage, region
ORDER BY forest_percentage DESC;