/* 1. **`sp_apply_category_discount(p_category TEXT, p_percent NUMERIC)`**
    - Reduce `unit_price` of **active** products in a category by `p_percent` (e.g., 10 = 10%). Prevent negative or zero prices using a `CHECK` at update time. */



alter table training_ecom.products 
add constraint check_positive_price check (unit_price > 0);

create or replace procedure training_ecom.apply_category_discount(p_category text, p_percent numeric)
language plpgsql
as $$
begin
	update training_ecom.products
	set unit_price = unit_price * (1 - p_percent / 100.0)
	where category = p_category and active = true;
end;
$$;

call training_ecom.apply_category_discount('Home', 1);


select * from training_ecom.products;


/* 2. **`sp_cancel_order(p_order_id INT)`**
    - Set order `status` to `cancelled` **only if** it is not already `delivered`.
    - (Optional) Delete unpaid `payments` if any exist for that order (there shouldn’t be, but handle defensively). */

select * from training_ecom.orders;

create or replace procedure training_ecom.sp_cancel_order(p_order_id int)
language plpgsql
as $$
begin
	update training_ecom.orders
	set status = 'cancelled'
	where order_id = p_order_id
		and status != 'delivered';
	
	-- Delete payments
	delete from training_ecom.payments
	where order_id = p_order_id;
end;
$$;


CALL training_ecom.sp_cancel_order(5);
CALL training_ecom.sp_cancel_order(8);

select * from training_ecom.orders;
select * from training_ecom.payments; -- payments for 5 and 8 are deleted.



/* **`sp_reprice_stale_products(p_days INT, p_increase NUMERIC)`**
    - For products **not ordered** in the last `p_days`, increase `unit_price` by `p_increase` percent. */

create or replace procedure training_ecom.sp_reprice_stale_products(p_days int, p_increase numeric)
language plpgsql
as $$
begin
    update training_ecom.products
    set unit_price = unit_price * (1 + p_increase / 100)
    where product_id not in (
        select distinct product_id
        from training_ecom.order_items oi
        join training_ecom.orders o
        on oi.order_id = o.order_id
        where o.order_date >= current_date - interval '1 day' * p_days
    );
end;
$$;

call training_ecom.sp_reprice_stale_products(90, 10);


