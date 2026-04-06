-- This is cafe sales data from sales management system. This query checks data quality and fixes errors. 

-- 1.1. Check uniqueness of transaction_id 
SELECT COUNT(transaction_id) as nr_of_rows, COUNT(DISTINCT transaction_id) AS distinct_ids
FROM cafe_sales;

SELECT COUNT(transaction_id) - COUNT(DISTINCT transaction_id) AS difference_from_rows
FROM cafe_sales;

-- Find the rows which are not unique
SELECT transaction_id, count(*)
FROM cafe_sales
GROUP BY  transaction_id
HAVING count(*) > 1;

-- 2.1. Check values in item column
SELECT item, count(*) as nr_of_rows
FROM cafe_sales
group by item
ORDER BY nr_of_rows ASC;

-- 2.2. Create a new column "item_cleaned" where ERROR and NULL are mapped to UNKNOWN
-- Select distinct values from "item" and "item_cleaned" column 
SELECT DISTINCT item, CASE WHEN item = 'ERROR' THEN 'UNKNOWN'
WHEN item IS NULL THEN 'UNKNOWN' 
ELSE item END AS item_cleaned
from cafe_sales;

-- 3.1. Check if quantity is a whole number
SELECT *
FROM cafe_sales
WHERE quantity % 1 <> 0;

-- 3.2. Check quantity values 
SELECT quantity, count(*) as nr_of_rows
FROM cafe_sales
group by quantity
ORDER BY nr_of_rows ASC;

-- 4.1. Check unit price minimum and maximum values 
SELECT MIN(unit_price) as minimumprice, MAX(unit_price) AS maximumprice
FROM cafe_sales;

-- 4.2. Check if unit price is a decimal number 
SELECT DISTINCT unit_price, typeof(unit_price)
FROM cafe_sales
WHERE typeof(unit_price) != 'real';

-- 4.3. Select rows where unit_price is decimal number 
SELECT *
FROM cafe_sales
WHERE typeof(unit_price) = 'real';

-- 5.1. Check if total spent is a decimal number 
SELECT DISTINCT total_spent, typeof(total_spent)
FROM cafe_sales
WHERE typeof(total_spent) != 'real';

-- 5.2. Create new column "total_spent_calc" based on multiplication of quantity and unit price. 
-- Select only rows where unit price is an actual number. 
SELECT quantity * unit_price AS total_spent_calc
FROM cafe_sales
WHERE typeof(unit_price) = 'real';

-- 6.1. Select values from payment method 
SELECT payment_method, count(*) as nr_of_rows
FROM cafe_sales
group by payment_method
ORDER BY nr_of_rows ASC;

-- 6.2. Create a new column "payment_method_cleaned" where ERROR and NULL are mapped to UNKNOWN
-- Select distinct values from "payment_method" and "payment_method_cleaned" column 
SELECT DISTINCT payment_method, CASE WHEN payment_method = 'ERROR' THEN 'UNKNOWN'
WHEN payment_method IS NULL THEN 'UNKNOWN' 
ELSE payment_method END AS payment_method_cleaned
from cafe_sales;

-- 7.1.  Select values from location 
SELECT location, count(*) as nr_of_rows
FROM cafe_sales
group by location
ORDER BY nr_of_rows ASC;

-- 7.2. Create a new column "location_cleaned" where ERROR and NULL are mapped to UNKNOWN
-- Select distinct values from "location" and "location_cleaned" column 
SELECT DISTINCT location, CASE WHEN location = 'ERROR' THEN 'UNKNOWN'
WHEN location IS NULL THEN 'UNKNOWN' 
ELSE location END AS location_cleaned
from cafe_sales;

-- 8.1. Check values that are not a valid date in transaction_date 
SELECT DISTINCT transaction_date, DATE(transaction_date)
FROM cafe_sales
WHERE DATE(transaction_date) IS NULL OR transaction_date != DATE(transaction_date)
ORDER BY transaction_date DESC;

-- 8.2. Select only rows where transaction date is a valid date
SELECT * 
FROM cafe_sales 
WHERE DATE(transaction_date) IS NOT NULL AND transaction_date = DATE(transaction_date);

-- Create a clean dataset 
SELECT transaction_id 
    ,CASE
    	WHEN UPPER(item) = 'ERROR' OR item IS NULL THEN 'UNKNOWN'
        ELSE item
    END AS item_cleaned
    ,quantity
    ,unit_price
    ,quantity * unit_price AS total_spent_calc
    ,CASE
    	WHEN UPPER(payment_method) = 'ERROR' OR payment_method IS NULL THEN 'UNKNOWN'
        ELSE payment_method
    END AS payment_method_cleaned
    ,CASE
    	WHEN UPPER(location) = 'ERROR' OR location IS NULL THEN 'UNKNOWN'
        ELSE location
    END AS location_cleaned
    ,transaction_date
FROM cafe_sales
WHERE typeof(unit_price) = 'real'
	AND DATE(transaction_date) IS NOT NULL 
    AND transaction_date = DATE(transaction_date);






