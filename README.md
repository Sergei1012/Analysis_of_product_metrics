# Анализ продуктовых метрик

Цель проекта заключалась в анализе необходимых метрик продукта. Были проанализированны данные компании по доставке продуктов.

Структыра базы данных:

![](https://github.com/Sergei1012/Analysis_of_product_metrics/blob/master/Структура%20БД.png)

# Результаты

На данном графике показана динамика количества новых пользователей и курьеров.

![](https://github.com/Sergei1012/Analysis_of_product_metrics/blob/master/Графики/Динамика%20количества%20пользователей%20и%20курьеров.png)

По имеющимся данным была расчитана выручка за текущий день и прирост выручки, по сравнению с прошлым днем. Полученные зависимости приведены на графике:

![](https://github.com/Sergei1012/Analysis_of_product_metrics/blob/master/Графики/Выручка.png)

Как видно из графика с 4 по 6 сентября наблюдалось значительное снижение ежедневной выручки, скорее всего, это связано с меньшим притоком новых пользователей и курьеров в эти дни.

На основании данных о выручке были расчитаны относительные показатели, которые показывают сколько готовы платить пользователи за услуги сервиса доставки. Вот эти метрики:
- ARPU (Average Revenue Per User) — средняя выручка на одного пользователя за день
- ARPPU (Average Revenue Per Paying User) — средняя выручка на одного платящего пользователя за день
- AOV (Average Order Value) — средний чек пользователя за день

  Получененные зависимости приведены на данном графике:

  ![](https://github.com/Sergei1012/Analysis_of_product_metrics/blob/master/Графики/ARPU.png)

Также было выявлено, какие товары пользуются наибольшим спросом и приносят основной доход. Товары, доля в выручки которых составляет менее 0,5% были объединены в одру группу "ДРУГОЕ".

![](https://github.com/Sergei1012/Analysis_of_product_metrics/blob/master/Графики/Распределение%20продуктов%20в%20зависимости%20от%20выручки.png)

Из диаграммы можем сделать вывод, что большую часть в выручке составляю мясные продукты.

Также были расчитаны затраты с налогами и посчитана валовая прибыль, то есть сумма которую фактически получил бизнес в результате реализации товаров за рассматриваемый период.

![](https://github.com/Sergei1012/Analysis_of_product_metrics/blob/master/Графики/Динамика%20валовой%20прибыли.png)

Как видно из графика, начиная с 31 августа валовая прибыль компании стала положительной. Но лишь 5 сентября суммарная валовая прибыль превысила нулевую отметку и сервис впервые «вышел в плюс» по этому показателю.

![](https://github.com/Sergei1012/Analysis_of_product_metrics/blob/master/Графики/Суммарная%20валовая%20прибыль.png)
