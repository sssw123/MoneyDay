package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.TargetService;

import com.moneyday.backend.entity.Target;
import com.moneyday.backend.mapper.TargetMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class TargetServiceImpl implements TargetService {

    @Autowired
    private TargetMapper targetMapper;

    @Autowired
    private com.moneyday.backend.service.CycleRecordService cycleRecordService;

    public List<Target> getAllTargets() {
        return targetMapper.selectList(null);
    }

    public Target addTarget(Target target) {
        if (target.getStartDate() == null) {
            target.setStartDate(java.time.LocalDate.now());
        }
        targetMapper.insert(target);
        return target;
    }

    public Target updateTarget(Target target) {
        targetMapper.updateById(target);
        return target;
    }

    public void deleteTarget(Long id) {
        targetMapper.deleteById(id);
    }

    @Autowired
    private com.moneyday.backend.service.TransactionService transactionService;

    @Autowired
    private com.moneyday.backend.mapper.CategoryMapper categoryMapper;

    @org.springframework.transaction.annotation.Transactional
    public void realizeTarget(Long id, Long accountId) {
        Target target = targetMapper.selectById(id);
        if (target == null || (target.getIsRealized() != null && target.getIsRealized() == 1)) {
            throw new RuntimeException("目标不存在或已实现");
        }

        BigDecimal cumulativeBalance = cycleRecordService.getTotalCumulativeBalance();
        if (cumulativeBalance.compareTo(target.getTargetAmount()) < 0) {
            throw new IllegalArgumentException("累计结余不足，严禁实现！当前累计结余: ¥" + cumulativeBalance + "，目标需: ¥" + target.getTargetAmount());
        }

        target.setIsRealized(1);
        targetMapper.updateById(target);

        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.moneyday.backend.entity.Category> catQuery = 
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        catQuery.eq("name", "目标").eq("type", 2).last("LIMIT 1");
        com.moneyday.backend.entity.Category targetCategory = categoryMapper.selectOne(catQuery);

        com.moneyday.backend.entity.Transaction t = new com.moneyday.backend.entity.Transaction();
        t.setType(2); // 支出
        t.setAmount(target.getTargetAmount());
        t.setTransactionDate(java.time.LocalDate.now());
        t.setAccountId(accountId);
        if (targetCategory != null) {
            t.setCategoryId(targetCategory.getId());
        }
        t.setRemark("实现目标：" + target.getName());
        transactionService.addTransaction(t);
    }
}
