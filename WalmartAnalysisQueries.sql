select * from walmart;
select count(*) from walmart;

select distinct payment_method from walmart;

select  payment_method, count(*)
from walmart
group by payment_method;

select count(distinct Branch)
from walmart;

select max(quantity) from walmart;

-- Bussiness Problems
-- Q1. Find different number of payment methods , number of transactions and number of quantity sold
select  payment_method, 
		count(*), 
        sum(quantity) as num_of_qty_sold
from walmart
group by payment_method;

-- Q2.  Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating

SELECT Branch, category, avg_rating
FROM (
    SELECT 
        Branch,
        category,
        avg_rating,
        RANK() OVER(PARTITION BY Branch ORDER BY avg_rating DESC) AS rnk
    FROM (
        SELECT Branch, category, AVG(rating) AS avg_rating
        FROM walmart
        GROUP BY Branch, category
    ) avg_table
) ranked_table
WHERE rnk = 1;

-- -- Q3: Identify the busiest day for each branch based on the number of transactions

SELECT Branch, day_name, no_transactions
FROM (
    SELECT 
        Branch, 
        DAYNAME(date) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY Branch, day_name
) ranked_table
WHERE rnk = 1;

-- Q4: Calculate the total quantity of items sold per payment method

select  payment_method, sum(quantity) as no_of_quantity
from walmart
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
-- List the city, avg_rating, min_rating, max_rating
select 
    City, 
    category, 
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
from walmart
group by City, category;

-- Q6: Calculate the total profit for each category

SELECT category,
       SUM(total) AS total_revenue, 
       SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch

WITH cte AS (
    SELECT 
        Branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY Branch, payment_method
)
SELECT *
FROM cte
WHERE rnk = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
-- Find out each of the shift and number of invoices

SELECT Branch, 
       CASE  
           WHEN HOUR(TIME(time)) < 12 THEN 'Morning'  
           WHEN HOUR(TIME(time)) >= 12 AND HOUR(TIME(time)) < 17 THEN 'Afternoon'  
           ELSE 'Evening'  
       END AS shift,  
       COUNT(*) AS No_Of_Invoices  
FROM walmart  
GROUP BY Branch, shift  
ORDER BY Branch, No_Of_Invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS(
	select Branch, 
		   SUM(total) as revenue
	from walmart
	where YEAR(DATE) = 2022
	GROUP BY Branch
),
revenue_2023 AS(
	select Branch, 
		   SUM(total) as revenue
	from walmart
	where YEAR(DATE) = 2023
	GROUP BY Branch
)
SELECT 
	rev2022.Branch,
    rev2022.revenue AS last_year_revenue,
    rev2023.revenue AS current_year_revenue,
    ROUND(((rev2022.revenue - rev2023.revenue)/rev2022.revenue * 100),2) AS revenue_decrease_ratio
FROM revenue_2022 AS rev2022
JOIN revenue_2023 AS rev2023 ON rev2022.Branch=rev2023.Branch
WHERE rev2022.revenue > rev2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

-- 10.Identify the most profitable product category in each branch
WITH category_profit AS (
   SELECT 
        Branch, 
        category, 
        SUM(total * profit_margin) AS total_profit,
        RANK() OVER(PARTITION BY Branch ORDER BY SUM(total * profit_margin) DESC) AS rnk
    FROM walmart
    GROUP BY Branch, category
)
SELECT Branch, category, total_profit
FROM category_profit
WHERE rnk = 1;

-- Q11: Find the month with the highest sales for each branch

WITH monthly_sales AS (
    SELECT 
        Branch, 
        MONTHNAME(date) AS month, 
        SUM(total) AS total_revenue,
        RANK() OVER(PARTITION BY Branch ORDER BY SUM(total) DESC) AS rnk
    FROM walmart
    GROUP BY Branch, month
)
SELECT Branch, month, total_revenue
FROM monthly_sales
WHERE rnk = 1;

-- Q12: Analyze customer shopping behavior - Find the average basket size per branch

SELECT 
    Branch, 
    ROUND(AVG(quantity), 2) AS avg_basket_size
FROM walmart
GROUP BY Branch
ORDER BY avg_basket_size DESC;










