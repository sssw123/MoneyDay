-- 由具有建库/授权权限的管理员执行；仅创建新库，不操作旧库。
CREATE DATABASE IF NOT EXISTS moneyday_multiuser
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 将 YOUR_APP_USER / YOUR_APP_HOST 替换为现有应用账号与其授权来源。
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER
  ON moneyday_multiuser.* TO 'YOUR_APP_USER'@'YOUR_APP_HOST';
-- 随后用 InitializeDatabase.java 对空库执行 schema.sql；非空库会被拒绝。
