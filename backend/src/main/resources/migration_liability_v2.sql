-- 升级分期表，增加下一次应还日期字段
ALTER TABLE `liability`
ADD COLUMN `next_repayment_date` DATE NULL COMMENT '下一次应还日期' AFTER `repayment_day`;
