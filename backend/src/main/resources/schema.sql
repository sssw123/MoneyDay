-- 用户表 (单用户)
CREATE TABLE IF NOT EXISTS `cycle_template` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    `start_day` INT NOT NULL COMMENT '1-31',
    `is_default` TINYINT(1) DEFAULT 0,
    `default_fixed_deposit` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '全局默认固存金额'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `cycle_template` (name, start_day, is_default) VALUES ('自然月', 1, 1);

CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `billing_cycle_start_day` INT NOT NULL DEFAULT 1 COMMENT '账单周期起算日 (1-31)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入默认单用户 (密码 123456 的 bcrypt 或是明文，MVP先简单处理)
INSERT IGNORE INTO `user` (`id`, `username`, `password`, `billing_cycle_start_day`) VALUES (1, 'admin', '123456', 1);

-- 账户表
CREATE TABLE IF NOT EXISTS `account` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL COMMENT '账户名称，如招商银行、微信',
  `type` VARCHAR(20) NOT NULL COMMENT '账户类型，如 CASH, BANK, EWALLET',
  `initial_balance` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '期初余额',
  `current_balance` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '当前余额',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账户表';

-- 分类表
CREATE TABLE IF NOT EXISTS `category` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `type` TINYINT NOT NULL COMMENT '1=收入, 2=支出',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用 1=是, 0=否（代替硬删除）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收支分类表';

-- 预置一些基础分类
INSERT IGNORE INTO `category` (`id`, `name`, `type`) VALUES 
(1, '工资', 1), (2, '理财收益', 1),
(3, '餐饮', 2), (4, '交通', 2), (5, '购物', 2);

-- 账单流水表
CREATE TABLE IF NOT EXISTS `transaction` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `type` TINYINT NOT NULL COMMENT '1=收入, 2=支出, 3=转账',
  `amount` DECIMAL(18,2) NOT NULL COMMENT '金额，必须为正数',
  `transaction_date` DATE NOT NULL COMMENT '记账纯日期，无时区问题',
  `category_id` BIGINT NULL COMMENT '分类ID（转账无分类）',
  `account_id` BIGINT NOT NULL COMMENT '收/支账户ID（转账时为转出账户）',
  `to_account_id` BIGINT NULL COMMENT '转账时的转入账户ID',
  `remark` VARCHAR(255) NULL COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账单流水表';

-- 攒钱目标表
CREATE TABLE IF NOT EXISTS `target` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL COMMENT '目标名称',
  `target_amount` DECIMAL(18,2) NOT NULL COMMENT '目标金额',
  `allocated_amount` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '已分配金额（存入的钱）',
  `deadline` DATE NULL COMMENT '截止日期',
  `is_realized` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已实现',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='攒钱目标表';

-- 周期快照表 (Cycle Record)
CREATE TABLE IF NOT EXISTS `cycle_record` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `cycle_start_date` DATE NOT NULL COMMENT '周期开始日期',
  `cycle_end_date` DATE NOT NULL COMMENT '周期结束日期',
  `fixed_deposit` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '该周期的固存金额快照',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='周期快照表';

-- 月度预算表 (如果需要按周期单独存，或者只存一个全局通用预算)
-- MVP 中我们可以只存一个全局总月度预算在 User 表，或者单独建立 budget 表记录每个周期的预算
CREATE TABLE IF NOT EXISTS `budget` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `amount` DECIMAL(18,2) NOT NULL COMMENT '预算金额',
  `cycle_start_date` DATE NOT NULL COMMENT '该预算生效周期的开始日期',
  `cycle_end_date` DATE NOT NULL COMMENT '该预算生效周期的结束日期',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='周期预算表';
