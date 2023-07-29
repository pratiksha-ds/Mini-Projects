#Composite data of a business organisation, confined to ‘sales and delivery’ domain is given for the period of last decade.
# From the given data retrieve solutions for the given scenario.

#1.	Join all the tables and create a new table called combined_table.
#(market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

create table combined_table 
(select a.Customer_Name,  a.Province,cd.Region, Customer_Segment, a.Cust_id,
b.Ord_id, b.Prod_id, b.Ship_id, b.Sales, b.Discount, b.Order_Quantity, b.Profit, b.Shipping_Cost, b.Product_Base_Margin,
c.Order_ID, c.Order_Date, c.Order_Priority,
pd.Product_Category, pd.Product_Sub_Category, 
sd.Ship_Mode, sd.Ship_Date
from cust_dimen a
join
market_fact b
on  a.Cust_id = b.Cust_id
join
orders_dimen c
on b.ord_id = c.Ord_id
join
prod_dimen pd
on pd.prod_id =b.prod_id
join
shipping_dimen sd
on
sd.Order_ID = c.Order_ID
group by Customer_Name);

#2.	Find the top 3 customers who have the maximum number of orders


select customer_name , sum(order_quantity) from combined_table group by cust_id order by order_quantity desc limit 3;


select customer_name , count(ord_id)  from market_fact a join cust_dimen using(cust_id) 
group by customer_name order by count(ord_id) desc limit 3;



#3.	Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.


alter table combined_table add column DaysTakenForDelivery int ;
update combined_table set Daystakenfordelivery = str_to_date(ship_date, '%d-%m-%YYYY') - str_to_date(order_date, '%d-%m-%YYYY'); 

#4.	Find the customer whose order took the maximum time to get delivered.

select customer_name , daystakenfordelivery from combined_table where DaysTakenForDelivery = (select max(DaysTakenForDelivery) 
from combined_table);

#5.	Retrieve total sales made by each product from the data (use Windows function)

select prod_id , sum(sales) over(order by prod_id) total_sales from market_fact group by prod_id;

#6.	Retrieve total profit made from each product from the data (use windows function)

select prod_id , avg(profit) over(order by profit desc) profit_prod from market_fact group by prod_id;

#7.	Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select count( distinct customer_name) from combined_table where month(str_to_date(order_date, "%d-%m-%YYYY")) = 1;

select count( distinct customer_name) from combined_table 
where year(str_to_date(order_date, "%d-%m-%YYYY")) = 2011 and month(str_to_date(order_date, "%d-%m-%YYYY")) != 1  
and customer_name in (select distinct customer_name from combined_table where month(str_to_date(order_date, "%d-%m-%YYYY")) = 1);

#8.	Retrieve month-by-month customer retention rate since the start of the business.(using views)

select cust_id , date_format(str_to_date(order_date, '%d-%m-%YYYY'), '%d-%m-%Y') visit_date , 
str_to_date(order_date, '%d-%m-%YYYY') - lag(str_to_date(order_date, '%d-%m-%YYYY')) 
over(partition by cust_id) as diff_btwn_visits  
from orders_dimen a join market_fact b using(ord_id) order by cust_id,visit_date;

#Tips: 
#1: Create a view where each user’s visits are logged by month, allowing for the possibility that these will have occurred over multiple # years since whenever business started operations
# 2: Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.
# 3: Calculate the time gaps between visits
# 4: categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned
# 5: calculate the retention month wise


