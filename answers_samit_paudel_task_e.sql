/* 1. **Average Order Value by City (Delivered Only)**
    - Output: city, avg_order_value, delivered_orders_count. Order by `avg_order_value` desc. Use `HAVING` to keep cities with at least 2 delivered orders. */

select
    c.city,
    avg(oi.quantity * oi.unit_price) as avg_order_value,
    count(distinct o.order_id) as delivered_orders_count
from training_ecom.orders o
join training_ecom.customers c
    on o.customer_id = c.customer_id
join training_ecom.order_items oi
    on o.order_id = oi.order_id
where o.status = 'delivered'
group by c.city
having count(distinct o.order_id) >= 2
order by avg_order_value desc;

/* 2. **Category Mix per Customer**
    - For each customer, list categories purchased and the **count of distinct orders** per category. Order by customer and count desc. */

select
    c.full_name,
    p.category,
    count(distinct o.order_id) as distinct_orders_count
from training_ecom.customers c
inner join training_ecom.orders o
on c.customer_id = o.customer_id
inner join training_ecom.order_items oi
on o.order_id = oi.order_id
inner join training_ecom.products p
on oi.product_id = p.product_id
group by c.customer_id, c.full_name, p.category
order by c.full_name, distinct_orders_count desc;


/*  **Set Ops: Overlapping Customers**
    - Split customers into two sets: those who bought `Electronics` and those who bought `Fitness`. Show:
      - `UNION` of both sets,
      - `INTERSECT` (bought both),
      - `EXCEPT` (bought Electronics but not Fitness). */

-- customers who bought electronics
-- Customers who bought either 'Electronics' or 'Fitness' (or both)
select distinct c.full_name
from training_ecom.customers c
join training_ecom.orders o
    on c.customer_id = o.customer_id
join training_ecom.order_items oi
    on o.order_id = oi.order_id
join training_ecom.products p
    on oi.product_id = p.product_id
where p.category = 'Electronics'

union

select distinct c.full_name
from training_ecom.customers c
join training_ecom.orders o
    on c.customer_id = o.customer_id
join training_ecom.order_items oi
    on o.order_id = oi.order_id
join training_ecom.products p
    on oi.product_id = p.product_id
where p.category = 'Fitness';


-- Customers who bought both 'Electronics' AND 'Fitness'
select distinct c.full_name
from training_ecom.customers c
join training_ecom.orders o
    on c.customer_id = o.customer_id
join training_ecom.order_items oi
    on o.order_id = oi.order_id
join training_ecom.products p
    on oi.product_id = p.product_id
where p.category = 'Electronics'

intersect

select distinct c.full_name
from training_ecom.customers c
join training_ecom.orders o
    on c.customer_id = o.customer_id
join training_ecom.order_items oi
    on o.order_id = oi.order_id
join training_ecom.products p
    on oi.product_id = p.product_id
where p.category = 'Fitness';


-- Customers who bought 'Electronics' but NOT 'Fitness'
select distinct c.full_name
from training_ecom.customers c
join training_ecom.orders o
    on c.customer_id = o.customer_id
join training_ecom.order_items oi
    on o.order_id = oi.order_id
join training_ecom.products p
    on oi.product_id = p.product_id
where p.category = 'Electronics'

except

select distinct c.full_name
from training_ecom.customers c
join training_ecom.orders o
    on c.customer_id = o.customer_id
join training_ecom.order_items oi
    on o.order_id = oi.order_id
join training_ecom.products p
    on oi.product_id = p.product_id
where p.category = 'Fitness';