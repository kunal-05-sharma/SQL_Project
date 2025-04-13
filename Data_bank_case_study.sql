use data_bank; 
select * from customer_nodes limit 5;
# 1. How many different nodes make up the Data Bank network?
select count(distinct node_id) from customer_nodes;

#2. How many nodes are there in each region?

select region_id,count(node_id) as count_nodes from customer_nodes  inner join regions 
using (region_id) group by region_id; 

# 3. How many customers are divided among the regions? 

select region_id,count(distinct customer_id) as Customers from customer_nodes inner join regions 
using (region_id) group by region_id;

# 4. Determine the total amount of transactions for each region name

select region_name, sum(txn_amount) from customer_transactions,regions,customer_nodes 
where regions.region_id = customer_nodes.region_id and customer_transactions.customer_id = customer_nodes.customer_id
group by region_name;

# 5. How long does it take on an average to move clients to a new node?

select round(avg(datediff(end_date,start_date)),2) as average_time from customer_nodes 
where end_date != '9999-12-31';

# 6. What is the unique count and total amount for each transaction type?
select txn_type ,count(*) as Unique_count, sum(txn_amount) as total_amount from customer_transactions
group by txn_type;

# 7. What is the average number and size of past deposits across all customers?
select round(count(customer_id)/(select count(distinct customer_id) from customer_transactions)) as average_deposit 
from customer_transactions where txn_type = 'deposit';

# 8. For each month - how many Data Bank customers make more than 1 deposit
#     and at least either 1 purchase or 1 withdrawal in a single month?

with tran_per_month_cte as
( select customer_id , month(txn_date) as txn_month ,
sum(if(txn_type = 'deposit',1,0)) as deposit_count,
sum(if(txn_type = 'withdrawal',1,0)) as withdrawal_count,
sum(if(txn_type = 'Purchase',1,0)) as purchase_count 
from customer_transactions
group by customer_id,month(txn_date))

select txn_month ,count(distinct customer_id) as customer_count
from tran_per_month_cte
where deposit_count>1 and
(purchase_count=1 or withdrawal_count=1)
group by txn_month;
