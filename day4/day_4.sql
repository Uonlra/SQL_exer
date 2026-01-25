-- 1. 在 events 表中，为每个 user_id 生成 rn（按 event_ts 升序）。
# select event_id, user_id,event_ts,
#        row_number() overs (partition by user_id order by events.event_ts) as rn -- 在每个 user_id 分组（分区）内按 event_ts 排序并为每一行分配唯一的序号（从 1 开始）。
# from events;
-- 2.对 orders 表，为每个 user_id 按 order_ts 降序计算 ROW_NUMBER 并返回 rn = 1 的行（即每用户最近一笔订单的完整 order 行）。
WITH ranked AS ( -- 定义一个临时命名结果集ranked
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_ts ASC) AS rn
  FROM events
)
SELECT * FROM ranked WHERE rn = 1;
-- 3.用窗口函数找出每个 user_id 的 top 1 订单（按 amount），返回 order_id, user_id, amount。
SELECT order_id, user_id, amount
FROM (
  SELECT o.*,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY amount DESC) AS rn
  FROM orders o
) t
WHERE rn = 1;
-- 4.用 RANK 找出 orders 表中按 amount 排名前 2（考虑并列情况）的所有行（即并列情况下返回多于 2 行）。
SELECT order_id, user_id, amount
FROM (
  SELECT o.*,
         RANK() OVER (ORDER BY amount DESC) AS rnk
  FROM orders o
) t
WHERE rnk <= 2;