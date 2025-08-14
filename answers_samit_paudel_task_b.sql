--create view ve_recent_orders_30d

create view training_ecom.ve_recent_orders_30d as
select 
	o.order_id,
	o.customer_id,
	o.order_date ,
	o.status ,
	SUM(oi.quantity * oi.unit_price) AS order_total
from training_ecom.orders o
inner join training_ecom.order_items oi
on o.order_id = oi.order_id 
where o.status != 'cancelled' 
	and o.order_date >= CURRENT_DATE - INTERVAL '30 days'
group by o.order_id, 
	o.customer_id,
	o.order_date ,
	o.status;


/* **Products Never Ordered**
   - Using a subquery, list products that **never** appear in `order_items`. */

select 
	product_id 
from training_ecom.products p
where p.product_id not in (
	select distinct
		product_id
	from training_ecom.order_items
	) ;


/* **Top Category by City**
   - For each `city`, find the **single category** with the highest total revenue. Use an inner subquery or a view plus a filter on rank. */
select
    u.city,
    u.category,
    u.total_revenue
from (
    select
        t.city,
        t.category,
        t.total_revenue,
        rank() over (partition by city order by total_revenue desc) as rn
    from (
        select
            c.city,
            p.category,
            sum(oi.quantity * oi.unit_price) as total_revenue
        from training_ecom.orders o 
        inner join training_ecom.customers c on c.customer_id = o.customer_id 
        inner join training_ecom.order_items oi on oi.order_id = o.order_id 
        inner join training_ecom.products p on p.product_id = oi.product_id 
        group by c.city, p.category
    ) t
) u
where u.rn = 1;


/* **Customers Without Delivered Orders**
   - Using `NOT EXISTS`, list customers who have **no orders** with status `delivered`.*/

select 
	c.customer_id,
	c.full_name 
from training_ecom.customers c 
where not exists (
	select c.customer_id 
	from training_ecom.orders o 
	where o.customer_id = c.customer_id 
		and o.status = 'delivered'
)







