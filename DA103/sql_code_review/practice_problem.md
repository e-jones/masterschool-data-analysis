# Practice Code Review
Imagine you just joined a team as a data analyst looking at sales data. Your team member has provided you the code they are working on and wants you to review it. What feedback do you have for them?

## Find the sales reps which the highest sales in each region

```sql
select t3.rep_name, t3.region_name, t3.total_amt
from(select region_name, MAX(total_amt) total_amt
from(select s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps AS s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1, 2) t1
GROUP BY 1 ORDER BY total_amt DESC) t2
JOIN (select s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
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


## SQL Code Review Best Practices
- Is the code [formatted properly](https://codebeautify.org/sqlformatter)?
- Is the logic easy to follow? (avoid nested subqueries)
- Are there redundant parts of the code?

### Step 1: Format the code
You can use an online formatter if you don't have a text editor that will do this for you. Try [https://codebeautify.org/sqlformatter](https://codebeautify.org/sqlformatter) as one example.

Result:
```sql
SELECT 
  t3.rep_name, 
  t3.region_name, 
  t3.total_amt 
FROM 
  (
    -- For each region, what's the highest amount of sales
    SELECT 
      region_name, 
      MAX(total_amt) AS total_amt 
    FROM 
      (
        -- Total sales by rep and region
        SELECT 
          s.name AS rep_name, 
          r.name AS region_name, 
          SUM(o.total_amt_usd) total_amt 
        FROM 
          sales_reps AS s 
          JOIN accounts AS a ON a.sales_rep_id = s.id 
          JOIN orders AS o ON o.account_id = a.id 
          JOIN region AS r ON r.id = s.region_id 
        GROUP BY 
          rep_name, 
          region_name
      ) AS t1 
    GROUP BY 
      1 
    ORDER BY 
      total_amt DESC
  ) AS t2 
  JOIN (
    select 
      s.name rep_name, 
      r.name region_name, 
      SUM(o.total_amt_usd) total_amt 
    FROM 
      sales_reps s 
      JOIN accounts a ON a.sales_rep_id = s.id 
      JOIN orders o ON o.account_id = a.id 
      JOIN region r ON r.id = s.region_id 
    GROUP BY 
      1, 
      2 
    ORDER BY 
      3 DESC
  ) t3 ON t3.region_name = t2.region_name 
  AND t3.total_amt = t2.total_amt;
```

### Step 2: Is the logic easy to follow?
Multiple nested subqueries make the code difficult to read. Let's break them into WITH clauses and see if that makes things easier to follow

```sql

-- 
WITH t1 AS (
   -- Total sales by rep and region
   SELECT 
     s.name AS rep_name, 
     r.name AS region_name, 
     SUM(o.total_amt_usd) total_amt 
   FROM 
     sales_reps AS s 
     JOIN accounts AS a ON a.sales_rep_id = s.id 
     JOIN orders AS o ON o.account_id = a.id 
     JOIN region AS r ON r.id = s.region_id 
   GROUP BY 
     rep_name, 
     region_name
)

, t2 AS (
     -- For each region, what's the highest amount of sales
     SELECT 
      region_name, 
      MAX(total_amt) AS total_amt 
     FROM t1

     GROUP BY 
      1 
     ORDER BY 
      total_amt DESC
)

, t3 AS (
    SELECT 
      s.name AS rep_name, 
      r.name AS region_name, 
      SUM(o.total_amt_usd) AS total_amt 
    FROM 
      sales_reps AS s 
      JOIN accounts AS a ON a.sales_rep_id = s.id 
      JOIN orders AS o ON o.account_id = a.id 
      JOIN region AS r ON r.id = s.region_id 
    GROUP BY 
      1, 
      2 
    ORDER BY 
      3 DESC
)

SELECT 
  t1.rep_name, 
  t1.region_name, 
  t1.total_amt 
FROM t2 
  JOIN t1 ON t1.region_name = t2.region_name 
  AND t1.total_amt = t2.total_amt;
```

### Step 3: Are there parts of the code that we don't need?
One principle in writing code is D.R.Y. or "Dont Repeat Yourself". Is there a better way to write this code?

```sql
-- 
WITH t1 AS (
   -- Total sales by rep and region
   SELECT 
     s.name AS rep_name, 
     r.name AS region_name, 
     SUM(o.total_amt_usd) total_amt 
   FROM 
     sales_reps AS s 
     JOIN accounts AS a ON a.sales_rep_id = s.id 
     JOIN orders AS o ON o.account_id = a.id 
     JOIN region AS r ON r.id = s.region_id 
   GROUP BY 
     rep_name, 
     region_name
)

, t2 AS (
     -- For each region, what's the highest amount of sales
     SELECT 
      region_name, 
      MAX(total_amt) AS total_amt 
     FROM t1
     GROUP BY 
      region_name
)

SELECT 
  t1.rep_name, 
  t1.region_name, 
  t1.total_amt 
FROM t2 
  JOIN t1 ON t1.region_name = t2.region_name 
  AND t1.total_amt = t2.total_amt
ORDER BY total_amt DESC
;
```

### Step 4: Are there other ways of getting to the same answer?
For top sales by region we can look into using WINDOW functions.

```sql
TBD
```




