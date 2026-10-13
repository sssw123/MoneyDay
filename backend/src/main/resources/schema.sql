-- ============================================================
-- MoneyDay 核心数据库结构定义 (MySQL 8.0+)
-- ============================================================

-- 1. 周期模板表 (Cycle Template)
CREATE TABLE IF NOT EXISTS `cycle_template` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL COMMENT '周期名称',
    `start_day` INT NOT NULL COMMENT '起算日 (1-31)',
    `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认周期',
    `fixed_items` JSON NULL COMMENT '周期固定收支固存项 (JSON)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='周期模板表';

INSERT IGNORE INTO `cycle_template` (`id`, `name`, `start_day`, `is_default`, `fixed_items`) 
VALUES (1, '自然月', 1, 1, '[]');

-- 2. 用户表 (单用户)
CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

INSERT IGNORE INTO `user` (`id`, `username`, `password`) VALUES (1, 'admin', '123456');

-- 3. 账户表
CREATE TABLE IF NOT EXISTS `account` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL COMMENT '账户名称，如招商银行、微信',
  `type` VARCHAR(20) NOT NULL COMMENT '账户类型，如 CASH, BANK, EWALLET',
  `initial_balance` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '期初余额',
  `current_balance` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '当前余额',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账户表';

-- 4. 分类表
CREATE TABLE IF NOT EXISTS `category` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `type` TINYINT NOT NULL COMMENT '1=收入, 2=支出',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用 1=是, 0=否（代替硬删除）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收支分类表';

INSERT IGNORE INTO `category` (`id`, `name`, `type`, `is_active`) VALUES 
(1, '工资', 1, 1), (2, '理财收益', 1, 1),
(3, '餐饮', 2, 1), (4, '交通', 2, 1), (5, '购物', 2, 1), (6, '房租', 2, 1), (7, '分期还款', 2, 1);

-- 5. 账单流水表
CREATE TABLE IF NOT EXISTS `transaction` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `type` TINYINT NOT NULL COMMENT '1=收入, 2=支出, 3=转账',
  `amount` DECIMAL(18,2) NOT NULL COMMENT '金额，必须为正数',
  `transaction_date` DATE NOT NULL COMMENT '记账纯日期',
  `category_id` BIGINT NULL COMMENT '分类ID（转账无分类）',
  `account_id` BIGINT NOT NULL COMMENT '收/支账户ID（转账时为转出账户）',
  `to_account_id` BIGINT NULL COMMENT '转账时的转入账户ID',
  `remark` VARCHAR(255) NULL COMMENT '备注',
  `liability_id` BIGINT NULL COMMENT '关联的负债ID',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账单流水表';

-- 6. 周期快照表 (Cycle Record)
CREATE TABLE IF NOT EXISTS `cycle_record` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `cycle_start_date` DATE NOT NULL COMMENT '周期开始日期',
  `cycle_end_date` DATE NOT NULL COMMENT '周期结束日期',
  `fixed_items` JSON NULL COMMENT '周期固定项快照 (JSON)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='周期快照表';

-- 7. 目标表 (净资产目标)
CREATE TABLE IF NOT EXISTS `target` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL COMMENT '目标名称',
  `target_amount` DECIMAL(18,2) NOT NULL COMMENT '目标金额',
  `deadline` DATE NULL COMMENT '截止日期',
  `start_date` DATE NOT NULL COMMENT '立项时间',
  `is_realized` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已实现 0=否, 1=是',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='目标表';

-- 8. 心愿单表 (独立储蓄心愿)
CREATE TABLE IF NOT EXISTS `wishlist` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT '心愿名称',
  `target_amount` DECIMAL(18,2) NOT NULL COMMENT '心愿金额',
  `deadline` DATE NULL COMMENT '期望日期',
  `start_date` DATE NOT NULL COMMENT '立项时间',
  `is_realized` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0: 心愿中, 1: 已实现',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='心愿单表';

-- 9. 透支分期表 (Liability)
CREATE TABLE IF NOT EXISTS `liability` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT '分期/负债名称',
  `principal` DECIMAL(18,2) NOT NULL COMMENT '分期本金',
  `total_amount` DECIMAL(18,2) NOT NULL COMMENT '总待还本息总额',
  `total_periods` INT NOT NULL COMMENT '总期数',
  `current_period` INT NOT NULL DEFAULT 0 COMMENT '已还期数',
  `period_amount` DECIMAL(18,2) NOT NULL COMMENT '每期应还金额',
  `rate_type` VARCHAR(20) NOT NULL DEFAULT 'NONE' COMMENT 'NONE: 免息, FEE: 每期手续费率, APR: 年化等额本息',
  `interest_rate` DECIMAL(8,4) NOT NULL DEFAULT 0.0000 COMMENT '利率/费率百分比',
  `repayment_day` INT NOT NULL COMMENT '每月还款日 (1-31)',
  `next_repayment_date` DATE NULL COMMENT '下一次应还日期',
  `default_account_id` BIGINT NOT NULL COMMENT '默认扣款账户',
  `category_id` BIGINT NOT NULL COMMENT '支出记账分类ID',
  `auto_cycle_fixed_expense` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1: 自动纳入周期固定支出, 0: 否',
  `status` VARCHAR(20) NOT NULL DEFAULT 'REPAYING' COMMENT 'REPAYING: 还款中, SETTLED: 已结清',
  `start_date` DATE NOT NULL COMMENT '首期起算日期',
  `settled_at` DATETIME NULL COMMENT '提前结清时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='透支分期表';

-- 10. 待办事项表 (Todo Item)
CREATE TABLE IF NOT EXISTS `todo_item` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `type` VARCHAR(30) NOT NULL COMMENT '待办类型: LIABILITY_OVERDUE(分期扣款失败), CYCLE_FIXED_ITEMS(新周期账单提醒), WISHLIST_REACHED(心愿达成)',
  `title` VARCHAR(100) NOT NULL COMMENT '待办标题',
  `content` VARCHAR(255) NOT NULL COMMENT '待办详细说明',
  `biz_id` VARCHAR(64) NOT NULL COMMENT '业务关联ID: liability_id, cycle_id, wishlist_id',
  `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING, RESOLVED, DISMISSED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_status_type` (`status`, `type`),
  INDEX `idx_biz` (`biz_id`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='待办事项与告警中心表';
