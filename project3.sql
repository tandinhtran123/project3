--1
select productline,
extract (year from orderdate) as year_id,dealsize,
sum(sales) as revenue
from sales_dataset_rfm_prj
group by productline,extract (year from orderdate),dealsize
order by productline
--2
select 
extract(month from orderdate) as month_id,
sum(sales) as revenue,
count(ordernumber) as order_number
from sales_dataset_rfm_prj
group by extract(month from orderdate)
order by revenue desc
limit 1
--3
select
extract(month from orderdate) as month_id,
productline,
count(quantityordered) as order_number
from sales_dataset_rfm_prj
where extract(month from orderdate)=11
group by extract(month from orderdate),productline
order by order_number desc
limit 1
--4
with cte as (select
extract(year from orderdate) as year_id,
productline,
sum(sales)over(partition by productline order by extract(year from orderdate)) as revenue
from sales_dataset_rfm_prj
where country in ('UK')),
ct2 as (
select *,
row_number()over(partition by year_id order by revenue desc) as rank
from cte)
select year_id,productline,revenue
from ct2 where rank=
--
with customer_rfm as
(select contactfullname,
current_date-MAX(orderdate) as R,
count(ordernumber) as F,
sum(sales) as M
from sales_dataset_rfm_prj
group by contactfullname),

rfm_score as
(select contactfullname,
ntile(5)over(order by R DESC) as R_score,
ntile(5)over(order by F) as F_score,
ntile(5)over(order by M) as M_score
from customer_rfm),

rfm_final as
(select contactfullname,
cast(r_score as varchar)||cast(f_score as varchar)||cast(m_score as varchar) as rfm_score
from rfm_score)

select a.contactfullname
from rfm_final a join segment_score b
on a.rfm_score=b.scores
where b.segment in ('Champions')
