-- Demo SQL setup + exercises for Day 1 (suitable for MySQL / DataGrip)
-- 使用方法：在 DataGrip 的 demo_sql 数据库 Console 中粘贴并运行整个脚本（或分块运行）。
-- 如果需要 demo 用户可选性建用户（下面包含创建 demo 用户的语句，可按需执行）。

/* --------------------------
   Database & user (optional)
   -------------------------- */
CREATE DATABASE IF NOT EXISTS demo_sql;
USE demo_sql;

-- 可选：创建 demo 用户并授权（如果不需要请注释掉或略过）
-- 注意：在某些环境下需由具有足够权限的账户执行（例如 root）
CREATE USER IF NOT EXISTS 'demo'@'%' IDENTIFIED BY 'demo_pwd';
GRANT ALL PRIVILEGES ON demo_sql.* TO 'demo'@'%';
FLUSH PRIVILEGES;

/* --------------------------
   Tables: users, events, orders
   -------------------------- */
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  user_id INT PRIMARY KEY,
  name VARCHAR(50),
  city VARCHAR(50),
  created_at DATE
);

CREATE TABLE events (
  event_id INT PRIMARY KEY,
  user_id INT,
  event_type VARCHAR(50),
  event_ts DATETIME,
  value INT,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  user_id INT,
  amount DECIMAL(10,2),
  order_ts DATETIME,
  status VARCHAR(20),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

/* --------------------------
   Sample data
   -------------------------- */
INSERT INTO users (user_id, name, city, created_at) VALUES
(1,'Alice','Beijing','2024-11-01'),
(2,'Bob','Shanghai','2024-10-10'),
(3,'Carol','Beijing','2024-12-15'),
(4,'Dave','Guangzhou','2025-01-01');

INSERT INTO events (event_id, user_id, event_type, event_ts, value) VALUES
(1,1,'login','2025-01-01 08:00:00', NULL),
(2,1,'click','2025-01-01 08:05:00', 1),
(3,2,'login','2025-01-02 09:00:00', NULL),
(4,3,'click','2025-01-03 10:00:00', 3),
(5,1,'purchase','2025-01-04 11:00:00', 100),
(6,2,'click','2025-01-04 12:00:00', 2);

INSERT INTO orders (order_id, user_id, amount, order_ts, status) VALUES
(100,1,99.90,'2025-01-04 11:01:00','paid'),
(101,3,15.50,'2025-01-05 10:00:00','paid');

/* --------------------------
   Day 1 Exercises (do them yourself first)
   在 DataGrip 中逐题运行并检查结果；答案在每题下方注释中。
   -------------------------- */

-- Exercise 1:
-- 查询 users 表所有列（全部用户）。
-- ANSWER:
-- SELECT * FROM users;

-- Exercise 2:
-- 查询 users 表中 name 和 created_at 两列，给 created_at 起别名 signup_date。
-- ANSWER:
-- SELECT name, created_at AS signup_date FROM users;

-- Exercise 3:
-- 查询 events 表中所有 event_type 为 'click' 的行（返回 event_id, user_id, event_ts）。
-- ANSWER:
-- SELECT event_id, user_id, event_ts
-- FROM events
-- WHERE event_type = 'click';

-- Exercise 4:
-- 从 users 中找出 city = 'Beijing' 的用户，按 created_at 降序返回 name 和 created_at，只取前 2 条。
-- ANSWER:
-- SELECT name, created_at
-- FROM users
-- WHERE city = 'Beijing'
-- ORDER BY created_at DESC
-- LIMIT 2;

-- Exercise 5:
-- 在 events 表中，查找 value 不为 NULL 的记录并按 value 降序排序。
-- ANSWER:
-- SELECT * FROM events
-- WHERE value IS NOT NULL
-- ORDER BY value DESC;

-- Exercise 6:
-- 查询 orders 表所有不同的 status（去重）。
-- ANSWER:
-- SELECT DISTINCT status FROM orders;

-- Exercise 7:
-- 统计每个 user_id 在 events 表中的事件数量（返回 user_id, event_count）。
-- ANSWER:
-- SELECT user_id, COUNT(*) AS event_count
-- FROM events
-- GROUP BY user_id;

-- Exercise 8:
-- 统计每个 user_id 的订单总金额（SUM(amount)），并按总金额降序。
-- ANSWER:
-- SELECT user_id, SUM(amount) AS total_amount
-- FROM orders
-- GROUP BY user_id
-- ORDER BY total_amount DESC;

-- Exercise 9:
-- 找出 event_type = 'click' 的总次数（全表聚合）。
-- ANSWER:
-- SELECT COUNT(*) AS click_count
-- FROM events
-- WHERE event_type = 'click';

-- Exercise 10:
-- 列出每位用户的最新一次事件时间（user_id, last_event_ts）。
-- ANSWER:
-- SELECT user_id, MAX(event_ts) AS last_event_ts
-- FROM events
-- GROUP BY user_id;

-- Exercise 11:
-- 找出没有下单的用户（返回 user_id, name）。
-- ANSWER (方法 A: LEFT JOIN):
-- SELECT u.user_id, u.name
-- FROM users u
-- LEFT JOIN orders o ON u.user_id = o.user_id
-- WHERE o.order_id IS NULL;
-- ANSWER (方法 B: NOT EXISTS):
-- SELECT u.user_id, u.name
-- FROM users u
-- WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.user_id);

-- Exercise 12:
-- 找出按用户总消费排序的 top 2 用户（user_id 和 total_amount），并把结果导出为 CSV（如果在本地使用 INTO OUTFILE）。
-- ANSWER (查询部分):
-- SELECT user_id, SUM(amount) AS total_amount
-- FROM orders
-- GROUP BY user_id
-- ORDER BY total_amount DESC
-- LIMIT 2;
-- ANSWER (本地 MySQL 导出 CSV 示例，需 MySQL 进程对目标目录有写权限)：
-- SELECT user_id, SUM(amount) AS total_amount
-- FROM orders
-- GROUP BY user_id
-- ORDER BY total_amount DESC
-- LIMIT 2
-- INTO OUTFILE '/tmp/top2_users.csv'
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

/* --------------------------
   小提示与说明
   - 如果在 DataGrip 无法使用 INTO OUTFILE（通常因为 MySQL 文件系统权限），请使用 DataGrip 结果面板的 Export 功能导出 CSV。
   - 如果想清空并重新跑一遍，请先 DROP TABLE 或重新创建数据库：
     DROP DATABASE IF EXISTS demo_sql;
   - MySQL 8 支持窗口函数（如 ROW_NUMBER() OVER ...），将在后续练习中使用。
   -------------------------- */

-- End of script