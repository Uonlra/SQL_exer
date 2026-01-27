-- 练习 1:
-- 在 events 表中，为每个 user_id 生成 rn（按 event_ts 升序）。
SELECT event_id, user_id, event_ts,
       ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_ts) AS rn
FROM events;

-- 练习 2:
-- 对 orders 表，为每个 user_id 按 order_ts 降序计算 ROW_NUMBER 并返回 rn = 1 的行（即每用户最近一笔订单的完整 order 行）。
SELECT order_id, user_id, amount, order_ts, status
FROM (
  SELECT o.*,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_ts DESC) AS rn
  FROM orders o
) t
WHERE rn = 1;

-- 练习 3:
-- 用窗口函数找出每个 user_id 的 top 1 订单（按 amount），返回 order_id, user_id, amount。
SELECT order_id, user_id, amount
FROM (
  SELECT o.*,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY amount DESC) AS rn
  FROM orders o
) t
WHERE rn = 1;

-- 练习 4:
-- 用 RANK 找出 orders 表中按 amount 排名前 2（考虑并列情况）的所有行。
SELECT order_id, user_id, amount
FROM (
  SELECT o.*,
         RANK() OVER (ORDER BY amount DESC) AS rnk
  FROM orders o
) t
WHERE rnk <= 2;

-- 练习 5:
-- 计算每个用户事件之间的分钟差（diff_min），并筛选出 diff_min IS NOT NULL 的行。
SELECT event_id, user_id, event_ts, prev_ts,
       TIMESTAMPDIFF(MINUTE, prev_ts, event_ts) AS diff_min
FROM (
  SELECT e.*,
         LAG(event_ts) OVER (PARTITION BY user_id ORDER BY event_ts) AS prev_ts
  FROM events e
) t
WHERE prev_ts IS NOT NULL
ORDER BY user_id, event_ts;

-- 练习 6:
-- 在 orders 表中为每个用户计算按 order_ts 排序的累计消费（running_total）。
SELECT order_id, user_id, amount, order_ts,
       SUM(amount) OVER (PARTITION BY user_id ORDER BY order_ts
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders
ORDER BY user_id, order_ts;

-- 练习 7:
-- 用窗口函数为每个 user_id 计算 events 的 running_cnt（累计事件数），并用 CTE 输出每个用户最后一条事件所在行（带 running_cnt）。
WITH ev_with_running AS (
  SELECT e.*,
         COUNT(*) OVER (PARTITION BY user_id ORDER BY event_ts
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_cnt,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_ts DESC) AS rn_desc
  FROM events e
)
SELECT event_id, user_id, event_ts, running_cnt
FROM ev_with_running
WHERE rn_desc = 1;

-- 练习 8:
-- 对每个 user_id，生成三列特征：total_events（历史总事件数）、last_event_ts、avg_event_interval_min（平均两次事件间隔，单位分钟，若少于 2 次则为 NULL）。
WITH ev AS (
  SELECT *,
         LAG(event_ts) OVER (PARTITION BY user_id ORDER BY event_ts) AS prev_ts
  FROM events
),
gap AS (
  SELECT user_id,
         TIMESTAMPDIFF(MINUTE, prev_ts, event_ts) AS gap_min
  FROM ev
  WHERE prev_ts IS NOT NULL
),
agg_gap AS (
  SELECT user_id,
         AVG(gap_min) AS avg_event_interval_min
  FROM gap
  GROUP BY user_id
),
totals AS (
  SELECT user_id, COUNT(*) AS total_events, MAX(event_ts) AS last_event_ts
  FROM events
  GROUP BY user_id
)
SELECT u.user_id,
       COALESCE(t.total_events, 0) AS total_events,
       t.last_event_ts,
       a.avg_event_interval_min
FROM users u
LEFT JOIN totals t ON u.user_id = t.user_id
LEFT JOIN agg_gap a ON u.user_id = a.user_id;