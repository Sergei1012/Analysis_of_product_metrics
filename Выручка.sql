WITH t1 AS (SELECT creation_time::date AS date, order_id, UNNEST(product_ids) AS product_id
FROM orders
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')),

t2 AS (SELECT product_id, price
FROM products),

t3 AS (SELECT *
FROM t1
LEFT JOIN t2
USING(product_id))

--Определим выручку на этот день, суммарную выручку на текущий день и  прирост вырочки
SELECT DISTINCT date, revenue,
SUM(revenue) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_revenue,
ROUND(((revenue - LAG(revenue) OVER())::decimal*100 / (LAG(revenue) OVER())), 2) AS revenue_change
FROM (SELECT DISTINCT date, SUM(price) OVER(PARTITION BY date) AS revenue
FROM t3) AS f1
ORDER BY date