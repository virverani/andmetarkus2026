-- 1. Leia müügisummad toodete kaupa – toote ID ja müügisumma
SELECT product_id, ROUND(sum(sale_sum),2) AS muugisumma
FROM sales_table
GROUP BY product_id 
ORDER BY product_id;

-- 2. Leia müügisummad klientide kaupa – kliendi ID ja müügisumma
SELECT customer_id, ROUND(sum(sale_sum),2) AS muugisumma
FROM sales_table
GROUP BY customer_id 
ORDER BY customer_id;


-- 3. Leia müügisummad müügiesindajate kaupa – kliendiesindaja ID ja müügisumma
SELECT sales_rep_id , ROUND(sum(sale_sum),2) AS muugisumma
FROM sales_table
GROUP BY sales_rep_id 
ORDER BY sales_rep_id;

-- 4. Leia müügisummad aastate kaupa – aasta ja müügisumma
SELECT EXTRACT (year from sale_date) AS sales_year, ROUND(SUM(sale_sum), 2)
FROM sales_table
GROUP BY sales_year
ORDER BY sales_year;

-- Alternatiivne variant 
SELECT DATE_PART ('year', sale_date) AS sales_year, ROUND(SUM(sale_sum), 2)
FROM sales_table
GROUP BY sales_year
ORDER BY sales_year;

-- 5. Lisa müükidele müügisumma kategooriad
-- Large Sale > 500
-- Medium Sale <= 500 and >= 250
-- Small Sale < 250
SELECT *,
	CASE WHEN sale_sum < 250 THEN 'Small Sale'
	WHEN sale_sum >= 250 and sale_sum <= 500 THEN 'Medium Sale'
	WHEN sale_sum >= 500 THEN 'Large Sale'
	ELSE 'ERROR' END AS sale_category
	FROM sales_table;

-- Lisa see tulp müügitabelisse
ALTER table sales_table ADD COLUMN sale_category VARCHAR(50);

UPDATE sales_table SET sale_category = 
CASE WHEN sale_sum < 250 THEN 'Small Sale'
	WHEN sale_sum >= 250 and sale_sum <= 500 THEN 'Medium Sale'
	WHEN sale_sum >= 500 THEN 'Large Sale'
	ELSE 'ERROR' END;
	
-- 6. Leia müükide arv ja müügisumma müügisumma kategooriate kaupa - Müügisumma kategooria, müükide arv, müügisumma
SELECT sale_category, COUNT(*) as nr_of_sales, SUM(sale_sum) as total_sum
FROM sales_table 
GROUP BY sale_category 
ORDER BY sale_category;

-- Alternatiivne lahendus ajutise päringu abil 

WITH sales_per_category AS (
SELECT *, 
CASE WHEN sale_sum < 250 THEN 'Small Sale'
	WHEN sale_sum >= 250 and sale_sum <= 500 THEN 'Medium Sale'
	WHEN sale_sum >= 500 THEN 'Large Sale'
	ELSE 'ERROR' END AS sale_category_new
	FROM sales_table)	
SELECT sale_category_new, sum(sale_sum), count(*)
FROM sales_per_category
GROUP BY sale_category_new;

select
	case
		when st.sale_sum > 500 then 'Large Sale'
		when st.sale_sum <= 500 and st.sale_sum >= 250 then 'Medium Sale'
		when st.sale_sum < 250 then 'Small Sale'
		else 'ERROR'
	end as sale_category
	,count(st.sale_id) as sales_count
	,sum(st.sale_sum) as sales_sum
from sales_table st 
group by sale_category;


-- 7. Mida veel võiks leida?

-- 7.1. Allahindlus müügiesindajate lõikes võrreldes keskmise allahindlusega
SELECT sales_rep_id, AVG(discount) as avg_discount_per_sales_rep,
(SELECT AVG(discount) AS avg_discount_in_company FROM sales_table), 
AVG(DISCOUNT) - (SELECT AVG(discount) AS avg_discount_in_company FROM sales_table) AS difference_from_company_average
FROM sales_table st 
GROUP BY sales_rep_id;

-- 7.2. Leia müügisummad regioonide kaupa – regiooni ID ja müügisumma
SELECT region_id, ROUND(sum(sale_sum),2) AS muugisumma
FROM sales_table
GROUP BY region_id 
ORDER BY region_id;

