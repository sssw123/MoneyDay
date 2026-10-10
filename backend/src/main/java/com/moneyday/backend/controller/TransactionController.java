package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.Transaction;
import com.moneyday.backend.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {

    @Autowired
    private TransactionService transactionService;

    @GetMapping
    public Result<List<Transaction>> getAll() {
        return Result.success(transactionService.getAllTransactions());
    }

    @PostMapping
    public Result<Transaction> create(@RequestBody Transaction tx) {
        return Result.success(transactionService.addTransaction(tx));
    }

    @PutMapping("/{id}")
    public Result<Transaction> update(@PathVariable Long id, @RequestBody Transaction tx) {
        tx.setId(id);
        return Result.success(transactionService.updateTransaction(tx));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        transactionService.deleteTransaction(id);
        return Result.success(null);
    }
}
