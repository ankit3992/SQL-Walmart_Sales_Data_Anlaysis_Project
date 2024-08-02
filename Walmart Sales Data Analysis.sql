-- ---------------------- Create Database ---------------------------------

CREATE DATABASE WalmartSalesData;

-- ----------------------- Create Table -----------------------------------

CREATE TABLE IF NOT EXISTS sales(
	Invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
	Branch VARCHAR(5) NOT NULL,
    City VARCHAR(10) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL,
    Gender VARCHAR(30) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    Total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    Payment_method VARCHAR(15) NOT NULL,
    Cogs DECIMAL(10,2) NOT NULL,
    Gross_margin_pct FLOAT(11,9),
    Gross_income DECIMAL(12, 4) NOT NULL,
    Rating FLOAT(2, 1)
);

-- --------------------------- Feature Engineering --------------------------

-- time_of_day --

SELECT time,
	(CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN 'Morning'
        WHEN time BETWEEN "12;01;00" AND "16;00;00" THEN 'Afternoon'
        ELSE 'Evening'
	END) AS time_of_day
 FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales SET time_of_day = (CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN 'Morning'
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN 'Afternoon'
        ELSE 'Evening'
	END);

-- day_name --

SELECT date,
	DAYNAME(date) AS day_name
 FROM sales;
 
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales SET day_name = DAYNAME(date);

-- month_name --

SELECT date,
 MONTHNAME(date) AS month_name
 FROM sales;
 
ALTER TABLE sales ADD COLUMN month_name VARCHAR(15);
UPDATE sales SET month_name = MONTHNAME(date);

-- ---------------------------------------------------------------------------------
-- ---------------------------------- Generic --------------------------------------

-- 1. How many unique cities does the data have? --

SELECT 
	DISTINCT city 
FROM sales;

-- 2. In which city is each branch? --

SELECT
	DISTINCT branch, city
FROM sales;

-- --------------------------- ------Product ---------------------------------------

-- 1. How many unique product lines does the data have? --

SELECT 
	DISTINCT product_line
FROM sales;

-- 2. What is the most common payment method? --

SELECT
	 Payment_method,
     COUNT(Payment_method) AS Count
FROM sales
GROUP BY Payment_method
ORDER BY Count DESC;

-- 3. What is the most selling product line? --

SELECT
	 Product_line,
     COUNT(Product_line) AS Cnt
FROM sales
GROUP BY Product_line
ORDER BY Cnt DESC;

-- 4. What is the total revenue by month? --

SELECT 
	month_name AS Month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS? --

SELECT 
	month_name AS Month,
    SUM(COGS) AS Total_Sales
FROM sales
GROUP BY month_name
ORDER BY Total_Sales DESC;

-- 6. What product line had the largest revenue? --

SELECT 
	DISTINCT Product_line,
    SUM(total) AS Total_Revenue
FROM sales
GROUP BY Product_line
ORDER BY Total_Revenue DESC;

-- 7. What is the city with the largest revenue? --

SELECT 
	DISTINCT city, branch,
    SUM(total) AS Total_Revenue
FROM sales
GROUP BY city, branch
ORDER BY Total_Revenue DESC;

-- 8. What product line had the largest VAT? --

SELECT 
	Product_line,
    AVG(VAT) AS Avg_Tax
FROM Sales
GROUP BY Product_line
ORDER BY Avg_Tax DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales --

SELECT
	AVG(quantity) AS Avg_Sales
FROM Sales;

SELECT
	Product_line,
    CASE 
		WHEN Avg(Quantity) > 5.4995 THEN 'Good'
        ELSE 'Bad'
	END AS Remark
FROM sales
GROUP BY Product_line;

-- 10. Which branch sold more products than average product sold? --

SELECT
	Branch,
    SUM(quantity) AS Qty
FROM sales
GROUP BY Branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11. What is the most common product line by gender? --

SELECT gender, product_line,
	COUNT(gender) AS cnt
FROM Sales
GROUP BY gender, product_line
ORDER BY cnt DESC;

-- 12. What is the average rating of each product line? --

SELECT
	Product_line,
    ROUND(AVG(rating),2) as Avg_Rating
FROM sales
GROUP BY Product_line
ORDER BY Avg_Rating DESC;

-- ----------------------------------------------------------------------------------
-- ---------------------------------- Sales -----------------------------------------

-- 1. Number of sales made in each time of the day per weekday --

SELECT
	time_of_day,
    COUNT(*) AS Total_sales
FROM sales
WHERE day_name <> 'Saturday' AND day_name <> 'Sunday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 2. Which of the customer types brings the most revenue? --

SELECT
	Customer_type,
    SUM(Total) AS Total_Revn
FROM sales
GROUP BY Customer_type
ORDER BY Total_Revn;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)? --

SELECT
	City,
    ROUND(AVG(VAT),2) AS AVG_Tax_Pct
FROM Sales
GROUP BY City
ORDER BY AVG_Tax_Pct DESC;

-- 4. Which customer type pays the most in VAT? --

SELECT
	Customer_type,
    ROUND(AVG(VAT),1) AS AVG_Tax
FROM Sales
GROUP BY Customer_type
ORDER BY AVG_Tax DESC;

-- ----------------------------------------------------------------------------------
-- ---------------------------------- Customer --------------------------------------

-- 1. How many unique customer types does the data have? --

SELECT
	DISTINCT customer_type
FROM sales;

-- 2. How many unique payment methods does the data have? --

SELECT
	DISTINCT payment_method
FROM sales;

-- 3. What is the most common customer type? --

SELECT
	Customer_type,
	COUNT(*) AS CNT
FROM sales
GROUP BY Customer_type
ORDER BY CNT DESC;

-- 4. Which customer type buys the most? --

SELECT
	Customer_type,
    SUM(Quantity) AS Total
FROM Sales
GROUP BY Customer_type
ORDER BY Total DESC;

SELECT
	customer_type,
    COUNT(*) AS Cnt
FROM sales
GROUP BY customer_type;

-- 5. What is the gender of most of the customers? --

SELECT
	gender,
    COUNT(*) AS Cnt
FROM sales
GROUP BY gender;

-- 6. What is the gender distribution per branch? --

SELECT
    gender,
    COUNT(gender) AS Gender_Cnt
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY Gender_Cnt DESC;

-- 7. Which time of the day do customers give most ratings? --

SELECT
	time_of_day,
	COUNT(Rating) AS Rating_Cnt
FROM sales
GROUP BY time_of_day
ORDER BY Rating_Cnt DESC;

-- 8. Which time of the day do customers give most ratings per branch? --

SELECT
	time_of_day,
	COUNT(Rating) AS Rating_Cnt
FROM sales
WHERE branch = 'A'
GROUP BY time_of_day
ORDER BY Rating_Cnt DESC;

-- 9. Which day of the week has the best avg ratings? --

SELECT
	day_name,
    AVG(Rating) AS Avg_Rating
FROM Sales
GROUP BY day_name
ORDER BY Avg_Rating DESC;

-- 10. Which day of the week has the best average ratings per branch?

SELECT
	day_name,
    AVG(Rating) AS Avg_Rating
FROM Sales
WHERE branch = 'B'
GROUP BY day_name
ORDER BY Avg_Rating DESC;

-- ----------------------------------------------------------------------------------
-- ---------------------------------- THANK YOU !! ----------------------------------


