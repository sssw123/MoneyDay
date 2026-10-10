package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.Account;
import com.moneyday.backend.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    @Autowired
    private AccountService accountService;

    @GetMapping
    public Result<List<Account>> getAll() {
        return Result.success(accountService.getAllAccounts());
    }

    @PostMapping
    public Result<Account> create(@RequestBody Account account) {
        return Result.success(accountService.addAccount(account));
    }

    @PutMapping("/{id}")
    public Result<Account> update(@PathVariable Long id, @RequestBody Account account) {
        account.setId(id);
        return Result.success(accountService.updateAccount(account));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        accountService.deleteAccount(id);
        return Result.success(null);
    }
}
