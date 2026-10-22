package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.TransactionService;

import com.moneyday.backend.entity.Account;
import com.moneyday.backend.entity.Transaction;
import com.moneyday.backend.mapper.AccountMapper;
import com.moneyday.backend.mapper.TransactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class TransactionServiceImpl implements TransactionService {
    @Autowired private com.moneyday.backend.security.OwnershipGuard guard;


    @Autowired
    private TransactionMapper transactionMapper;
    @Autowired
    private AccountMapper accountMapper;

    public List<Transaction> getAllTransactions() {
        return transactionMapper.selectList(null);
    }

    public Transaction getTransactionById(Long id) {
        return guard.require(transactionMapper,id);
    }

    @Transactional
    public Transaction addTransaction(Transaction tx) {
        guard.transaction(tx);
        tx.setId(null);
        // 1. insert
        transactionMapper.insert(tx);
        // 2. update account balance
        applyTransactionToAccount(tx, false);
        return tx;
    }

    @Transactional
    public Transaction updateTransaction(Transaction tx) {
        Transaction oldTx = guard.require(transactionMapper,tx.getId());
        guard.transaction(tx);
        if (oldTx == null) throw new IllegalArgumentException("Transaction not found");

        // 1. revert old
        applyTransactionToAccount(oldTx, true);
        
        // 2. update
        transactionMapper.updateById(tx);
        
        // 3. apply new
        applyTransactionToAccount(tx, false);
        return tx;
    }

    @Autowired
    private com.moneyday.backend.mapper.CycleRecordMapper cycleRecordMapper;

    @Transactional
    public void deleteTransaction(Long id) {
        Transaction oldTx = guard.require(transactionMapper,id);
        if (oldTx != null) {
            applyTransactionToAccount(oldTx, true);
            transactionMapper.deleteById(id);

            // 联动重置关联的周期固定项目状态
            List<com.moneyday.backend.entity.CycleRecord> records = cycleRecordMapper.selectList(null);
            for (com.moneyday.backend.entity.CycleRecord record : records) {
                if (record.getFixedItems() != null) {
                    boolean modified = false;
                    for (com.moneyday.backend.entity.FixedItem item : record.getFixedItems()) {
                        if (id.equals(item.getTransactionId())) {
                            item.setIsBooked(false);
                            item.setTransactionId(null);
                            modified = true;
                        }
                    }
                    if (modified) {
                        cycleRecordMapper.updateById(record);
                    }
                }
            }
        }
    }

    private void applyTransactionToAccount(Transaction tx, boolean isRevert) {
        BigDecimal amount = tx.getAmount();
        if (isRevert) {
            amount = amount.negate();
        }

        // 1=鏀跺叆, 2=鏀嚭, 3=杞处
        if (tx.getType() == 1) {
            updateBalance(tx.getAccountId(), amount);
        } else if (tx.getType() == 2) {
            updateBalance(tx.getAccountId(), amount.negate());
        } else if (tx.getType() == 3) {
            updateBalance(tx.getAccountId(), amount.negate());
            if (tx.getToAccountId() != null) {
                updateBalance(tx.getToAccountId(), amount);
            }
        }
    }

    private void updateBalance(Long accountId, BigDecimal delta) {
        Account acc = guard.require(accountMapper,accountId);
        if (acc == null) throw new IllegalArgumentException("Account not found: " + accountId);
        acc.setCurrentBalance(acc.getCurrentBalance().add(delta));
        accountMapper.updateById(acc);
    }
}
