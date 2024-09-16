-- Restaurant Order Analysis for Taste of the World Cafe. 
-- This restaurant debuted a new menu at the start of the year.
-- You've been asked to dig into the customer data and see what items are doing well/ not doing well & what the top customers seem to like best.
-- Objective #1 - Explore the menu_items table to get an idea of what's on the new menu
USE restaurant_db;
-- 1. View the menu_items table 
SELECT * FROM menu_items;

-- 2. Find the number of items on the menu

SELECT COUNT(item_name) 
FROM menu_items;

-- 3. What are the least and most expensive items on the menu?
SELECT * 
FROM menu_items
ORDER BY price desc;

SELECT * 
FROM menu_items
ORDER BY price asc;


-- 4. How many Italian dishes are on the menu?
SELECT COUNT(item_name) as ItalianDishCount
FROM menu_items
WHERE category='Italian';

-- 5. What are the least and most expensive Italian dishes on the menu?
SELECT item_name, category, price
FROM menu_items
WHERE category='Italian'
ORDER BY price asc;

-- 6. How many dishes are in each category?
SELECT category, COUNT(menu_item_id) as num_dishes
FROM menu_items
GROUP BY category;

-- 7. What is the average dish price within each category?
SELECT category, ROUND(avg(price),2) as avg_price
FROM menu_items
GROUP BY category;

-- Objective #2 - Explore the order_details table to get an idea of the data that's been collected.
-- 1. View the order_details table
SELECT * FROM	order_details;

-- 2. What is the date range of the table?
SELECT MIN(order_date) as min_order_date, MAX(order_date) as max_order_date FROM order_details;

-- 3. How many orders were made within this date range?
SELECT COUNT(distinct order_id) as Total_Orders FROM order_details;

-- 4. How many items were ordered within this date range?
SELECT COUNT(*) as Total_Items_Ordered FROM order_details;

-- 5. Which orders had the most number of items?
SELECT order_id, COUNT(item_id) as num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items desc;

-- 6. How many orders had more than 12 items?
SELECT COUNT(*) as num_orders_over_12_items FROM
(SELECT order_id, COUNT(item_id) AS num_items
FROM order_details
GROUP BY order_id
HAVING num_items > 12) AS num_orders;

-- Objective #3 - Use both tables to understand how customers are reacting to the new menu. 

-- 1. Combine the menu_items and order_details tables into a single table.
SELECT * FROM menu_items;
-- Fields include: menu_item_id, item_name, category, price
SELECT * FROM order_details;
-- Fields include: order_details_id, order_id, order_date, order_time, item_id 
-- join on menu_item_id and item_id
SELECT *
FROM order_details od LEFT JOIN menu_items mi 
	ON od.item_id = mi.menu_item_id;

-- 2. What were the least and most ordered items? What categories were they in?
-- Take the join statement from above and group it by the item name,order it by the # of purchases descending and limit to 5
SELECT item_name, category, COUNT(order_details_id) as num_purchases
FROM order_details od LEFT JOIN menu_items mi 
	ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY num_purchases DESC;

-- 3. What were the top 5 orders that spent the most money?
SELECT order_id, SUM(price) as  total_spend
FROM order_details od LEFT JOIN menu_items mi 
	ON od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY total_spend DESC
LIMIT 5;

-- 4. View the details of the highest spend order. What insights can you gather from the results?
SELECT *
FROM order_details od LEFT JOIN menu_items mi 
	ON od.item_id = mi.menu_item_id
WHERE order_id = 440;

-- Deeper look at what 'order 440' ordered by category
SELECT category, COUNT(item_id) AS num_items
FROM order_details od LEFT JOIN menu_items mi 
	ON od.item_id = mi.menu_item_id
WHERE order_id = 440
GROUP BY category
ORDER BY num_items DESC;

-- 5. View the details of thw top 5 highest spend order. What insights can you gather from the result?

-- This result aggregates all of the top 5 highest spend orders
SELECT category, COUNT(item_id) AS num_items
FROM order_details od LEFT JOIN menu_items mi 
	ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY category
ORDER BY num_items DESC;

-- This query shows for each of the top 5 highest-spend orders, how many items from each category were purchased
SELECT order_id, category, COUNT(item_id) AS num_items
FROM order_details od LEFT JOIN menu_items mi 
	ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY order_id, category;


