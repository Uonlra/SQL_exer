-- Day 2: SQL 练习脚本（ORDER/LIMIT, WHERE 复杂条件, DISTINCT, 字符串/日期函数, 分页）
-- 使用方法：
-- 1) 在 DataGrip 中选择 demo_sql 数据库（或在脚本顶部修改 USE 行为你的库名）
-- 2) 先尝试自己编写/运行每道题对应的查询（��目下方有写答案的位置）
-- 3) 若想查看参考答案，请到文档底部的 “-- 参考答案（已注释）” 区域取消相应行的注释执行
-- 注意：脚本中大部分为注释题目，不会在执行时产生副作用

USE demo_sql;

-- ============================================
-- Hour 1: ORDER BY / LIMIT / OFFSET
-- ============================================

-- 练习 1:
-- 按 orders.order_ts 降序取最近一条订单（含所有列）。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- 练习 2:
-- 按 events.event_ts 升序显示全部 event_type = 'click' 的记录，并只看前 3 条（返回 event_id, user_id, event_ts）。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- ============================================
-- Hour 2: 复杂 WHERE（AND/OR/NOT/IN/BETWEEN/LIKE/NULL）
-- ============================================

-- 练习 3:
-- 找出 event_ts 在 2025-01-01 到 2025-01-04（含）之间且 event_type = 'click' 的记录。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- 练习 4:
-- 找出 name 以 'C' 开头或 city = 'Shanghai' 的用户（返回所有列）。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- ============================================
-- Hour 3: DISTINCT、别名、字符串与日期函数
-- ============================================

-- 练习 5:
-- 查询 orders 中所有不同的 order 日期（按日期去重），并按日期升序排序。返回列名 order_date。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- 练习 6:
-- 返回 users 的 user_id 和一个 label（格式 "name - city"），如 "Alice - Beijing"。列名为 label。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- ============================================
-- Hour 4: 综合练习与检查点
-- ============================================

-- 练习 7:
-- 查询所有 value 为 NULL 的 events，并按 event_ts 倒序排序（返回 event_id, user_id, event_type, event_ts）。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- 练习 8:
-- 查询 orders 表中 amount 在 10 到 100 之间（含边界）的订单，按 amount 降序，返回 order_id, user_id, amount。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- 练习 9:
-- 找出既有 click 行为又有 purchase 行为的用户 user_id（返回 user_id）。提示：可用 EXISTS 或 GROUP BY + HAVING。
-- 在下面编写你的 SQL（或查看底部参考答案）。

-- 练习 10:
-- 分页题：按 user_id 升序返回 users 表第 2 页记录（每页 2 条，即返回 offset=2 开始的 2 条）。
-- 返回 user_id, name。
-- 在下面编写你的 SQL（或查看底部参考答案）。


-- ============================================
-- 参考答案（已注释）—— 若需执行，请去掉对应查询前的注释符号 "--"
-- ============================================

-- 练习 1 参考答案：
-- SELECT *
-- FROM orders
-- ORDER BY order_ts DESC
-- LIMIT 1;

-- 练习 2 参考答案：
-- SELECT event_id, user_id, event_ts
-- FROM events
-- WHERE event_type = 'click'
-- ORDER BY event_ts ASC
-- LIMIT 3;

-- 练习 3 参考答案：
-- SELECT *
-- FROM events
-- WHERE event_type = 'click'
--   AND event_ts BETWEEN '2025-01-01' AND '2025-01-04 23:59:59';

-- 练习 4 参考答案：
-- SELECT *
-- FROM users
-- WHERE name LIKE 'C%'
--    OR city = 'Shanghai';

-- 练习 5 参考答案：
-- SELECT DISTINCT DATE(order_ts) AS order_date
-- FROM orders
-- ORDER BY order_date ASC;

-- 练习 6 参考答案：
-- SELECT user_id, CONCAT(name, ' - ', city) AS label
-- FROM users;

-- 练习 7 参考答案：
-- SELECT event_id, user_id, event_type, event_ts
-- FROM events
-- WHERE value IS NULL
-- ORDER BY event_ts DESC;

-- 练习 8 参考答案：
-- SELECT order_id, user_id, amount
-- FROM orders
-- WHERE amount BETWEEN 10 AND 100
-- ORDER BY amount DESC;

-- 练习 9 参考答案（EXISTS 版本）：
-- SELECT DISTINCT u.user_id
-- FROM users u
-- WHERE EXISTS (SELECT 1 FROM events e WHERE e.user_id = u.user_id AND e.event_type = 'click')
--   AND EXISTS (SELECT 1 FROM events e2 WHERE e2.user_id = u.user_id AND e2.event_type = 'purchase');

-- 练习 9 参考答案（GROUP BY + HAVING 版本）：
-- SELECT user_id
-- FROM events
-- WHERE event_type IN ('click', 'purchase')
-- GROUP BY user_id
-- HAVING COUNT(DISTINCT event_type) = 2;

-- 练习 10 参考答案（第 2 页，每页 2 条，offset = (2-1)*2 = 2）：
-- SELECT user_id, name
-- FROM users
-- ORDER BY user_id
-- LIMIT 2 OFFSET 2;

-- ============================================
-- 可选：把某个查询结果导出为 CSV（DataGrip 中也能右键导出）
-- 例如：将 top 2 用户导出为 /tmp/top2_users.csv（本地 MySQL 需要文件写权限）
-- 注意：在容器/服务器上写文件时路径需服务器可写，DataGrip 导出更便捷。
-- SELECT user_id, SUM(amount) AS total_amount
-- FROM orders
-- GROUP BY user_id
-- ORDER BY total_amount DESC
-- LIMIT 2
-- INTO OUTFILE '/tmp/top2_users.csv'
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';
-- ============================================