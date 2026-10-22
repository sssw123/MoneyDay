package com.moneyday.backend.security;

import com.moneyday.backend.common.ApiException;
import com.moneyday.backend.entity.User;
import com.moneyday.backend.mapper.UserMapper;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionTemplate;

/** Serializes financial changes and snapshot creation per user, including nested service calls. */
@Aspect
@Component
public class BusinessTransactionAspect {
    private final UserMapper users;
    private final TransactionTemplate transactions;
    public BusinessTransactionAspect(UserMapper users, org.springframework.transaction.PlatformTransactionManager manager) {
        this.users = users; this.transactions = new TransactionTemplate(manager);
    }
    @Around("execution(public * com.moneyday.backend.service.impl.*.*(..)) && !within(com.moneyday.backend.service.impl.UserServiceImpl)")
    public Object withinUserTransaction(ProceedingJoinPoint invocation) {
        long id = UserContext.requireId();
        return transactions.execute(status -> {
            User user = users.lockById(id);
            if (user == null || !"ACTIVE".equals(user.getStatus())) throw new ApiException(401, "账户不可用，请重新登录");
            try { return invocation.proceed(); }
            catch (RuntimeException | Error e) { throw e; }
            catch (Throwable e) { throw new IllegalStateException(e); }
        });
    }
}
