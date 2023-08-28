-- Определим выручку за каждый день
WITH t1 AS (SELECT *, SUM(price) OVER(PARTITION BY date) AS revenue
FROM (SELECT creation_time::date AS date, order_id, UNNEST(product_ids) AS product_id
FROM orders
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')) AS f1
LEFT JOIN products
USING(product_id)
ORDER BY date),

-- Определим количество курьеров, доставлявших 5 и более заказов в конкретный день
t2 AS (SELECT date, COUNT(DISTINCT courier_id)  AS courier_count_5
FROM (SELECT time::date AS date, courier_id, order_id, action, COUNT(order_id) OVER(PARTITION BY time::date, courier_id) AS count_order
FROM courier_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order') AND action='deliver_order') AS f2
WHERE count_order>=5
GROUP BY date),

-- Определим количество оформленных заказов в каждый день
t3 AS (SELECT DISTINCT date, COUNT(DISTINCT order_id) AS counts_day
FROM t1
GROUP BY date),

-- Определим количество доставленных заказов для каждого дня
t4 AS (SELECT DISTINCT time::date AS date, COUNT(order_id) OVER(PARTITION BY time::date) AS count_order_deliver
FROM courier_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order') AND action='deliver_order'
ORDER BY date),

-- Определим издержки для каждого дня
t5 AS (SELECT *,
CASE
WHEN DATE_PART('month', date)=8 THEN 120000 + 140 * counts_day + 150 * count_order_deliver + 400 * count_courier_5
WHEN DATE_PART('month', date)=9 THEN 150000 + 115 * counts_day + 150 * count_order_deliver + 500 * count_courier_5
END AS costs
FROM (SELECT *, COALESCE(courier_count_5, 0) AS count_courier_5
FROM t1
LEFT JOIN t3
USING(date)
LEFT JOIN t2
USING(date)
LEFT JOIN t4
USING(date)) AS f4),

-- Определим НДС для каждого продукта и НДС для каждого дня
t6 AS (SELECT date, revenue, ROUND(costs, 2) AS costs , SUM(nds) OVER(PARTITION BY date) AS tax
FROM (SELECT *,
CASE
WHEN name IN ('сахар', 'сухарики', 'сушки', 'семечки', 
'масло льняное', 'виноград', 'масло оливковое', 
'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
'овсянка', 'макароны', 'баранина', 'апельсины', 
'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 
'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 
'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 
'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') THEN ROUND(10*price/110, 2)
ELSE ROUND(20*price/120, 2)
END nds
FROM t5) AS f6)


SELECT *,
-- Валовая прибыль за день
revenue - costs - tax AS gross_profit,
-- Суммарная выручку на текущий день 
SUM(revenue) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_revenue,
-- Суммарные затраты на текущий день
SUM(costs) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_costs,
-- Суммарный НДС на текущий день
SUM(tax) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_tax,
-- Суммарная валовая прибыль на текущий день
SUM(revenue - costs - tax) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_gross_profit,
-- Доля валовой прибыли в выручке за этот день
ROUND(((revenue - costs - tax)*100::decimal/revenue), 2) AS gross_profit_ratio,
-- Доля суммарной валовой прибыли в суммарной выручке на текущий день
ROUND(((SUM(revenue - costs - tax) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))*100::decimal/
(SUM(revenue) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))), 2) AS total_gross_profit_ratio
FROM (SELECT DISTINCT * FROM t6) AS f7