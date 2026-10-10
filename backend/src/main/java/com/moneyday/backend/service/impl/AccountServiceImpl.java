package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.AccountService;

import com.moneyday.backend.entity.Account;
import com.moneyday.backend.mapper.AccountMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AccountServiceImpl implements AccountService {

    @Autowired
    private AccountMapper accountMapper;

    public List<Account> getAllAccounts() {
        return accountMapper.selectList(null);
    }

    public Account getAccountById(Long id) {
        return accountMapper.selectById(id);
    }

    public Account addAccount(Account account) {
        if (account.getInitialBalance() != null) {
            account.setCurrentBalance(account.getInitialBalance());
        }
        accountMapper.insert(account);
        return account;
    }

    public Account updateAccount(Account account) {
        accountMapper.updateById(account);
        return account;
    }

    public void deleteAccount(Long id) {
        accountMapper.deleteById(id);
    }
}
