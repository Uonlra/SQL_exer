-- 1. GROUP BY 进阶与 HAVING
-- 例1： 每用户事件计数后筛选出事件数
-- WHERE 在分组前过滤行，HAVING 在分组后过滤分组
select user_id, count(*) as cnt
from  events
group by user_id
having cnt >= 2;

-- 练习
-- 1.统计每个 event_type 的数量，并只返回数量 >= 2 的 event_type（返回 event_type, cnt）
select event_type, count(*) as cnt
from events
group by event_type
having cnt >= 2;
-- 2.统计每个 city 的用户数量（users 表），并只保留用户数 >= 2 的城市（返回 city, user_count）。
select city, count(*) as user_count
from users
group by city
having user_count >= 2;
-- 3.使用 GROUP BY 多列统计每位用户每天的事件数量（返回 user_id, DATE(event_ts) AS dt, cnt），并返回 cnt >= 1 的记录。
select user_id, DATE(events.event_ts) as dt, count(*) as cnt
from events
group by user_id, DATE (event_ts)
having cnt >= 1;

-- 例2.CTE（WITH）与子查询
with  user_events as
    (select user_id, count(*) as ev_cnt -- 主查询
    from events -- 按 events 表的 user_id 分组，计算每个 user_id 对应的事件数量，结果列为 user_id 和 ev_cnt
    group by user_id
    )
select  u.user_id, u.name, ue.ev_cnt -- 从 users 表取每个用户的 user_id 和 name，然后用 LEFT JOIN 把上面 CTE（每个用户的事件计数）连接进来。
from users u
left join  user_events ue on u.user_id = ue.user_id;
-- 练习 4. 用 CTE 写出每个 user_id 的总事件数（cte 名为 user_events），然后选择 event_count > 1 的用户 id 与 count。
with user_events as(
    select user_id, count(*) as event_count
    from events
    group by user_id
)
select user_id , event_count
from user_events
where event_count > 1;
-- 5. 用相关子查询找出每条 orders 记录对应用户在 events 表中的事件总数（返回 order_id, user_id, amount, event_count）。
select o.order_id, o.user_id, o.amount,
       (
           select  count(*)
           from events e
           where e.user_id = o.user_id
    )  as event_ccount
from orders o;
-- 6. 用 NOT EXISTS 找出从未有任何 events 的用户（返回 user_id, name）。
select u.user_id, u.name
from users u
where not exists(
    select 1 from events e
             where e.user_id = u.user_id
);

-- 字符串与日期/时间函数进阶
-- 例子
-- 提取订单日期与星期几
select order_id, date(order_ts) as order_date, dayofweek(order_ts) as weekday
from orders;
-- 计算用户最近一次事件到现在的天数（示例用固定日期）
select user_id, datediff('2025-01-10', max(event_ts)) as days_since_last
from events
group by user_id;
-- 练习
-- 7. 查询 orders，返回 order_id, order_date (DATE(order_ts)), order_weekday（使用 DAYOFWEEK），按 order_date 排序。
select  order_id, date(order_ts) as order_date, dayofweek(order_ts) as order_weeday
from orders
order by order_date;
-- 8. 查找 users 中 name 以 A 或 C 开头的用户（两个条件），并把名字转成大写显示（返回 user_id, upper_name）。
select user_id, upper(name) as upper_name
from users
where name like 'A%' or name like 'C%';
with last_order as (
    select user_id , max(order_ts) as last_order_ts
    from orders
    group by user_id
)
select o.*
from orders o
join last_order lo on o.user_id = lo.user_id
    and o.order_ts = lo.last_order_ts;

-- 知识整合练习 + 窗口函数入门简介
-- 练习 9. 找出每个 user_id 的最后一次 order 时间（order_ts 最大），并返回 user_id, last_order_ts（可用子查询或 CTE）。
select user_id,max(order_ts) as last_order_ts
from orders
group by user_id;

WITH last_order AS (
  SELECT user_id, MAX(order_ts) AS last_order_ts
  FROM orders
  GROUP BY user_id
)
SELECT o.*
FROM orders o
JOIN last_order lo ON o.user_id = lo.user_id AND o.order_ts = lo.last_order_ts;


--  10. 用 CTE 先计算每位用户在 orders 表的总消费 total_amount，然后列出 total_amount >= 50 的用户（返回 user_id, total_amount）。
with totals as (
    select user_id, sum(amount) as total_amount
    from orders
    group by user_id
)
select user_id, total_amount
from totals
where total_amount >= 50;
-- 11. 利用字符串函数把 users 表中的 name 和 city 拼成 "name|city" 格式并过滤出包含 'Beijing' 的记录（返回 user_id, label）。
select user_id,concat(name, '|', city) as labe1
from users
where city = 'beijing';
-- *** 12. 复合题：找出在 2025-01-01 到 2025-01-05 期间发生过事件且总事件数 >= 2 的用户（返回 user_id, ev_cnt）。提示：先用 WHERE 限定时间，再 GROUP BY HAVING。
select user_id, count(*) as ev_cnt
from events
where event_ts between '2025-01-01' and '2025-01-06'
group by user_id
having  ev_cnt >= 2;
