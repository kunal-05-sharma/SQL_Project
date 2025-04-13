 use case1;
 select * from weekly_sales limit 5;
 # data cleansing
 create table clean_weekly_sales as
 select week_date,
 week(week_date) as week_number,
 month(week_date) as month_number,
 year(week_date) as calender_year,
 region,platform,
 case 
 when segment = null then "Unknown"
 else segment
 end as segment,
 case 
 when right(segment,1) = '1' then "Young Adults"
 when right(segment,1) = '2' then "Middle Aged"
 when right(segment,1) in ('3','4') then "Retirees"
 else "Unknown"
 end as age_band,
 case
 when left(segment,1) = 'C' then "Couples"
 when left(segment,1) = 'F' then "Families"
 else "Unknown"
 end as demographic,
 customer_type,transactions,sales,
 round(sales/transactions,2) as avg_transactions
 from weekly_sales;
 select * from clean_weekly_sales limit 5;
 
 
 # Which week no. is missing in the table ?
 create table seq100(x int auto_increment primary key); 
 insert into seq100 values (),(),(),(),(),(),(),(),(),();
 insert into seq100 values (),(),(),(),(),(),(),(),(),();
 insert into seq100 values (),(),(),(),(),(),(),(),(),();
 insert into seq100 values (),(),(),(),(),(),(),(),(),();
 insert into seq100 values (),(),(),(),(),(),(),(),(),();
 insert into seq100 select x+50 from seq100;
 select * from seq100;
 create table seq52(select x from seq100 limit 52);
 select distinct x as week_day from seq52
 where x not in (select distinct week_number from clean_weekly_sales);

## 2.How many total transactions were there for each year in the dataset?
SELECT calender_year , sum(transactions) as total_transactions from clean_weekly_sales group by calender_year;

## 3.What are the total sales for each region for each month?
select region ,month_number, sum(sales) as total_sales from clean_weekly_sales group by month_number,region;

## 4.What is the total count of transactions for each platform
select platform,count(transactions) as count_of_transactions from clean_weekly_sales group by platform;

## 5.What is the percentage of sales for Retail vs Shopify for each month?
WITH cte_monthly_platform_sales AS (
  SELECT
    month_number,calendar_year,
    platform,
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY month_number,calendar_year, platform
)
SELECT
  month_number,calendar_year,
  ROUND(
    100 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS retail_percentage,
  ROUND(
    100 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) /
      SUM(monthly_sales),
    2
  ) AS shopify_percentage
FROM cte_monthly_platform_sales
GROUP BY month_number,calendar_year
ORDER BY month_number,calendar_year;

## 6.What is the percentage of sales by demographic for each year in the dataset?
SELECT calendar_year, demographic,SUM(SALES) AS yearly_sales,
  ROUND((100 * SUM(sales)/SUM(SUM(SALES)) OVER (PARTITION BY demographic)),2) AS percentage
FROM clean_weekly_sales
GROUP BY calendar_year,demographic
ORDER BY calendar_year, demographic;

## 7.Which age_band and demographic values contribute the most to Retail sales?

SELECT age_band,demographic,SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC;


