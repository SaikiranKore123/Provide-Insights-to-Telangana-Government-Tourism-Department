create database Visitors;
use visitors;

CREATE TABLE DomesticVisitors (
    district VARCHAR(255),
    date DATE,
    month VARCHAR(50),
    year INT,
    visitors INT
);
select * from domesticvisitors;

CREATE TABLE Foreignvisitors (
    district VARCHAR(255),
    date DATE,
    month VARCHAR(50),
    year INT,
    visitors INT
);
select count(*) from foreignvisitors;

-- 1.List down the top 10 districts that have the highest 
--      number of domestic visitors overall (2016-2019)? 
-- (Insight: Get an overview of districts that are doing well)

select district,sum(visitors) as total_visitors from domesticvisitors
group by district
order by total_visitors desc
limit 10;

-- 2. List down the top 3 districts based on compounded 
-- annual growth rate (CAGR) of visitors between (2016-2019)? 
-- (Insight: Districts that are growing) 

-- CAGR = (Ending Value / Beginning Value)^(1 / Number of Years) – 1.
SELECT * FROM visitors.domesticvisitors;

with cte as(
select district,year as y ,sum(visitors) as total_visitors
 from domesticvisitors d
group by district,y
order by district,y asc),
cte1 as(
select district,
		sum(case when y =2016 then total_visitors end) as vis_2016,
		sum(case when y =2019 then total_visitors end) as  vis_2019 
from cte
group by district)

select district,(POW((vis_2019 / vis_2016), (1.0 / 3)) - 1) as cagr from cte1
order by cagr desc
limit 3;

-------------------------------------------------------------------------------------------
-- Including domestic and foreign visitors combined
with cte0 as(
select * from domesticvisitors 
union all
select * from foreignvisitors),cte01 as(

select district,year as y ,sum(visitors) as total_visitors
 from cte0 
group by district,y
order by district,y asc),

cte1 as(
select district,
		sum(case when y =2016 then total_visitors end) as vis_2016,
		sum(case when y =2019 then total_visitors end) as  vis_2019 
from cte01
group by district)

select district,(POW((vis_2019 / vis_2016), (1.0 / 3)) - 1) as cagr from cte1
order by cagr desc
limit 3;

--------------------------------------------------------------------------------------------
SELECT * FROM visitors.total_visitors as total_visitors;

with cte as(
select district,
		sum(case when y =2016 then total_visitors end) as vis_2016,
		sum(case when y =2019 then total_visitors end) as  vis_2019 
from total_visitors
group by district)

select district,(POW((vis_2019 / vis_2016), (1.0 / 3)) - 1) as cagr from cte
order by cagr desc
limit 3;
--------------------------------------------------------------------------------------------

# 2nd way
SELECT district,
       (POW(
           SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) /
           NULLIF(SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END), 0),
           1.0 / 3
       ) - 1) AS cagr
FROM domesticvisitors
WHERE year IN (2016, 2019)
GROUP BY district
ORDER BY cagr DESC
LIMIT 3;


-- 3. List down the bottom 3 districts based on compounded 
-- annual growth rate (CAGR) of visitors between (2016 - 2019)? 
-- (Insight: Districts that are declining

------------------------------------------------------------------------------
SELECT * FROM visitors.total_visitors as total_visitors;

with cte as(
select district,
		sum(case when y =2016 then total_visitors end) as vis_2016,
		sum(case when y =2019 then total_visitors end) as  vis_2019 
from total_visitors
group by district),cte1 as(

select district,(POW((vis_2019 / vis_2016), (1.0 / 3)) - 1) as cagr from cte
order by cagr asc )
select * from cte1 where cagr is not null
limit 3;
------------------------------------------------------------------------------
with cte as(
select district,year as y ,sum(visitors) as total_visitors
 from domesticvisitors d
group by district,y
order by district,y asc),cte1 as(

select district,
		sum(case when y =2016 then total_visitors end) as vis_2016,
		sum(case when y =2019 then total_visitors end) as  vis_2019 
from cte
group by district),cte2 as(

select district,(POW((vis_2019 / vis_2016), (1.0 / 3)) - 1) as cagr from cte1
order by cagr asc)

select * from cte2 where cagr is not null
limit 3;

-- 4. What are the peak and low season months for Hyderabad based 
-- on the data from 2016 to 2019 for Hyderabad district? 
-- (Insight: Government can plan well for the peak seasons 
-- and boost low seasons by introducing new events)

with cte as(
select * from domesticvisitors 
union all
select * from foreignvisitors)

select district,year as y ,month m,sum(visitors) as total_visitors
 from cte
group by district,y,m
order by district,y asc;

-- or -- 
select * from total_visitors;

-- Peak season months for Hyderabad district
select m,sum(total_visitors) as total_vistors_per_month from total_visitors
where district = "Hyderabad"
group by m
order by total_vistors_per_month desc ;

-- Low season months for Hyderabad district
select m,sum(total_visitors) as total_vistors_per_month from total_visitors
where district = "Hyderabad"
group by m
order by total_vistors_per_month asc; 

-- 5. Show the top & bottom 3 districts with high domestic 
-- to foreign tourist ratio? 
-- (Insight: Government can learn from top districts and 
-- replicate the same to bottom districts which can improve 
-- the foreign visitors as foreign visitors will bring more revenue)

# top 3 districts with high domestic to foreign tourist ratio
with cte as(
SELECT district, sum(visitors) as d_total_visitors  FROM visitors.domesticvisitors
group by district
order by d_total_visitors asc),

cte1 as(
SELECT cte.district, d_total_visitors, sum(f.visitors) as f_total_visitors  
FROM visitors.foreignvisitors f
join cte cte
on cte.district = f.district
group by cte.district
order by f_total_visitors asc)
,cte2 as(
select *,ifnull(d_total_visitors/f_total_visitors,' ') as Ratio from cte1)
select * from cte2 where Ratio != ' '
order by cast(ratio as float)  desc
 limit 3;
 
 # Bottom 3 districts with high domestic to foreign tourist ratio
 with cte as(
SELECT district, sum(visitors) as d_total_visitors  FROM visitors.domesticvisitors
group by district
order by d_total_visitors asc),

cte1 as(
SELECT cte.district, d_total_visitors, sum(f.visitors) as f_total_visitors  
FROM visitors.foreignvisitors f
join cte cte
on cte.district = f.district
group by cte.district
order by f_total_visitors asc)
,cte2 as(
select *,ifnull(d_total_visitors/f_total_visitors,' ') as Ratio from cte1)
 
 select * from cte2 where Ratio != ' '
order by cast(ratio as float)  asc
 limit 3;
 
-- Secondary Research Questions: (Need to do research and get additional data) 

CREATE TABLE population_data (
    district VARCHAR(255),
    resident_population INT
);
select * from population_data;

SELECT * FROM visitors.population_data;
-- 6. List the top & bottom 5 districts based on 
-- 'population to tourist footfall ratio *' ratio in 2019? 
-- (* ratio: Total Visitors / Total Residents Population in the given year) 
-- (Insight: Find the bottom districts and create a plan to accommodate more tourists) 

#Bottom 5 districts based on population to tourist footfall ratio
with cte as(
select  p.district,sum(total_visitors) as total_visitors, min(resident_population) as resident_population
from total_visitors t
join population_data p
on t.district = p.district
group by p.district),
cte1 as(
select  *,(total_visitors/resident_population) as population_to_tourist_footfall_ratio
from cte
order by population_to_tourist_footfall_ratio)

select * from cte1
where population_to_tourist_footfall_ratio !=0
limit 5;

#top  5 districts based on population to tourist footfall ratio
with cte as(
select  p.district,sum(total_visitors) as total_visitors, min(resident_population) as resident_population
from total_visitors t
join population_data p
on t.district = p.district
group by p.district),
cte1 as(
select  *,(total_visitors/resident_population) as population_to_tourist_footfall_ratio
from cte
order by population_to_tourist_footfall_ratio desc)

select * from cte1
where population_to_tourist_footfall_ratio !=0
limit 5;


-- 7. What will be the projected number of domestic and foreign tourists in Hyderabad 
-- in 2025 based on the growth rate from previous years? 
-- (Insight: Better estimate of incoming tourists count so that government can plan 
-- the infrastructure better) 

with cte as(
select district,y,sum(total_visitors) as total_visitors from total_visitors
where district = "Hyderabad"
group by district,y),cte1 as(select *,total_visitors as V_2019 from cte where y=2019),
cte2 as(select *,total_visitors as V_2018 from cte where y=2018),
growth_calculation as(
SELECT 
    c2.district,c2.V_2018,c1.V_2019,
    ((c1.V_2019 - c2.V_2018) / c2.V_2018) * 100 AS growth_rate
FROM cte2 c2
JOIN cte1 c1 ON c2.district = c1.district)

SELECT 
    district,V_2019,V_2018,growth_rate,
    -- Calculate projected tourists for 2025
    round((V_2019 * POWER((1 + (growth_rate / 100)), 6))) AS projected_tourists_2025
FROM growth_calculation;

-- 8. Estimate the projected revenue for Hyderabad in 2025 based 
-- on average spend per tourist (approximate data) Tourist Average Revenue ₹ ₹ Foreign 
-- Tourist 5,600.00 Domestic Tourist 1,200.00 Suggested areas for further secondary research 
-- to get more insights: Crime rate, Cleanliness Ratings, Infrastructure Development 
-- Ratings etc.



select * from district_yearwise_visitors;


with cte1 as(
select 
sum(case when year =2018 then domestic_visitors end) as vis_2018,
sum(case when year =2019 then domestic_visitors end) as vis_2019
from district_yearwise_visitors
where district = "Hyderabad"),
cte2 as (
select *,(100*(vis_2019-vis_2018))/vis_2018 as gr
from cte1),
 cte3 as(
select (vis_2019*pow((1+gr/100),6))*1200 as rev
from cte2),
 cte4 as(
select 
sum(case when year =2018 then foreign_visitors end) as vis_2018,
sum(case when year =2019 then foreign_visitors end) as vis_2019
from district_yearwise_visitors
where district = "Hyderabad"),
cte5 as (
select *,(100*(vis_2019-vis_2018))/vis_2018 as gr
from cte4),
 cte6 as(
select (vis_2019*pow((1+gr/100),6))*5600 as rev
from cte5)
select * from (
select * from cte3
union all
select * from cte6);



WITH cte1 AS (
    SELECT 
        SUM(CASE WHEN year = 2018 THEN domestic_visitors ELSE 0 END) AS vis_2018,
        SUM(CASE WHEN year = 2019 THEN domestic_visitors ELSE 0 END) AS vis_2019
    FROM district_yearwise_visitors
    WHERE district = 'Hyderabad'
),
cte2 AS (
    SELECT *,
        CASE 
            WHEN vis_2018 > 0 THEN (100 * (vis_2019 - vis_2018)) / vis_2018 
            ELSE 0 
        END AS gr
    FROM cte1
),
cte3 AS (
    SELECT 
        (vis_2019 * POWER((1 + gr / 100), 6)) * 1200 AS rev
    FROM cte2
),
cte4 AS (
    SELECT 
        SUM(CASE WHEN year = 2018 THEN foreign_visitors ELSE 0 END) AS vis_2018,
        SUM(CASE WHEN year = 2019 THEN foreign_visitors ELSE 0 END) AS vis_2019
    FROM district_yearwise_visitors
    WHERE district = 'Hyderabad'
),
cte5 AS (
    SELECT *,
        CASE 
            WHEN vis_2018 > 0 THEN (100 * (vis_2019 - vis_2018)) / vis_2018 
            ELSE 0 
        END AS gr
    FROM cte4
),
cte6 AS (
    SELECT 
        (vis_2019 * POWER((1 + gr / 100), 6)) * 5600 AS rev
    FROM cte5
),
combined AS (
    SELECT 
        'Domestic' AS visitor_type, rev FROM cte3
    UNION ALL
    SELECT 
        'Foreign' AS visitor_type, rev FROM cte6
)
SELECT 
    SUM(rev) AS total_revenue
FROM combined;

WITH visitor_data AS (
    SELECT 
        SUM(CASE WHEN year = 2018 THEN domestic_visitors ELSE 0 END) AS domestic_vis_2018,
        SUM(CASE WHEN year = 2019 THEN domestic_visitors ELSE 0 END) AS domestic_vis_2019,
        SUM(CASE WHEN year = 2018 THEN foreign_visitors ELSE 0 END) AS foreign_vis_2018,
        SUM(CASE WHEN year = 2019 THEN foreign_visitors ELSE 0 END) AS foreign_vis_2019
    FROM district_yearwise_visitors
    WHERE district = 'Hyderabad'
),
calculated_revenue AS (
    SELECT
        CASE 
            WHEN domestic_vis_2018 > 0 THEN (domestic_vis_2019 * POWER((1 + (100 * (domestic_vis_2019 - domestic_vis_2018) / domestic_vis_2018) / 100), 6)) * 1200 
            ELSE 0 
        END AS domestic_revenue,
        CASE 
            WHEN foreign_vis_2018 > 0 THEN (foreign_vis_2019 * POWER((1 + (100 * (foreign_vis_2019 - foreign_vis_2018) / foreign_vis_2018) / 100), 6)) * 5600 
            ELSE 0 
        END AS foreign_revenue
    FROM visitor_data
)
SELECT 
    domestic_revenue + foreign_revenue AS total_revenue
FROM calculated_revenue;


# District_yearwise_visitors
select d.district,d.year,sum(d.visitors) as Domestic_visitors,sum(f.visitors) as foreign_visitors,
		sum(d.visitors) + sum(f.visitors) as Total_visitors from domesticvisitors d
join foreignvisitors f
using(district,year,month)
group by d.district,d.year;


