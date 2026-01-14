-- 复习
-- 1
select users.user_id, name, users.created_at
From users
ORDER BY created_at DESC
LIMIT 2;
-- 2
select  users.user_id, users.name
from users
order by  user_id
limit 2 offset 2;
-- 练习
-- 1.按 orders.order_ts 降序取最近一条订单（含所有列）。
select *
from Orders
order by order_ts DESC
LIMIT 1;

-- 2.按 events.event_ts 升序显示全部 click 事件，并只看前 3 条。
select events.event_id, user_id, events.event_ts
from events
where event_type = 'click'
order by event_ts ASC
limit 3;
-- 3. 找出 event_ts 在 2025-01-01 到 2025-01-04（含）之间且 event_type = 'click' 的记录。
select *
from events
where event_type = 'click'
    and event_ts between '2025-01-01' AND '2025-01-04 23:59:59';
-- 4.找出 name 以 'C' 开头或 city = 'Shanghai' 的用户（注意 OR 的括号使用）。
select *
from users
where name like 'C%'
    or city = 'Shanghai';
-- 5. 查询 users 中所有不同的 createdd_at 日期（按日期去重），并按日期升序排序。
select distinct  date(created_at) AS order_data
from users
order by order_data asc ;
-- 6.返回 users 的 user_id 和一个 label（格式 "name - city"），如 "Alice - Beijing"。
select users.user_id, concat(users.name, ' - ', users.city) as lable
from users;
-- 7. 查询所有 value 为 NULL 的 events，并按 event_ts 倒序排序（返回 event_id, user_id, event_type, event_ts）。
select event_id, user_id,event_type, event_ts
from events
where value IS NULL
order by event_ts DESC;
-- 8. 查询 orders 表中 amount 在 10 到 100 之间（含边界）的订单，按 amount 降序，返回 order_id, user_id, amount。
select order_id, user_id, amount
from orders
where amount between 10 and 100
order by amount desc ;
-- 9. 找出既有 click 行为又有 purchase 行为的用户 user_id（提示：可以用 EXISTS、IN 或 GROUP BY HAVING）。
SELECT DISTINCT u.user_id
FROM users u
WHERE EXISTS (SELECT 1 FROM events e WHERE e.user_id = u.user_id AND e.event_type = 'click')
  AND EXISTS (SELECT 1 FROM events e2 WHERE e2.user_id = u.user_id AND e2.event_type = 'purchase');

select  user_id
from events
where event_type IN ('click', 'purchase')
group by user_id
having count(distinct  events.event_type) = 2;
-- 10. 分页题：按 user_id 升序返回 users 表第 2 到第 3 条记录（假设每页 2 条，返回第 2 页的数据）。

SELECT user_id, name
FROM users
ORDER BY user_id
LIMIT 2 OFFSET 2;-- offset=2, count=2，返回第 3 和第 4 条（0-based offset）
