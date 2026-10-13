export const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS cycle_template (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  start_day INTEGER NOT NULL,
  is_default INTEGER DEFAULT 0,
  fixed_items TEXT NULL
);

CREATE TABLE IF NOT EXISTS account (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  initial_balance REAL NOT NULL DEFAULT 0.0,
  current_balance REAL NOT NULL DEFAULT 0.0,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS category (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS transaction_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type INTEGER NOT NULL,
  amount REAL NOT NULL,
  transaction_date TEXT NOT NULL,
  category_id INTEGER NULL,
  account_id INTEGER NOT NULL,
  to_account_id INTEGER NULL,
  remark TEXT NULL,
  liability_id INTEGER NULL,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS cycle_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cycle_start_date TEXT NOT NULL,
  cycle_end_date TEXT NOT NULL,
  fixed_items TEXT NULL,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS target (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  deadline TEXT NULL,
  start_date TEXT NOT NULL,
  is_realized INTEGER NOT NULL DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS wishlist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  deadline TEXT NULL,
  start_date TEXT NOT NULL,
  is_realized INTEGER NOT NULL DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS liability (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  principal REAL NOT NULL,
  total_amount REAL NOT NULL,
  total_periods INTEGER NOT NULL,
  current_period INTEGER NOT NULL DEFAULT 0,
  period_amount REAL NOT NULL,
  rate_type TEXT NOT NULL DEFAULT 'NONE',
  interest_rate REAL NOT NULL DEFAULT 0.0,
  repayment_day INTEGER NOT NULL,
  next_repayment_date TEXT NULL,
  default_account_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  auto_cycle_fixed_expense INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'REPAYING',
  start_date TEXT NOT NULL,
  settled_at TEXT NULL,
  created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

CREATE TABLE IF NOT EXISTS todo_item (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  biz_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'PENDING',
  created_at TEXT DEFAULT (datetime('now', 'localtime')),
  updated_at TEXT DEFAULT (datetime('now', 'localtime'))
);
`;

export const SEED_SQL = `
INSERT OR IGNORE INTO user (id, username, password) VALUES (1, 'admin', '123456');

INSERT OR IGNORE INTO cycle_template (id, name, start_day, is_default, fixed_items) 
VALUES (1, '自然月', 1, 1, '[]');

INSERT OR IGNORE INTO account (id, name, type, initial_balance, current_balance) VALUES
(1, '微信钱包', 'EWALLET', 0.0, 0.0),
(2, '支付宝', 'EWALLET', 0.0, 0.0),
(3, '招商银行', 'BANK', 0.0, 0.0);

INSERT OR IGNORE INTO category (id, name, type, is_active) VALUES
(1, '工资', 1, 1),
(2, '理财收益', 1, 1),
(3, '餐饮', 2, 1),
(4, '交通', 2, 1),
(5, '购物', 2, 1),
(6, '房租水电', 2, 1),
(7, '分期还款', 2, 1),
(8, '目标', 2, 1);
`;
