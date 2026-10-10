package com.moneyday.backend.service;

import com.moneyday.backend.entity.Account;
import com.moneyday.backend.mapper.AccountMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

public interface AccountService {
    List<Account> getAllAccounts();
    Account getAccountById(Long id);
    Account addAccount(Account account);
    Account updateAccount(Account account);
    void deleteAccount(Long id);
}
