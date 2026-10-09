-- E-COMMERCE SALES ANALYTICS
-- SQL Analysis Project
-- Database: ecommerce_analysis
-- Table: orders

USE ecommerce_analysis;

-- 1. KEY PERFORMANCE INDICATORS (KPIs)
SELECT
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    SUM(Quantity) AS total_quantity,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT `Customer ID`) AS total_customers
FROM orders;

-- 2. REGION ANALYSIS
SELECT
    Region,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM orders
GROUP BY Region
ORDER BY total_sales DESC;

-- 3. CATEGORY ANALYSIS
SELECT
    Category,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin
FROM orders
GROUP BY Category
ORDER BY total_sales DESC;

-- 4. SUB-CATEGORY ANALYSIS
SELECT
    `Sub-Category`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin
FROM orders
GROUP BY `Sub-Category`
ORDER BY total_sales DESC;

-- 5. PRODUCT ANALYSIS
SELECT
    `Product Name`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin
FROM orders
GROUP BY `Product Name`
ORDER BY total_sales DESC
LIMIT 10;

-- 6. CUSTOMER ANALYSIS
SELECT
    `Customer ID`,
    `Customer Name`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS profit_margin
FROM orders
GROUP BY `Customer ID`, `Customer Name`
ORDER BY total_sales DESC
LIMIT 10;

-- 7. TIME ANALYSIS
SELECT
    YEAR(`Order Date`) AS year,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM orders
GROUP BY YEAR(`Order Date`)
ORDER BY year;

-- 8. DISCOUNT ANALYSIS
SELECT
    ROUND(AVG(Discount) * 100, 2) AS average_discount_percentage,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit
FROM orders;

-- 9. PROFITABILITY CLASSIFICATION (CASE)
SELECT
    `Product Name`,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    CASE
        WHEN SUM(Profit) < 0 THEN 'Loss'
        WHEN SUM(Profit) = 0 THEN 'Break Even'
        ELSE 'Profit'
    END AS profitability_status
FROM orders
GROUP BY `Product Name`
ORDER BY total_profit DESC;

-- 10. CUSTOMER SEGMENT ANALYSIS (JOIN)
SELECT
    c.`Customer ID`,
    c.`Customer Name`,
    c.Segment,
    SUM(o.Sales) AS total_sales,
    SUM(o.Profit) AS total_profit
FROM customers c
JOIN orders o
    ON c.`Customer ID` = o.`Customer ID`
GROUP BY
    c.`Customer ID`,
    c.`Customer Name`,
    c.Segment
ORDER BY total_sales DESC
LIMIT 10;

-- 11. SUBQUERY ANALYSIS
-- Products with sales above the average product sales
SELECT
    `Product Name`,
    SUM(Sales) AS total_sales
FROM orders
GROUP BY `Product Name`
HAVING SUM(Sales) > (
    SELECT AVG(product_sales)
    FROM (
        SELECT SUM(Sales) AS product_sales
        FROM orders
        GROUP BY `Product Name`
    ) AS sales_summary
)
ORDER BY total_sales DESC;

-- 12. CATEGORY PERFORMANCE (CTE)
WITH category_performance AS (
    SELECT
        Category,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit
    FROM orders
    GROUP BY Category
)
SELECT
    Category,
    total_sales,
    total_profit,
    ROUND(total_profit / total_sales * 100, 2) AS profit_margin
FROM category_performance
ORDER BY total_sales DESC;

-- 13. TOP 3 PRODUCTS WITHIN EACH CATEGORY
-- (WINDOW FUNCTION)
WITH product_ranking AS (
    SELECT
        Category,
        `Product Name`,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY SUM(Sales) DESC
        ) AS product_rank
    FROM orders
    GROUP BY Category, `Product Name`
)
SELECT
    Category,
    `Product Name`,
    total_sales,
    total_profit,
    product_rank
FROM product_ranking
WHERE product_rank <= 3
ORDER BY Category, product_rank;