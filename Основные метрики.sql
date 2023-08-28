-- Определим ARPU - средняя выручка на одного пользователя за определённый период,
-- ARPPU - средняя выручка на одного платящего пользователя за определённый период,
-- AOV - средний чек (отношение выручки за определённый период к общему количеству заказов за это же время).
WITH t1 AS (SELECT creation_time::date AS date, order_id, UNNEST(product_ids) AS product_id
FROM orders
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')),

t2 AS (SELECT product_id, price
FROM products),

t3 AS (SELECT *
FROM t1
LEFT JOIN t2
USING(product_id)),

t4 AS (SELECT DISTINCT date, revenue,
SUM(revenue) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_revenue,
ROUND(((revenue - LAG(revenue) OVER())::decimal*100 / (LAG(revenue) OVER())), 2) AS revenue_change
FROM (SELECT DISTINCT date, SUM(price) OVER(PARTITION BY date) AS revenue
FROM t3) AS f1
ORDER BY date),

t5 AS (SELECT time::date AS date, COUNT(DISTINCT user_id) AS col_users,
COUNT(DISTINCT user_id) FILTER (WHERE  order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')) AS col_activ_users,
COUNT(DISTINCT order_id) FILTER (WHERE  order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')) AS col_order
FROM user_actions
GROUP BY time::date
ORDER BY date)

--Определим ARPU, ARPPU, AOV
SELECT date,
ROUND((revenue::decimal/col_users), 2) AS arpu,
ROUND((revenue::decimal/col_activ_users), 2) AS arppu,
ROUND((revenue::decimal/col_order), 2) AS aov
FROM t4
LEFT JOIN t5
USING(date)
ORDER BY date