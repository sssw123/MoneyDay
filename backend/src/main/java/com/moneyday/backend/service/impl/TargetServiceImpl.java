package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.TargetService;

import com.moneyday.backend.entity.Target;
import com.moneyday.backend.mapper.TargetMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TargetServiceImpl implements TargetService {

    @Autowired
    private TargetMapper targetMapper;

    public List<Target> getAllTargets() {
        return targetMapper.selectList(null);
    }

    public Target addTarget(Target target) {
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

    @org.springframework.transaction.annotation.Transactional
    public void realizeTarget(Long id, Long accountId) {
        Target target = targetMapper.selectById(id);
        if (target == null || (target.getIsRealized() != null && target.getIsRealized() == 1)) {
            throw new RuntimeException("目标不存在或已实现");
        }
        target.setIsRealized(1);
        targetMapper.updateById(target);

        com.moneyday.backend.entity.Transaction t = new com.moneyday.backend.entity.Transaction();
        t.setType(2); // 支出
        t.setAmount(target.getTargetAmount());
        t.setTransactionDate(java.time.LocalDate.now());
        t.setAccountId(accountId);
        t.setRemark("实现目标：" + target.getName());
        transactionService.addTransaction(t);
    }
}
