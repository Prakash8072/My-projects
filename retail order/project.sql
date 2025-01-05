select * from prakash.df_orders

-- 1.find the top 10 highest revenue generating products

select product_id, sum(sell_price)
from prakash.df_orders
group by product_id
order by sum(sell_price) desc
limit 10

-- 2.find top 5 highest selling products in each region
with cte as (select region , product_id, sum(sell_price),
row_number() OVER(Partition by region order by sum(sell_price) desc) as rn
from prakash.df_orders
group by region,product_id
order by region,sum(sell_price) desc )

select * from cte
where rn<=5

-- find the month over month growth comaparision for 202 and 2023 for eg 2022 jan vs 2023 jan

with cte as 
(select year(order_date) as year, month(order_date) as month, sum(sell_price) as sales
from prakash.df_orders
group by year(order_date), month(order_date)
order by year, month)

select month, 
sum(case when year=2022 then sales else 0 end) as 2022_sales,
sum(case when year=2023 then sales else 0 end) as 2023_sales
from cte
group by month

-- for each category which month had highest sales-- 
with cte as (select month(order_date) as month,category, sum(sell_price) as total
from prakash.df_orders
group by month, category
order by month, category)

select * from (select *, row_number() over(partition by category order by total desc) as rn
from cte ) as new
-- where total=(select max(total) from cte)-- 
where new.rn=1


-- which sub category has highest growth by profit in 2023 comapare to 2022
with cte as (select sub_category, year(order_date) as year, sum(sell_price) as sales
from prakash.df_orders
group by sub_category, year(order_date) 
order by sub_category, year(order_date) ),
cte2 as (select sub_category,
sum(case when year=2022 then sales else 0 end) as 2022_sales,
sum(case when year=2023 then sales else 0 end) as 2023_sales
from cte
group by sub_category)

select * , (2023_sales-2022_sales)
from cte2
order by 2023_sales-2022_sales desc