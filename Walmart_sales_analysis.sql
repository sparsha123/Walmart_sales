use salesdatawalmart;

-- Create table
CREATE TABLE IF NOT EXISTS walmart(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- Data cleaning
SELECT
	*
FROM walmart;
-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM walmart;

select * from walmart;
UPDATE walmart
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);
select * from walmart;
-- Add day_name column
SELECT
	date,
	DAYNAME(date)
FROM walmart;
ALTER TABLE walmart ADD COLUMN day_name VARCHAR(10);

UPDATE walmart
SET day_name = DAYNAME(date);
select * from walmart;
-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM walmart;

ALTER TABLE walmart ADD COLUMN month_name VARCHAR(10);

UPDATE walmart
SET month_name = MONTHNAME(date);
select * from walmart;
-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM walmart;
-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------
-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM walmart;
-- How many unique product lines does the data have?
SELECT 
	 count(DISTINCT product_line)
FROM walmart;
-- What is the most common payment method?
-- walmart['Payment'].value_counts().idxmax()
SELECT
	sum(invoice_id) as p,
    payment
FROM walmart
GROUP BY payment
ORDER BY p DESC
LIMIT 1;

-- What is the most selling product line?
-- walmart.groupby('Product line')['Quantity'].sum().idxmax()
SELECT
	sum(quantity) as q,
    product_line
FROM walmart
GROUP BY product_line
ORDER BY q DESC
LIMIT 1;

-- What is the total revenue by month?
-- walmart.groupby('month_name').Total.sum()
SELECT
	month_name,
    sum(total) as revenue
FROM walmart
GROUP BY month_name;

-- What month had the largest COGS?
-- walmart.groupby('month_name').cogs.sum().idxmax()
SELECT
	sum(cogs) as c,
    month_name
FROM walmart
GROUP BY month_name
ORDER BY c DESC
LIMIT 1;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
-- avg_sales= walmart.Total.mean().round()
-- prod_line_sales=walmart.groupby('Product line').Total.mean().round()
-- prod_line_sales.apply(lambda x: 'Good' if x> avg_sales else 'Bad')
SELECT
	product_line,
    (CASE
		WHEN avg(total) > (SELECT avg(total) as avg_sales FROM walmart) THEN "Good"
        ELSE "Bad"
    END) AS sales_staus
    FROM walmart
GROUP BY product_line
ORDER BY round(avg(total),2) DESC;
		
-- Which branch sold more products than average product sold?
SELECT
	branch, sum(quantity) AS no_of_prod
FROM walmart
GROUP BY branch
HAVING no_of_prod> (SELECT round(avg(quantity),2) FROM walmart);

-- What is the most common product line by gender?
-- walmart.groupby(['Product line','Gender'])['Gender'].count().sort_values(ascending=False)
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM walmart
GROUP BY gender, product_line
ORDER BY total_cnt DESC;
-- What is the average rating of each product line?
-- walmart.groupby('Product line').Rating.mean()
SELECT 
	product_line,
	round(avg(rating),2) as Avg_rating
FROM walmart
GROUP BY product_line;

-- -----------------------------------------------------------------------------------
-- -------------------------------------- Sales --------------------------------------
-- -----------------------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday
-- df=walmart.groupby(['time_of_day','day_name']).Total.count().reset_index()
-- df[df['day_name']=='Sunday'].groupby('time_of_day').Total.sum().sort_values(ascending=False)
SELECT
	time_of_day, count(total) AS tot_sales
FROM walmart
WHERE day_name='Sunday'
GROUP BY time_of_day
ORDER BY tot_sales DESC;

-- Which of the customer types brings the most revenue?
-- walmart.groupby('Customer type').Total.sum().idxmax()

SELECT
	customer_type
FROM walmart
GROUP BY customer_type
ORDER BY sum(total) DESC
LIMIT 1;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
-- walmart.groupby('City')['Tax 5%'].sum().idxmax()
SELECT 
	city, sum(tax_pct) as tot_tax
FROM walmart
GROUP BY city
ORDER BY tot_tax DESC
LIMIT 1;

-- Which customer type pays the most in VAT?
-- walmart.groupby('Customer type')['Tax 5%'].sum().idxmax()
SELECT 
	customer_type, sum(tax_pct) as tot_tax
FROM walmart
GROUP BY customer_type
ORDER BY tot_tax DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------
-- -------------------------------------- Customer --------------------------------------
-- -----------------------------------------------------------------------------------
-- How many unique customer types does the data have?
-- np.array(walmart['Customer type'].unique()).size
SELECT 
	COUNT(DISTINCT customer_type) as unique_cust_type
FROM walmart;

-- What is the most common customer type?
-- walmart['Customer type'].value_counts().idxmax()
SELECT
	customer_type, count(*) AS cust_type_count
FROM walmart
GROUP BY customer_type
ORDER BY count(*) DESC
LIMIT 1;

-- Which customer type buys the most?
-- walmart.groupby('Customer type').Total.sum().idxmax()
SELECT
	customer_type
FROM walmart
GROUP BY customer_type
ORDER BY sum(total) DESC
LIMIT 1;

-- What is the gender of most of the customers?
-- walmart['Gender'].value_counts().idxmax()
SELECT 
	gender , COUNT(*) as cust_cnt
FROM walmart
GROUP BY gender
ORDER BY cust_cnt DESC
LIMIT 1;

-- What is the gender distribution per branch?
-- walmart.groupby(['Gender','Branch']).Branch.count()
SELECT 
	gender, count(*)
FROM walmart
WHERE branch='A'
GROUP BY gender;


-- Which time of the day do customers give most ratings?
-- walmart.groupby('time_of_day').Rating.sum().idxmax()
SELECT 
	time_of_day , avg(rating)
FROM walmart
GROUP BY time_of_day
ORDER BY avg(rating) DESC;


-- Which time of the day do customers give most ratings per branch?
-- walmart.groupby(['time_of_day','Branch']).Rating.sum()
SELECT 
	time_of_day, avg(rating)
FROM walmart
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg(rating) DESC;

-- Which day fo the week has the best avg ratings?
-- walmart.groupby('day_name').Rating.mean().round(2).idxmax()
SELECT 
	day_name, avg(rating)
FROM walmart
GROUP BY day_name
ORDER BY avg(rating) DESC
LIMIT 1;

-- Which day of the week has the best average ratings per branch?
-- walmart.groupby(['day_name','Branch']).Rating.mean().round(2).idxmax()
SELECT 
	branch, day_name, avg(rating)
FROM walmart
GROUP BY day_name, branch
ORDER BY avg(rating) DESC;

