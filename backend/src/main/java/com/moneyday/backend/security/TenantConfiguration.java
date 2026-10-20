package com.moneyday.backend.security;

import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.TenantLineInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.handler.TenantLineHandler;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.LongValue;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import java.util.Set;

@Configuration
public class TenantConfiguration {
    private static final Set<String> OWNED = Set.of("account", "category", "transaction", "cycle_template", "cycle_record", "target", "wishlist", "liability", "todo_item");
    @Bean
    public MybatisPlusInterceptor userIsolation() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new TenantLineInnerInterceptor(new TenantLineHandler() {
            public Expression getTenantId() { return new LongValue(UserContext.requireId()); }
            public String getTenantIdColumn() { return "user_id"; }
            public boolean ignoreTable(String table) { return !OWNED.contains(table.replace("`", "").toLowerCase(java.util.Locale.ROOT)); }
        }));
        return interceptor;
    }
}
