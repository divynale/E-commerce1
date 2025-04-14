use olist_ecommerce_db;
show tables;

# KPI:1 Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics.

select * from order_review_db;
select kpi1.Day_End,round((kpi1.Total_Pmt/(Select sum(payment_value) from
order_payments_db))*100,2) as perc_pmtvalue
from
(select ord.Day_End,sum(pmt.payment_value) as Total_pmt
from  order_payments_db as pmt join
(select distinct(order_id), case when weekday(order_purchase_timestamp) in (5,6) then "Weekend"
else "Weekday" end as Day_End from orders_db) as ord on ord.order_id=pmt.order_id group by ord.Day_End)
as kpi1;

# KPI:2 Number of Orders with review score 5 and payment type as credit card.

select pmt.payment_type,count(pmt.order_id)
as Total_Orders from order_payments_db as pmt join
(select distinct ord.order_id,rw.review_score from  orders_db as ord
join order_review_db rw on ord.order_id=rw.order_id where review_score=5) as rw5
on pmt.order_id=rw5.order_id group by pmt.payment_type order by Total_Orders desc;

# KPI:3 Average number of days taken for order_delivered_customer_date for pet_shop.

select prod.product_category_name ,
round(avg(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0)
as  avg_delivery_date
from orders_db as ord join
(Select product_id,order_id,product_category_name from
product_table join order_items_db using (product_id)) as prod
on ord.order_id=prod.order_id  where prod.product_category_name="pet_shop"  group by prod.product_category_name;

#KPI:4 Average price and payment values from customers of sao paulo city .

# A.For Average price

select cust.customer_city,round(avg(pmt_price.price),0) as avg_price
from customers_db as cust
join (select pymnt.customer_id,pymnt.payment_value, item.price from order_items_db as item join
(Select ord.order_id,ord.customer_id,pmt.payment_value from orders_db as ord
join order_payments_db as pmt on ord.order_id=pmt.order_id) as pymnt
on item.order_id=pymnt.order_id) as pmt_price on cust.customer_id=pmt_price.customer_id where cust.customer_city="sao paulo";

# B.For Average Payment

select cust.customer_city,round(avg(pmt.payment_value),0)as avg_payment_value
from customers_db cust inner join orders_db ord
on cust.customer_id=ord.customer_id inner join
order_payments_db as pmt on ord.order_id=pmt.order_id
where customer_city="sao paulo";

# KIPI:5 Relationship between shipping days (order_delivered_customer_date — order_purchase_timestamp) Vs review scores.

select rw.review_score,
round(avg(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0)
as avg_Shipping_Days
from orders_db as ord join order_review_db rw on
rw.order_id=ord.order_id group by rw.review_score order by rw.review_score;
