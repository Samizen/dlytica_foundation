create or replace function training_ecom.fn_customer_lifetime_value(p_customer_id int)
	returns numeric(10,2) as $$
declare
	total_paid_amount numeric(10, 2);
begin
	select 
		coalesce(sum(p.amount), 0)
	into total_paid_amount
	from training_ecom.payments p
	inner join training_ecom.orders o
	on p.order_id = o.order_id
	where o.customer_id = p_customer_id
		and o.status in ('delivered', 'shipped', 'placed');
	
	return total_paid_amount;
end;
$$ language plpgsql;


select training_ecom.fn_customer_lifetime_value(1);
select training_ecom.fn_customer_lifetime_value(2);
select training_ecom.fn_customer_lifetime_value(3);
select training_ecom.fn_customer_lifetime_value(4);
select training_ecom.fn_customer_lifetime_value(5);
select training_ecom.fn_customer_lifetime_value(6);

/* **Table Function: `fn_recent_orders(p_days INT)`**
    - Return `order_id, customer_id, order_date, status, order_total` for orders in the last `p_days` days. */
create or replace function training_ecom.fn_recent_orders(p_days int)
returns table (
	order_id int,
	customer_id int,
	order_date timestamp,
    status varchar(20),
    order_total numeric(10, 2)
) as $$
begin
	return query
	select 
		o.order_id,
		o.customer_id,
		o.order_date,
		o.status,
		sum(oi.quantity * oi.unit_price) AS total_order
    from training_ecom.orders as o
    inner join training_ecom.order_items as oi
    on o.order_id = oi.order_id
    where o.order_date >= CURRENT_DATE - INTERVAL '1 day' * p_days
    group by o.order_id, o.customer_id, o.order_date, o.status
	order by o.order_date;
end;
$$ language plpgsql;


select * from training_ecom.fn_recent_orders(120);


/* **Utility Function: `fn_title_case_city(text)`**
    - Return city name with first letter of each word capitalized (hint: split/upper/lower or use `initcap()` in PostgreSQL). */
create or replace function training_ecom.fn_title_case_city(p_city text)
returns text as $$
	select initcap(p_city);
$$ language sql;

select training_ecom.fn_title_case_city(city)
from training_ecom.customers;

