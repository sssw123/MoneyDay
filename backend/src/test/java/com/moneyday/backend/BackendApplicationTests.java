package com.moneyday.backend;

import com.moneyday.backend.common.ApiException;
import com.moneyday.backend.security.TenantConfiguration;
import com.moneyday.backend.security.UserContext;
import com.moneyday.backend.service.impl.UserServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.inner.TenantLineInnerInterceptor;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.List;
import java.util.concurrent.CompletableFuture;

import static org.junit.jupiter.api.Assertions.*;

/** These checks deliberately load no Spring context and cannot access a database. */
class BackendApplicationTests {
    @Test
    void missingUserScopeFailsClosedAndNestedScopesRestoreEvenOnFailure() {
        assertEquals(401, assertThrows(ApiException.class, UserContext::requireId).getStatus());
        UserContext.call(11L, () -> {
            assertEquals(11L, UserContext.requireId());
            assertThrows(IllegalStateException.class, () -> UserContext.call(22L, () -> {
                assertEquals(22L, UserContext.requireId());
                throw new IllegalStateException("test");
            }));
            assertEquals(11L, UserContext.requireId());
            assertEquals(401, CompletableFuture.supplyAsync(() ->
                    assertThrows(ApiException.class, UserContext::requireId).getStatus()).join());
            return null;
        });
        assertThrows(ApiException.class, UserContext::requireId);
    }

    @Test
    void everyOwnedTableRequiresScopeAndRewritesSelectUpdateDeleteInsert() {
        TenantLineInnerInterceptor tenant = (TenantLineInnerInterceptor)
                new TenantConfiguration().userIsolation().getInterceptors().get(0);
        for (String table : List.of("account", "category", "transaction", "cycle_template",
                "cycle_record", "target", "wishlist", "liability", "todo_item")) {
            String select = "SELECT * FROM `" + table + "`";
            assertThrows(ApiException.class, () -> tenant.parserSingle(select, null), table);
            UserContext.call(345L, () -> {
                for (String sql : List.of(select, "UPDATE `" + table + "` SET id = 2 WHERE id = 1",
                        "DELETE FROM `" + table + "` WHERE id = 1")) {
                    String rewritten = tenant.parserSingle(sql, null);
                    assertTrue(rewritten.contains("user_id = 345"), rewritten);
                }
                String insert = tenant.parserSingle("INSERT INTO `" + table + "` (id) VALUES (1)", null);
                assertTrue(insert.contains("user_id"), insert);
                assertTrue(insert.contains("345"), insert);
                return null;
            });
        }
        assertEquals("SELECT * FROM user", tenant.parserSingle("SELECT * FROM user", null));
        assertEquals("SELECT * FROM auth_session", tenant.parserSingle("SELECT * FROM auth_session", null));
    }

    @Test
    void namesNormalizeAndPasswordValidationHonorsUnicodeAndBcryptByteBoundary() {
        assertEquals("user.name-1", UserServiceImpl.normalizeUsername(" USER.Name-1 "));
        for (String name : List.of("ab", "a b", "用户123", "x".repeat(51))) {
            assertEquals(400, assertThrows(ApiException.class,
                    () -> UserServiceImpl.normalizeUsername(name)).getStatus());
        }
        assertThrows(ApiException.class, () -> UserServiceImpl.normalizeUsername(null));
        for (String password : List.of("1234567", "x".repeat(73), "密".repeat(25), "😀".repeat(7))) {
            assertThrows(ApiException.class, () -> UserServiceImpl.validatePassword(password));
        }
        assertThrows(ApiException.class, () -> UserServiceImpl.validatePassword(null));
        assertDoesNotThrow(() -> UserServiceImpl.validatePassword("x".repeat(72)));
        assertDoesNotThrow(() -> UserServiceImpl.validatePassword("密".repeat(24)));
        assertDoesNotThrow(() -> UserServiceImpl.validatePassword("😀".repeat(8)));
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String hash = encoder.encode("八个字符测试密码");
        assertNotEquals("八个字符测试密码", hash);
        assertTrue(encoder.matches("八个字符测试密码", hash));
        assertFalse(encoder.matches("another-password", hash));
    }

    @Test
    void sessionTokenHashHasStableSha256Representation() {
        assertEquals("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", UserServiceImpl.hashToken("abc"));
        assertNotEquals(UserServiceImpl.hashToken("abc"), UserServiceImpl.hashToken("abd"));
        assertEquals(64, UserServiceImpl.hashToken("token").length());
    }
}
