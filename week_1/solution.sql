select * from sales s ;

select * from menu m ;

select * from members m2 ;


--1
select customer_id, sum(price) as total_amt_spent from sales s 
join menu m 
on s.product_id = m.product_id
group by customer_id ;


--2
select customer_id, count(distinct order_date) as no_of_visits
from sales
group by 1;


--3
with cte as
(select customer_id, product_name , order_date,
rank() over(partition by customer_id order by order_date) r
from sales s 
join menu m 
on s.product_id = m.product_id)


select distinct customer_id, product_name as first_item_purchased
from cte
where r = 1
order by 1;



--4
select product_name, count(s.product_id) cnt from sales s 
join menu m 
on s.product_id = m.product_id
group by 1
limit 1;


--4b
with cte as
(select product_id, count(product_id) cnt
from sales s 
group by 1
limit 1)

select count(customer_id), customer_id from sales s 
where product_id = (select product_id from cte)
group by 2;



--5
with cte as
(select customer_id,product_name,count(s.product_id) as cnt
from sales s 
join menu m 
on s.product_id = m.product_id
group by 1,2
order by 1,3),

ctb as
(select customer_id,product_name,cnt,
rank() over(partition by customer_id order by cnt desc) rnk
from cte)

select customer_id,product_name from ctb
where rnk=1;




--5b
with cte as
(select customer_id, product_name,
rank() over(partition by customer_id order by count(s.product_id) desc) rnk
from sales s 
join menu m 
on s.product_id = m.product_id
group by customer_id,product_name)

select customer_id, product_name
from cte
where rnk =1;



--6
with cte as
(select s.customer_id, order_date, join_date, product_name,
rank() over(partition by s.customer_id order by order_date) as rnk
from sales s 
join menu mn 
on s.product_id = mn.product_id
join members m 
on s.customer_id = m.customer_id 
where order_date > join_date
order by 1,2)

select customer_id, product_name
from cte
where rnk = 1



--7
with cte as
(select s.customer_id, order_date, join_date, product_name,
rank() over(partition by s.customer_id order by order_date desc) as rnk
from sales s 
join menu mn 
on s.product_id = mn.product_id
join members m 
on s.customer_id = m.customer_id 
where order_date < join_date
order by 1,2)

select customer_id, product_name
from cte
where rnk = 1


--8
with cte as
(select s.customer_id, order_date, join_date, product_name, price,
rank() over(partition by s.customer_id order by order_date desc) as rnk
from sales s 
join menu mn 
on s.product_id = mn.product_id
join members m 
on s.customer_id = m.customer_id 
where order_date < join_date
order by 1,2)

select customer_id, sum(price) amt_spent, count(product_name) item_bought
from cte
group by customer_id


--9
select customer_id, sum(points) from
(select customer_id , case when product_name = 'sushi' then price*20 else price*10 end as points
from sales s 
join menu mn 
on s.product_id = mn.product_id) a
group by customer_id 
order by 1


--10
---In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
---not just sushi - how many points do customer A and B have at the end of January?

select customer_id, sum(pr) from
(select s.customer_id, order_date, join_date,
case when order_date between join_date and (join_date + INTERVAL '6 day') then price else 0 end as pr
from sales s 
join menu mn 
on s.product_id = mn.product_id
join members m 
on s.customer_id = m.customer_id 
where order_date >= join_date
order by 1,2) a
group by 1



select s.customer_id, order_date, join_date,
case when order_date between join_date and (join_date + INTERVAL '6 day') then price else 0 end
from sales s 
join members m 
on s.customer_id = m.customer_id 
where order_date >= join_date


--11
select s.customer_id, order_date, product_name,price,
case when order_date < join_date then 'N' 
	 when order_date >= join_date then 'Y'
	 else 'N' end as member
from sales s 
left join menu mn 
on s.product_id = mn.product_id
left join members m 
on s.customer_id = m.customer_id
order by 1,2


--12
with cte as
(select s.customer_id, order_date, product_name,price,
case when order_date < join_date then 'N' 
	 when order_date >= join_date then 'Y'
	 else 'N' end as member
from sales s 
left join menu mn 
on s.product_id = mn.product_id
left join members m 
on s.customer_id = m.customer_id
order by 1,2)

select *,
case when member = 'Y' then (rank() over(partition by member,customer_id order by order_date))
	 else null
	 end as ranking
from cte
order by 1,2