/* Q1 Provide region, account, unit price  for every order. Orders should
be more than 300 for each type of paper */

SELECT a.name AS account_name, 
r.name AS region_name, 
o.total_amt_usd/(o.total+0.0001) AS unit_price
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
WHERE o.standard_qty > 300
AND o.poster_qty > 300
AND o.gloss_qty > 300
ORDER BY 3 DESC

/* Q2 Which 5 accounts spent most? (Round result to 0 decimels)*/

WITH t1 AS
(SELECT a.name AS account_name, 
ROUND(SUM(o.total_amt_usd),0) AS money_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5)

SELECT *, RANK() OVER (ORDER BY money_spent DESC)
FROM t1  



/* Q3 Classify Accounts with total spent amount. Accounts with 200000 and more 
TOP, 100000 and more MID, Other LOW. Result sould contain purchases from 2016-2017*/

SELECT a.name AS account_name, 
SUM(o.total_amt_usd) AS money_spent,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'TOP'
WHEN SUM(o.total_amt_usd) > 100000 THEN 'MID'
ELSE 'LOW' END AS classification
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE occurred_at > '2015-12-31' 
GROUP BY 1
ORDER BY 2 DESC


/* Q4 For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
how many web_events did they have for each channel? (Use subquery!) */
SELECT a.name AS account_name, w.channel, COUNT(*) AS num_of_channels
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.name = 
(SELECT account_name
FROM(SELECT a.name AS account_name, 
ROUND(SUM(o.total_amt_usd),0) AS money_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1) t1)
GROUP BY 1, 2

/* Q5 What is the lifetime average amount spent in terms of total_amt_usd 
for the top 10 total spending accounts? */
WITH t1 AS
(SELECT a.name AS account_name, 
SUM(o.total_amt_usd) AS money_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)

SELECT a.name AS account_name, 
ROUND(AVG(o.total_amt_usd),0) AS avg_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE a.name IN (SELECT account_name FROM t1)
GROUP BY 1
ORDER BY 2 DESC




/* Q6 Consider vowels as a, e, i, o, and u. What proportion of company names start
with a vowel? */
WITH t1 AS
(SELECT name,
CASE WHEN UPPER(LEFT(name,1)) IN ('A','E','I','O','U')
THEN 1 ELSE 0  END AS count
FROM accounts)

SELECT SUM(COUNT) AS vowels, COUNT(count) AS all
FROM t1



