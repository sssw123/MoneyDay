-- 1. 创建心愿单表
CREATE TABLE IF NOT EXISTS `wishlist` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT '心愿名称',
    `target_amount` DECIMAL(18, 2) NOT NULL COMMENT '心愿金额',
    `deadline` DATE NULL COMMENT '期望日期',
    `start_date` DATE NOT NULL COMMENT '立项时间',
    `is_realized` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0: 心愿中, 1: 已实现',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 将原有 target 表中的心愿单数据迁移至 wishlist
INSERT INTO `wishlist` (`name`, `target_amount`, `deadline`, `start_date`, `is_realized`, `created_at`, `updated_at`)
SELECT `name`, `target_amount`, `deadline`, `start_date`, `is_realized`, `created_at`, `updated_at`
FROM `target`
WHERE `type` = 'WISHLIST';

DELETE FROM `target` WHERE `type` = 'WISHLIST';

-- 3. 创建透支分期表
CREATE TABLE IF NOT EXISTS `liability` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT '分期/负债名称',
    `principal` DECIMAL(18, 2) NOT NULL COMMENT '分期本金',
    `total_amount` DECIMAL(18, 2) NOT NULL COMMENT '总待还本息总额',
    `total_periods` INT NOT NULL COMMENT '总期数',
    `current_period` INT NOT NULL DEFAULT 0 COMMENT '已还期数',
    `period_amount` DECIMAL(18, 2) NOT NULL COMMENT '每期应还金额',
    `rate_type` VARCHAR(20) NOT NULL DEFAULT 'NONE' COMMENT 'NONE: 免息, FEE: 每期手续费率, APR: 年化等额本息',
    `interest_rate` DECIMAL(8, 4) NOT NULL DEFAULT 0.0000 COMMENT '利率/费率百分比',
    `repayment_day` INT NOT NULL COMMENT '每月还款日 (1-31)',
    `default_account_id` BIGINT NOT NULL COMMENT '默认扣款账户',
    `category_id` BIGINT NOT NULL COMMENT '支出记账分类ID',
    `auto_cycle_fixed_expense` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1: 自动纳入周期固定支出, 0: 否',
    `status` VARCHAR(20) NOT NULL DEFAULT 'REPAYING' COMMENT 'REPAYING: 还款中, SETTLED: 已结清',
    `start_date` DATE NOT NULL COMMENT '首期起算日期',
    `settled_at` DATETIME NULL COMMENT '提前结清时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. 流水表新增 liability_id
SET @dbname = DATABASE();
SET @tablename = "transaction";
SET @columnname = "liability_id";
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE `transaction` ADD COLUMN `liability_id` BIGINT NULL COMMENT '关联的负债ID';"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 5. 确保默认支出分类【分期还款】存在
INSERT INTO `category` (`name`, `type`, `is_active`, `created_at`, `updated_at`)
SELECT '分期还款', 2, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM `category` WHERE `name` = '分期还款' AND `type` = 2);
