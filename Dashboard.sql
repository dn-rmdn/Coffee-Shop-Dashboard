-- Dashboard 1 : Sales
CREATE VIEW Sales AS
SELECT 
o.created_at,
o.order_id,
i.item_name,
i.item_cat,
o.quantity,
i.item_price,
o.in_or_out
FROM orders o
LEFT JOIN items i ON o.item_id = i.item_id;

-- Dashboard 2 : Stock
CREATE VIEW Stocks AS
WITH CTE_stocks AS
(SELECT
i.item_id,
i.item_name,
i.sku,
i.item_size,
r.ing_id,
ing.ing_name,
sum(o.quantity) AS order_quantity,
r.quantity AS recipe_quantity,
ing.ing_weight,
ing.ing_price
FROM orders o
LEFT JOIN items i ON o.item_id = i.item_id
LEFT JOIN recipe r ON i.sku = r.recipe_id
LEFT JOIN ingredients ing ON r.ing_id = ing.ing_id
GROUP BY
	i.sku,
    i.item_id,
    i.item_name,
    item_size,
    r.ing_id,
    r.quantity,
    ing.ing_name,
    ing.ing_weight,
	ing.ing_price)
SELECT 
item_id,
item_name,
item_size,
ing_id,
ing_name,
ing_weight,
ing_price,
order_quantity,
recipe_quantity,
order_quantity*recipe_quantity as ordered_weight,
ing_price/ing_weight as unit_cost,
order_quantity*recipe_quantity*(ing_price/ing_weight) as ingredient_cost
FROM CTE_Stocks;

CREATE VIEW STOCK2 AS
SELECT 
s1.ing_id,
s1.ing_name,
s1.ordered_weight,
inv.quantity*ing.ing_weight as total_inv_weight
FROM (SELECT 
s.ing_id,
s.ing_name,
sum(ordered_weight) as ordered_weight
FROM stocks s
GROUP BY s.ing_name, s.ing_id) s1
LEFT JOIN ingredients ing ON s1.ing_id = ing.ing_id
LEFT JOIN inventory inv ON s1.ing_id = inv.ing_id
GROUP BY
s1.ing_id,
s1.ing_name,
s1.ordered_weight,
total_inv_weight;

-- Dashboard 3: Staff
CREATE VIEW Staff_Cost AS
SELECT
DATE(r.date) as date,
s.first_name,
s.last_name,
s.sal_per_hour as hourly_rate,
TIME(sh.start_time) as start_time,
TIME(sh.end_time) as end_time,
((hour(timediff(sh.end_time,sh.start_time))*60)+(minute(timediff(sh.end_time,sh.start_time))))/60 as hour_in_shift,
((hour(timediff(sh.end_time,sh.start_time))*60)+(minute(timediff(sh.end_time,sh.start_time))))/60*s.sal_per_hour as staff_cost
FROM rota r
LEFT JOIN staff s on r.staff_id = s.staff_id
LEFT JOIN shift sh on r.shift_id = sh.shift_id;


