-- Basic:
-- Retrieve the total number of orders placed.
select count(order_id) from orders;


-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.
select name from pizza_types where pizza_type_id = (select pizza_type_id from pizzas ORDER BY price DESC LIMIT 1);

select pizza_types.name , pizzas.price from pizza_types left join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id order by pizzas.price desc limit 1;


-- Identify the most common pizza size ordered.
select pizzas.size , count(order_details.order_details_id) as total_order from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id group by pizzas.size order by total_order desc limit 1;


-- List the top 5 most ordered pizza types along with their quantities.
select sum(order_details.quantity) as total_order, pizza_types.name as pizza_name from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id left join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id group by pizza_name order by total_order desc limit 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category as pizza_category, sum(order_details.quantity) as total_order from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id left join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id group by pizza_category;

-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) from orders group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_orders),0) as avg_order from (select orders.order_date, sum(order_details.quantity) as total_orders from orders right join order_details on orders.order_id = order_details.order_id group by orders.order_date) as order_per_day;

-- Determine the top 3 most ordered pizza types based on revenue.
select (pizza_types.name) as pizza_name, round(sum(order_details.quantity*pizzas.price),2) as revenue from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id left join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id group by pizza_name order by revenue desc limit 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
select (pizza_types.category) as pizza_category, round((sum(order_details.quantity*pizzas.price)/(select sum(order_details.quantity * pizzas.price) from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id))*100,2) as percent_contribution from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id left join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id group by pizza_category;

-- Analyze the cumulative revenue generated over time.
select order_date, round(sum(revenue) over(order by order_date),2) as cum_revenue from (select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue from order_details left join orders on order_details.order_id = orders.order_id left join pizzas on order_details.pizza_id = pizzas.pizza_id group by orders.order_date) as daily_sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, round(revenue,2) from (select category, name, revenue, rank() over(partition by category order by revenue desc) as rk from (select pizza_types.category, pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue from order_details left join pizzas on order_details.pizza_id = pizzas.pizza_id left join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id group by pizza_types.category, pizza_types.name) as a) as b where rk <= 3;