-- Analyze cafe sales and compare them to budget 

-- 1.1. Cafe sales by Year-Month 
SELECT TO_CHAR(transaction_date , 'YYYY-MM') AS year_month, 
SUM(total_spent_calc ) as total_sales
FROM cafe_sales_cleaned
GROUP BY year_month 
ORDER BY year_month;

-- 1.2. Monthly sales vs monthly budget 
SELECT ms.year_month, ms.total_sales, cb.budget_sum
FROM (SELECT TO_CHAR(transaction_date , 'YYYY-MM') AS year_month, 
SUM(total_spent_calc ) as total_sales
FROM cafe_sales_cleaned
GROUP BY year_month 
ORDER BY year_month) AS ms 
LEFT JOIN cafe_budget AS cb 
ON ms.year_month = cb.year_month;

-- Alternatiivne lahendus 1
WITH monthly_sales AS (SELECT TO_CHAR(transaction_date , 'YYYY-MM') AS year_month, 
SUM(total_spent_calc ) as total_sales
FROM cafe_sales_cleaned
GROUP BY year_month 
ORDER BY year_month)
SELECT cb.year_month, cb.budget_sum, ms.total_sales, ms.total_sales - cb.budget_sum AS difference
FROM cafe_budget AS cb 
FULL OUTER JOIN monthly_sales AS ms ON cb.year_month = ms.year_month

-- Alternatiivne lahendus 2 - kui eelarve tabelis on kõik kuud olemas
WITH monthly_sales AS (SELECT TO_CHAR(transaction_date , 'YYYY-MM') AS year_month, 
SUM(total_spent_calc ) as total_sales
FROM cafe_sales_cleaned
GROUP BY year_month 
ORDER BY year_month)
SELECT cb.year_month, cb.budget_sum, ms.total_sales, ms.total_sales - cb.budget_sum AS difference
FROM cafe_budget AS cb 
LEFT JOIN monthly_sales AS ms ON cb.year_month = ms.year_month

-- Alternatiivne lahendus 3
SELECT 
    b.year_month, SUM(c.total_spent_calc) AS actual_sales,
    b.budget_sum
FROM cafe_sales_cleaned c
LEFT JOIN cafe_budget b
    ON TO_CHAR(c.transaction_date, 'YYYY-MM') = b.year_month
GROUP BY b.year_month,b.budget_sum
ORDER BY b.year_month;

-- Alternatiivne lahendus 4 
select
	cb.year_month 
	,cb.budget_sum
	,csc2.sale_sum
from cafe_budget cb
	left join (
		select sum(csc.total_spent_calc) as sale_sum, to_char(csc.transaction_date, 'YYYY-MM') as year_month
		from cafe_sales_cleaned csc 
		group by year_month
	) csc2 on cb.year_month = csc2.year_month;

-- Alternatiivne lahendus 5 
select
	cb.year_month 
	,(
		select sum(csc.total_spent_calc) as sale_sum
		from cafe_sales_cleaned csc 
		where to_char(csc.transaction_date, 'YYYY-MM') = cb.year_month 
		group by to_char(csc.transaction_date, 'YYYY-MM')
	)
	,cb.budget_sum 
from cafe_budget cb

-- 1.3. Cafe sales by item 
SELECT item_cleaned, ROUND(SUM(total_spent_calc), 0) || ' €' as sales_sum
FROM cafe_sales_cleaned
GROUP BY item_cleaned;

SELECT item_cleaned, ROUND(SUM(total_spent_calc), 2) as sales_sum
FROM cafe_sales_cleaned
GROUP BY item_cleaned;

-- 1.4. Compare average sale sum per item to average sale sum for all items 
select csc.item_cleaned ,
round(avg(csc.total_spent_calc ),2) as avg_by_item,
(select round(AVG(csc.total_spent_calc ), 2) as avg_total_spent 
	from cafe_sales_cleaned csc ),
round(avg(csc.total_spent_calc ) - (select AVG(csc2.total_spent_calc ) 
	as avg_total_spent from cafe_sales_cleaned csc2 ), 2) as difference_from_avg_total
from cafe_sales_cleaned csc 
group by csc.item_cleaned 
order by difference_from_avg_total DESC;

-- 1.5. Filter out only items where sales were more than 10 000
SELECT item_cleaned, SUM(total_spent_calc) AS kogumyyk
FROM cafe_sales_cleaned
GROUP  BY item_cleaned
HAVING SUM(total_spent_calc) > 10000
ORDER BY kogumyyk DESC;

-- ALternatiivne lahendus 1 
SELECT item_cleaned,
total_spent FROM (SELECT item_cleaned, ROUND(SUM(total_spent_calc), 2) as total_spent
FROM cafe_sales_cleaned
GROUP BY item_cleaned) 
WHERE total_spent > 10000;

-- 1.6. What were sales by payment method?
SELECT payment_method_cleaned, SUM(total_spent_calc) as sales_sum
FROM cafe_sales_cleaned
GROUP BY payment_method_cleaned 
UNION  ALL 
SELECT  'Total', SUM(total_spent_calc)
FROM cafe_sales_cleaned;

-- 1.7. Compare average sale sum by location to average sale sum
SELECT 
    location_cleaned,
    ROUND(AVG(total_spent_calc), 2) AS avg_location_sale,
    ROUND((SELECT AVG(total_spent_calc) FROM cafe_sales_cleaned), 2) AS avg_all_sales,
    ROUND(
        AVG(total_spent_calc) - 
        (SELECT AVG(total_spent_calc) FROM cafe_sales_cleaned),
    2) AS difference
FROM cafe_sales_cleaned
GROUP BY location_cleaned 
ORDER BY avg_location_sale DESC;

-- 1.8. What were sales by location?
SELECT location_cleaned,
       SUM(total_spent_calc) AS sales_sum,
       ROUND(SUM(total_spent_calc), 2) AS sales_sum_rounded
FROM cafe_sales_cleaned
GROUP BY location_cleaned
ORDER BY sales_sum DESC;

-- 1.9. How many units per item were sold?

-- 1.10. Filter out only items where more than 3000 units were sold

