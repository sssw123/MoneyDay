package com.moneyday.backend.security;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.moneyday.backend.common.ApiException;
import com.moneyday.backend.entity.*;
import com.moneyday.backend.mapper.*;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class OwnershipGuard {
    private final AccountMapper accounts;
    private final CategoryMapper categories;
    private final TransactionMapper transactions;
    private final LiabilityMapper liabilities;
    public OwnershipGuard(AccountMapper accounts,CategoryMapper categories,TransactionMapper transactions,LiabilityMapper liabilities) {
        this.accounts=accounts;this.categories=categories;this.transactions=transactions;this.liabilities=liabilities;
    }
    public <T> T require(BaseMapper<T> mapper,Long id) {
        if(id==null) throw ApiException.notFound();
        T record=mapper.selectById(id);
        if(record==null) throw ApiException.notFound();
        return record;
    }
    public void account(Long id) {require(accounts,id);}
    public void category(Long id) {if(id!=null) require(categories,id);}
    public void liability(Long id) {if(id!=null) require(liabilities,id);}
    public void transaction(Transaction tx) {
        account(tx.getAccountId());
        if(tx.getToAccountId()!=null) account(tx.getToAccountId());
        category(tx.getCategoryId());liability(tx.getLiabilityId());
        if(tx.getType()==null || !java.util.Set.of(1,2,3).contains(tx.getType()) || tx.getAmount()==null || tx.getAmount().signum()<=0 || tx.getTransactionDate()==null)
            throw new ApiException(400,"记账类型、日期或金额无效");
        if(tx.getType()==3 && (tx.getToAccountId()==null || tx.getToAccountId().equals(tx.getAccountId()))) throw new ApiException(400,"转入和转出账户必须不同");
    }
    public void fixedItems(List<FixedItem> items) {
        if(items==null)return;
        for(FixedItem item:items) {
            if(item==null) throw new ApiException(400,"固定项目无效");
            category(item.getCategoryId());
            if(item.getTransactionId()!=null) require(transactions,item.getTransactionId());
            if(item.getAmount()==null || item.getAmount().signum()<0 || !java.util.Set.of("INCOME","EXPENSE","DEPOSIT").contains(item.getType()==null?"":item.getType())) throw new ApiException(400,"固定项目类型或金额无效");
            // Template input cannot forge a booked snapshot.
            item.setIsBooked(false); item.setTransactionId(null);
        }
    }
}
