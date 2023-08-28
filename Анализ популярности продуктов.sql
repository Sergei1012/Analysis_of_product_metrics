WITH t1 AS  (SELECT UNNEST(product_ids) AS product_id, COUNT(order_id) AS count_product
FROM orders
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action='cancel_order')
GROUP BY product_id),

t2 AS (SELECT *
FROM products
LEFT JOIN t1
USING(product_id)), 

--Товары, доля которых в выручке составляет меньше 0,5% поместим в категорию ДРУГОЕ
t3 AS (SELECT *,
case
WHEN ROUND(((price*count_product)*100::decimal/(SUM((price*count_product)) OVER())), 2)<0.5 THEN 'ДРУГОЕ'
ELSE name
END product_name
FROM t2),

--Определим суммарную выручку от продажи конкретного товара и долю выручки товара от общей выручки 
t4 AS (SELECT product_name, (price*count_product) AS revenue, 
ROUND(((price*count_product)*100::decimal/(SUM((price*count_product)) OVER())), 2) AS share_in_revenue
FROM t3
ORDER BY revenue desc),

t5 AS (SELECT product_name, SUM(revenue) AS revenue
FROM t4
GROUP BY product_name
ORDER BY revenue desc)

SELECT *,
ROUND(((revenue)*100::decimal/(SUM((revenue)) OVER())), 2) AS share_in_revenue
FROM t5