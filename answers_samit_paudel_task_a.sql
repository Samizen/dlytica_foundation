/* 1. **Monthly Customer Rank by Spend**
   - For each month (based on `order_date`), rank customers by **total order value** in that month using `RANK()`.
   - Output: month (YYYY-MM), customer_id, total_monthly_spend, rank_in_month. */

select
	TO_CHAR(o.order_date, 'YYYY-MM') AS year_month,
	o.customer_id,	
	SUM(p.amount) total_monthly_spend,
	RANK() over (partition by TO_CHAR(o.order_date, 'YYYY-MM') order by SUM(p.amount) DESC) as monthly_rank
from training_ecom.orders o
inner join training_ecom.payments p 
on o.order_id = p.order_id 
group by o.customer_id, TO_CHAR(o.order_date, 'YYYY-MM')
order by TO_CHAR(o.order_date, 'YYYY-MM')


with monthly_sales as (
	select 
		TO_CHAR(o.order_date, 'YYYY-MM') AS year_month,
		o.customer_id,	
		SUM(p.amount) total_monthly_spend
	from training_ecom.orders o
	inner join training_ecom.payments p
	on o.order_id = p.order_id
	group by o.customer_id, TO_CHAR(o.order_date, 'YYYY-MM')

)

select 
	*, 
	rank() over (partition by year_month order by total_monthly_spend desc) as monthly_rank
from monthly_sales
order by year_month, monthly_rank 


/* **Share of Basket per Item**
   - For each order, compute each item's **revenue share** in that order:
     `item_revenue / order_total` using `SUM() OVER (PARTITION BY order_id)`. */

select 
	o.order_id,
	TO_CHAR(o.order_date, 'YYYY-MM') as year_month,
	oi.product_id,
	oi.quantity * oi.unit_price as item_revenue,
	sum(oi.quantity * oi.unit_price) over (partition by oi.order_id) as order_total,
	round((oi.quantity * oi.unit_price) / sum(oi.quantity * oi.unit_price) over (partition by oi.order_id) * 100, 2) as share_of_basket_percent
from training_ecom.orders o
inner join training_ecom.order_items oi 
on o.order_id = oi.order_id;


/* *Time Between Orders (per Customer)**
   - Show days since the **previous order** for each customer using `LAG(order_date)` and `AGE()`. */

select
	order_id,
	customer_id,
	order_date,
	lag(order_date) over (partition by customer_id order by order_date) as prev_order_date,
	age(order_date, lag(order_date) over (partition by customer_id order by order_date)) as days_difference
from training_ecom.orders;


select 
	*,
	order_date::date - t.prev_order_date::date as days_difference 
from (
	select
		*,
		lag(order_date) over (partition by customer_id order by order_date) as prev_order_date
	from training_ecom.orders
) t 


/* **Product Revenue Quartiles**
   - Compute total revenue per product and assign **quartiles** using `NTILE(4)` over total revenue. */
select 
	oi.product_id,
	sum(oi.quantity * oi.unit_price) as total_revenue,
	ntile(4) over (order by sum(oi.quantity * oi.unit_price) desc)
from training_ecom.order_items oi
group by oi.product_id


/* 5. **First and Last Purchase Category per Customer**
   - For each customer, show the **first** and **most recent** product category they've bought using `FIRST_VALUE` and `LAST_VALUE` over `order_date`. */
select distinct
--	o.order_id,
	o.customer_id,
--	oi.product_id,
--	p.product_name,
--	p.category,
	first_value(p.category) over (partition by customer_id order by o.order_date) as first_category,
	last_value(p.category) over (partition by customer_id order by o.order_date rows between unbounded preceding and unbounded following) as last_category
from training_ecom.orders o
inner join training_ecom.order_items oi
on o.order_id = oi.order_id
inner join training_ecom.products p
on oi.product_id = p.product_id
order by o.customer_id




with customer_categories as (
    select
        o.customer_id,
        p.category,
        o.order_date,
        first_value(p.category) over (partition by o.customer_id order by o.order_date) as first_category,
        last_value(p.category) over (partition by o.customer_id order by o.order_date rows between unbounded preceding and unbounded following) as last_category
    from
        training_ecom.orders o
    inner join training_ecom.order_items oi on o.order_id = oi.order_id
    inner join training_ecom.products p on oi.product_id = p.product_id
)
select distinct
    customer_id,
    first_category,
    last_category
from
    customer_categories
order by
    customer_id;


