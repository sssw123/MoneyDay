package com.moneyday.backend.service;

import com.moneyday.backend.entity.Account;
import com.moneyday.backend.entity.Transaction;
import com.moneyday.backend.mapper.AccountMapper;
import com.moneyday.backend.mapper.TransactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.List;

public interface TransactionService {
    List<Transaction> getAllTransactions();
    Transaction getTransactionById(Long id);
    Transaction addTransaction(Transaction tx);
    Transaction updateTransaction(Transaction tx);
    void deleteTransaction(Long id);
}
