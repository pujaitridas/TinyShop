create database tinyshop;
use tinyshop;

CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

select* from customers;

select* from orders;

select* from products;

select* from order_items;


#1.Which product has the highest price? Only return a single row.
select product_id,product_name,price
from products
order by price desc 
limit 1;

#2.Which customer has made the most orders?
with t as(
select customer_id,concat(first_name,' ' ,last_name) as FullName,count(*) as'No.of Orders',
dense_rank() over (order by count(*) desc) as `Rank`
from customers  join orders using(customer_id)
group by customer_id
)
select *
from t
where `Rank`=1;

#3.What’s the total revenue per product?
select product_id,product_name, sum(price*quantity) as Revenue
from products inner join order_items using(product_id)
group by product_id;

#4.Find the day with the highest revenue.
select sum(price*quantity) as Highest_Revenue, order_date 
from products inner join order_items using(product_id) inner join orders using(order_id)
group by order_id,order_date
order by Highest_Revenue desc 
limit 1;

#5.Find the first order (by date) for each customer.
select customer_id, concat(first_name,' ' ,last_name) as FullName, min(order_date) as `First order date`
from customers inner join orders using(customer_id)
group by customer_id;

#6.Find the top 3 customers who have ordered the most distinct products.
with t as(
select customer_id,concat(first_name," ", last_name) as fullname,count(distinct product_id) as 'No.of Distinct products',
dense_rank() over (order by count(distinct product_id) desc) as `Rank`
from products inner join order_items using(product_id) inner join orders using(order_id) inner join customers using(customer_id) 
group by customer_id
)
select *
from t 
where `Rank`=1;

#7.Which product has been bought the least in terms of quantity?
with t as(
select product_name, sum(quantity),
dense_rank() over (order by sum(quantity) ) as `rank`
from products inner join order_items using(product_id) inner join orders using(order_id)
group by product_id
)
select *
from t 
where `rank`=1;

#8.What is the median order total?

SET @rowindex := -1;
 with T as(
 select order_id,sum(price*quantity) as total
 from order_items inner join products using(product_id)
 group by order_id
 )
 
select
   round(avg(total),2) as Median 
from
   (
   select @rowindex:=@rowindex + 1 AS rowindex,total
   from t
    order by total 
    ) as d
where
d.rowindex in (floor(@rowindex / 2), ceil(@rowindex / 2));

/*9.For each order, determine if it was ‘Expensive’ (total over 300), 
‘Affordable’ (total over 100), or ‘Cheap’.*/
select order_id,sum(price*quantity) as Total,
case
when sum(price*quantity)>300 then "Expensive" 
when sum(price*quantity) >100 then "Affordable"
else "Cheap"
end as Status
from orders inner join order_items using(order_id) inner join  
products using(product_id)
group by order_id;

#10.Find customers who have ordered the product with the highest price.
with t as(
select customer_id,concat(first_name,' ' ,last_name) as FullName,price,
dense_rank() over (order by price desc) as `rank`
from customers inner join orders using(customer_id) inner join order_items using(order_id) inner join  products using(product_id) 
)
select *
from t
where `rank`=1;

/*Method 2*/
select customer_id,concat(first_name,' ' ,last_name) as FullName,price
from customers inner join orders using(customer_id) inner join order_items using(order_id) inner join  products using(product_id) 
where price=(
select max(price)
from products)
;

