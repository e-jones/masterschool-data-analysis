# 102.3 Number 18 - Subquery Mania

You are given this subquery which is pretty hard to read and the code looks a little duplicative

## Original query

Question: Find the top sales reps by each region:

```sql
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;
```

Reasons why I'm not a fan of this query the way it's written
- Multiple nested subqueries FROM(FROM(FROM)) makes it really hard to read
- The alias names are not useful (t1,t2,t3)
- There are repeated joins that appear to do similar things (this wastes compute resources)


## Using WITH clauses

Let's refactor the above to use `WITH` clause so it's easier to read by taking the subqueries and moving them to the top of the code. Notice how simiar `t1` and `t3` are!

```sql
WITH t1 AS (
     -- Get the sales reps names with the most orders by region
     SELECT 
          s.name AS rep_name, 
          r.name AS region_name, 
          SUM(o.total_amt_usd) AS total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY rep_name, region_name
)

, t2 AS (
     -- aggregate the orders by region name ('West' etc)
     SELECT 
          region_name, 
          MAX(total_amt) AS total_amt
     FROM t1
     GROUP BY region_name
)

, t3 AS (
     -- Rank the sales reps by most orders highest to lowest
     SELECT 
          s.name AS rep_name, 
          r.name AS region_name, 
          SUM(o.total_amt_usd) AS total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY rep_name, region_name
     ORDER BY total_amt DESC
)

-- Show the highest earning reps for each region
SELECT 
     t3.rep_name, 
     t3.region_name, 
     t3.total_amt
FROM t2 
JOIN t3 -- This is an INNER JOIN so it will only show regions in t2
ON 
     t3.region_name = t2.region_name 
     AND t3.total_amt = t2.total_amt;
```

## Updating the code to be more readable and using fewer joins

Now for the fun part. It looks like `t1` and `t3` are doing very similar things and we can possibly cut down on repetitive code and save some query engine time. Let's remove `t3` entirely

```sql
WITH t1 AS (
     -- Get the sales reps names with the most orders by region
     SELECT 
          s.name AS rep_name, 
          r.name AS region_name, 
          SUM(o.total_amt_usd) AS total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY rep_name, region_name
)

, t2 AS (
     -- aggregate the orders by region name ('West' etc)
     SELECT 
          region_name, 
          MAX(total_amt) AS total_amt
     FROM t1
     GROUP BY region_name
)

-- Show the highest earning reps for each region
SELECT 
     t1.rep_name, 
     t1.region_name, 
     t1.total_amt
FROM t2 
JOIN t1 -- This is an INNER JOIN so it will only show regions in t2
ON 
     t1.region_name = t2.region_name 
     AND t1.total_amt = t2.total_amt
ORDER BY total_amt DESC
```

## A Better solution is to use window functions

- A [quick primer on WINDOW functions](https://www.youtube.com/watch?v=xFeOVIIRyvQ) in SQL

```sql
-- aggregate all individual reps' sales for their regions
SELECT 
     s.name AS rep_name, 
     r.name AS region_name, 
     SUBSTRING(s.name,0,2) AS first_letter,
     SUM(o.total_amt_usd) AS total_amt,
     -- rank the sales reps by their total orders
     RANK() OVER(ORDER BY SUM(o.total_amt_usd) DESC) AS sales_rank_overall,
     -- rank the sales reps WITHIN EACH REGION by their total orders
     -- we do this using https://www.youtube.com/watch?v=xFeOVIIRyvQ
     RANK() OVER(PARTITION BY r.name ORDER BY SUM(o.total_amt_usd) DESC) AS sales_rank_by_region,
     RANK() OVER(PARTITION BY SUBSTRING(s.name,0,2) ORDER BY SUM(o.total_amt_usd) DESC) AS sales_rank_by_first_letter,
     
     RANK() OVER(
               -- these are my buckets
               PARTITION BY 
                    r.name, -- first bucket all reps into their regions 
                    SUBSTRING(s.name,0,2) -- next within those region buckets do the first letter
               -- this is how I want each bucket ordered
               ORDER BY SUM(o.total_amt_usd) DESC
          ) 
     AS sales_rank_by_region_then_first_letter

FROM sales_reps AS s
JOIN accounts AS a
     ON a.sales_rep_id = s.id
JOIN orders o 
     ON o.account_id = a.id
JOIN region r
     ON r.id = s.region_id
-- WHERE SUBSTRING(s.name,0,2) = 'E'
GROUP BY 
     rep_name, 
     region_name
ORDER BY 
     rep_name, 
     total_amt DESC
```






