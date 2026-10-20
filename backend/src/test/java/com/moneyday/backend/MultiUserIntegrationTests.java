package com.moneyday.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.moneyday.backend.security.UserContext;
import com.moneyday.backend.service.ScheduleTaskService;
import com.moneyday.backend.service.TodoService;
import com.moneyday.backend.service.impl.UserServiceImpl;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.math.BigDecimal;
import java.net.URI;
import java.time.LocalDate;
import java.util.*;
import java.util.concurrent.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Real HTTP/MySQL tests. Never uses application-local.yml credentials and never initializes a schema.
 * Initialize an empty dedicated moneyday_test* schema before explicitly opting in with all env vars.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {"spring.profiles.active=integration-test", "spring.sql.init.mode=never"})
@EnabledIfEnvironmentVariable(named = "MONEYDAY_TEST_DB_URL", matches = "jdbc:mysql:.*")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class MultiUserIntegrationTests {
    private static final String INITIAL = "TestInitial-2026!";
    private static final String CHANGED = "TestChanged-2026!";
    private static final String RESET = "TestReset-2026!";
    private static final String ADMIN_CHANGED = "IntegrationAdmin-2026!";
    @Autowired TestRestTemplate http;
    @Autowired JdbcTemplate jdbc;
    @Autowired ScheduleTaskService scheduler;
    @Autowired TodoService todos;
    private String admin;
    private long adminId;
    private final List<Long> createdUsers = new ArrayList<>();

    @DynamicPropertySource
    static void database(DynamicPropertyRegistry properties) {
        String url = Objects.requireNonNull(System.getenv("MONEYDAY_TEST_DB_URL"));
        String database = URI.create(url.substring("jdbc:".length())).getPath();
        if (database == null || !database.matches("/moneyday_test[A-Za-z0-9_]*")) {
            throw new IllegalStateException("Integration tests require a dedicated moneyday_test* schema");
        }
        properties.add("spring.datasource.url", () -> url);
        properties.add("spring.datasource.username", () -> required("MONEYDAY_TEST_DB_USERNAME"));
        properties.add("spring.datasource.password", () -> required("MONEYDAY_TEST_DB_PASSWORD"));
    }
    private static String required(String key) {
        return Objects.requireNonNull(System.getenv(key), key + " must be explicitly set");
    }

    @BeforeAll
    void authenticateAdministrator() {
        // The JDK URLConnection factory retries streamed POST bodies on 401 and hides the response.
        http.getRestTemplate().setRequestFactory(new org.springframework.http.client.JdkClientHttpRequestFactory());
        ResponseEntity<JsonNode> response = request(null, HttpMethod.POST, "/api/user/login",
                Map.of("username", "ADMIN", "password", required("MONEYDAY_ADMIN_PASSWORD")));
        if (response.getStatusCode().value() != 200) {
            response = request(null, HttpMethod.POST, "/api/user/login",
                    Map.of("username", "admin", "password", ADMIN_CHANGED));
        }
        JsonNode login = success(response);
        admin = login.path("token").asText();
        adminId = login.path("user").path("id").asLong();
        if (login.path("user").path("mustChangePassword").asBoolean()) {
            ok(admin, HttpMethod.PUT, "/api/user/password", Map.of(
                    "oldPassword", required("MONEYDAY_ADMIN_PASSWORD"), "newPassword", ADMIN_CHANGED));
            admin = login("admin", ADMIN_CHANGED);
        }
    }

    @AfterEach
    void removeOnlyFixturesCreatedByThisTest() {
        // Direct JDBC cleanup is intentionally scoped to IDs recorded from this test's create responses.
        for (long id : createdUsers) {
            for (String table : List.of("transaction", "todo_item", "cycle_record", "cycle_template",
                    "liability", "wishlist", "target", "account", "category", "auth_session")) {
                jdbc.update("DELETE FROM `" + table + "` WHERE user_id=?", id);
            }
            jdbc.update("DELETE FROM `user` WHERE id=?", id);
        }
        createdUsers.clear();
    }

    @Test
    void corsAllowsNativeAndWebOriginsButRejectsUntrustedOrigins() {
        for (String origin : List.of("https://localhost", "http://127.0.0.1:5173", "https://untrusted.invalid")) {
            HttpHeaders headers = new HttpHeaders();
            headers.setOrigin(origin);
            headers.setAccessControlRequestMethod(HttpMethod.GET);
            headers.setAccessControlRequestHeaders(List.of("authorization"));
            ResponseEntity<String> response = http.exchange("/api/accounts", HttpMethod.OPTIONS, new HttpEntity<>(headers), String.class);
            if (origin.contains("untrusted")) {
                assertEquals(403, response.getStatusCode().value());
                assertNull(response.getHeaders().getAccessControlAllowOrigin());
            } else {
                assertEquals(200, response.getStatusCode().value());
                assertEquals(origin, response.getHeaders().getAccessControlAllowOrigin());
            }
        }
    }

    @Test
    void anonymousRequestsFailAndOnlyAdministratorManagesUsers() {
        for (String route : List.of("/api/accounts", "/api/categories", "/api/stats", "/api/transactions",
                "/api/cycle-templates", "/api/cycles", "/api/targets", "/api/wishlists", "/api/liabilities", "/api/todos")) {
            expect(401, null, HttpMethod.GET, route, null);
            expect(401, "invalid-token", HttpMethod.GET, route, null);
        }
        Person user = person();
        expect(403, user.token, HttpMethod.GET, "/api/admin/users", null);
        expect(403, user.token, HttpMethod.POST, "/api/admin/users", Map.of("username", unique(), "password", INITIAL));
        expect(404, admin, HttpMethod.DELETE, "/api/admin/users/" + adminId, null);
        expect(404, admin, HttpMethod.PUT, "/api/admin/users/" + adminId + "/status", Map.of("status", "DISABLED"));
        expect(404, admin, HttpMethod.POST, "/api/admin/users/" + adminId + "/reset-password", Map.of("password", RESET));
        expect(404, user.token, HttpMethod.POST, "/api/user/register", Map.of("username", unique(), "password", INITIAL));
        String username = user.name;
        expect(409, admin, HttpMethod.POST, "/api/admin/users", Map.of("username", username.toUpperCase(Locale.ROOT), "password", INITIAL));
        expect(400, admin, HttpMethod.POST, "/api/admin/users", Map.of("username", unique(), "password", "short"));
        expect(400, admin, HttpMethod.POST, "/api/admin/users", Map.of("username", unique(), "password", "密".repeat(25)));
        JsonNode list = ok(admin, HttpMethod.GET, "/api/admin/users?keyword=" + username + "&status=ACTIVE&page=1&pageSize=10", null);
        assertEquals(1, list.path("total").asInt());
        assertEquals(user.id, list.path("records").get(0).path("id").asLong());
        assertFalse(list.toString().contains("password"));
        expect(400, admin, HttpMethod.GET, "/api/admin/users?page=0", null);
    }

    @Test
    void firstLoginRequiresPasswordChangeAndPersistsOnlyBcryptAndTokenHash() {
        Person user = create();
        JsonNode session = ok(null, HttpMethod.POST, "/api/user/login", Map.of("username", user.name.toUpperCase(Locale.ROOT), "password", INITIAL));
        String token = session.path("token").asText();
        assertTrue(session.path("user").path("mustChangePassword").asBoolean());
        assertFalse(session.toString().contains("password"));
        assertTrue(token.length() >= 40);
        String hash = jdbc.queryForObject("SELECT password FROM `user` WHERE id=?", String.class, user.id);
        assertNotNull(hash);
        assertTrue(hash.startsWith("$2"));
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM auth_session WHERE id=? AND user_id=?", Integer.class,
                UserServiceImpl.hashToken(token), user.id));
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM auth_session WHERE id=?", Integer.class, token));
        assertTrue(jdbc.queryForObject("SELECT TIMESTAMPDIFF(MINUTE,NOW(),expires_at) FROM auth_session WHERE id=?", Integer.class, UserServiceImpl.hashToken(token)) >= 10079);
        assertTrue(ok(token, HttpMethod.GET, "/api/user/profile", null).path("mustChangePassword").asBoolean());
        expect(403, token, HttpMethod.GET, "/api/accounts", null);
        expect(403, token, HttpMethod.GET, "/api/admin/users", null);
        expect(400, token, HttpMethod.PUT, "/api/user/password", Map.of("oldPassword", "incorrect", "newPassword", CHANGED));
        expect(400, token, HttpMethod.PUT, "/api/user/password", Map.of("oldPassword", INITIAL, "newPassword", INITIAL));
        ok(token, HttpMethod.PUT, "/api/user/password", Map.of("oldPassword", INITIAL, "newPassword", CHANGED));
        expect(401, token, HttpMethod.GET, "/api/user/profile", null);
        String normal = login(user.name, CHANGED);
        assertFalse(ok(normal, HttpMethod.GET, "/api/user/profile", null).path("mustChangePassword").asBoolean());
        ok(normal, HttpMethod.GET, "/api/accounts", null);
    }

    @Test
    void logoutExpiryPasswordResetDisableAndDeleteRevokeCorrectSessions() {
        Person user = person();
        String mobile = login(user.name, CHANGED);
        ok(user.token, HttpMethod.POST, "/api/user/logout", null);
        expect(401, user.token, HttpMethod.GET, "/api/user/profile", null);
        ok(mobile, HttpMethod.GET, "/api/user/profile", null);
        jdbc.update("UPDATE auth_session SET expires_at=DATE_SUB(NOW(),INTERVAL 1 SECOND) WHERE id=?", UserServiceImpl.hashToken(mobile));
        expect(401, mobile, HttpMethod.GET, "/api/user/profile", null);
        String web = login(user.name, CHANGED);
        mobile = login(user.name, CHANGED);
        ok(admin, HttpMethod.POST, "/api/admin/users/" + user.id + "/reset-password", Map.of("password", RESET));
        expect(401, web, HttpMethod.GET, "/api/user/profile", null);
        expect(401, mobile, HttpMethod.GET, "/api/user/profile", null);
        expect(401, null, HttpMethod.POST, "/api/user/login", Map.of("username", user.name, "password", CHANGED));
        web = login(user.name, RESET);
        mobile = login(user.name, RESET);
        expect(403, web, HttpMethod.GET, "/api/accounts", null);
        ok(web, HttpMethod.PUT, "/api/user/password", Map.of("oldPassword", RESET, "newPassword", CHANGED));
        expect(401, mobile, HttpMethod.GET, "/api/user/profile", null);
        web = login(user.name, CHANGED);
        mobile = login(user.name, CHANGED);
        ok(admin, HttpMethod.PUT, "/api/admin/users/" + user.id + "/status", Map.of("status", "DISABLED"));
        expect(401, web, HttpMethod.GET, "/api/user/profile", null);
        expect(401, mobile, HttpMethod.GET, "/api/user/profile", null);
        expect(401, null, HttpMethod.POST, "/api/user/login", Map.of("username", user.name, "password", CHANGED));
        ok(admin, HttpMethod.PUT, "/api/admin/users/" + user.id + "/status", Map.of("status", "ACTIVE"));
        expect(401, web, HttpMethod.GET, "/api/user/profile", null);
        web = login(user.name, CHANGED);
        mobile = login(user.name, CHANGED);
        long account = account(web, "retained", 100);
        ok(admin, HttpMethod.DELETE, "/api/admin/users/" + user.id, null);
        expect(401, web, HttpMethod.GET, "/api/user/profile", null);
        expect(401, mobile, HttpMethod.GET, "/api/user/profile", null);
        expect(401, null, HttpMethod.POST, "/api/user/login", Map.of("username", user.name, "password", CHANGED));
        expect(404, admin, HttpMethod.PUT, "/api/admin/users/" + user.id + "/status", Map.of("status", "ACTIVE"));
        expect(409, admin, HttpMethod.POST, "/api/admin/users", Map.of("username", user.name, "password", INITIAL));
        assertEquals("DELETED", jdbc.queryForObject("SELECT status FROM `user` WHERE id=?", String.class, user.id));
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM account WHERE id=? AND user_id=?", Integer.class, account, user.id));
        assertEquals(0, ok(admin, HttpMethod.GET, "/api/admin/users?keyword=" + user.name, null).path("total").asInt());
    }

    @Test
    void allBusinessListsAndWritesRejectOtherUserIdsWithoutChangingMoney() {
        Person a = person(), b = person();
        long account = account(a.token, "only A", 1000);
        long category = ok(a.token, HttpMethod.POST, "/api/categories", Map.of("name", "only A category", "type", 2, "isActive", 1)).path("id").asLong();
        long tx = ok(a.token, HttpMethod.POST, "/api/transactions", tx(account, category, 20)).path("id").asLong();
        long target = ok(a.token, HttpMethod.POST, "/api/targets", goal("only A target")).path("id").asLong();
        long wish = ok(a.token, HttpMethod.POST, "/api/wishlists", goal("only A wish")).path("id").asLong();
        long liability = liability(a, account, category, false, LocalDate.now().plusMonths(1));
        long template = ok(a.token, HttpMethod.POST, "/api/cycle-templates", template("only A template", category)).path("id").asLong();
        long cycle = ok(a.token, HttpMethod.GET, "/api/cycles", null).get(0).path("id").asLong();
        UserContext.call(a.id, () -> { todos.createTodoIfNotExists("LIABILITY_OVERDUE", "only A todo", "test", String.valueOf(liability)); return null; });
        long todo = jdbc.queryForObject("SELECT id FROM todo_item WHERE user_id=? AND biz_id=?", Long.class, a.id, String.valueOf(liability));
        Map<String, Long> ids = Map.of("accounts", account, "categories", category, "transactions", tx,
                "targets", target, "wishlists", wish, "liabilities", liability, "cycle-templates", template);
        BigDecimal before = balance(account);
        for (String other : List.of(b.token, admin)) {
            for (var resource : ids.entrySet()) {
                JsonNode list = ok(other, HttpMethod.GET, "/api/" + resource.getKey(), null);
                for (JsonNode row : list) assertNotEquals(resource.getValue().longValue(), row.path("id").asLong(), resource.getKey());
                expect(404, other, HttpMethod.PUT, "/api/" + resource.getKey() + "/" + resource.getValue(), Map.of("name", "tamper"));
                expect(404, other, HttpMethod.DELETE, "/api/" + resource.getKey() + "/" + resource.getValue(), null);
            }
            for (String resource : List.of("targets/" + target, "wishlists/" + wish)) {
                expect(404, other, HttpMethod.POST, "/api/" + resource + "/realize", Map.of("accountId", account));
                expect(404, other, HttpMethod.POST, "/api/" + resource + "/unrealize", null);
            }
            expect(404, other, HttpMethod.POST, "/api/cycle-templates/" + template + "/default", null);
            expect(404, other, HttpMethod.PUT, "/api/cycles/" + cycle + "/fixed-deposit", Map.of("fixedDeposit", 5));
            expect(404, other, HttpMethod.POST, "/api/cycles/" + cycle + "/book-item/fake", Map.of("accountId", account, "amount", 5, "date", today()));
            expect(404, other, HttpMethod.POST, "/api/cycles/" + cycle + "/unbook-item/fake", null);
            expect(404, other, HttpMethod.POST, "/api/liabilities/" + liability + "/repay", Map.of("accountId", account, "amount", 10, "periods", 1));
            expect(404, other, HttpMethod.POST, "/api/liabilities/" + liability + "/settle", Map.of("accountId", account, "settleAmount", 10));
            for (String action : List.of("dismiss", "resolve", "retry-repay")) {
                expect(404, other, HttpMethod.POST, "/api/todos/" + todo + "/" + action, Map.of("accountId", account));
            }
            for (JsonNode row : ok(other, HttpMethod.GET, "/api/todos", null)) assertNotEquals(todo, row.path("id").asLong());
            for (JsonNode row : ok(other, HttpMethod.GET, "/api/cycles", null)) assertNotEquals(cycle, row.path("id").asLong());
            assertEquals(0, ok(other, HttpMethod.GET, "/api/stats", null).path("totalAssets").decimalValue().signum());
        }
        assertEquals(0, before.compareTo(balance(account)));
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM `transaction` WHERE user_id=?", Integer.class, a.id));
    }

    @Test
    void associationsAndJsonReferencesAreCheckedBeforeAnyWrite() {
        Person a = person(), b = person();
        long own = account(a.token, "own", 1000), foreign = account(b.token, "foreign", 1000);
        long ownCategory = category(a), foreignCategory = category(b);
        long foreignLiability = liability(b, foreign, foreignCategory, false, LocalDate.now().plusMonths(1));
        long foreignTx = ok(b.token, HttpMethod.POST, "/api/transactions", tx(foreign, foreignCategory, 5)).path("id").asLong();
        Map<String, Object> ordinary = tx(own, ownCategory, 10);
        Map<String, Object> transfer = new HashMap<>(ordinary);
        transfer.put("type", 3); transfer.put("toAccountId", foreign);
        expect(404, a.token, HttpMethod.POST, "/api/transactions", transfer);
        for (Map<String, Object> attack : List.of(with(ordinary, "accountId", foreign), with(ordinary, "categoryId", foreignCategory), with(ordinary, "liabilityId", foreignLiability))) {
            expect(404, a.token, HttpMethod.POST, "/api/transactions", attack);
        }
        long ownTx = ok(a.token, HttpMethod.POST, "/api/transactions", ordinary).path("id").asLong();
        expect(404, a.token, HttpMethod.PUT, "/api/transactions/" + ownTx, with(ordinary, "accountId", foreign));
        expect(404, a.token, HttpMethod.POST, "/api/cycle-templates", template("forged category", foreignCategory));
        Map<String, Object> forgedItem = Map.of("name", "forged tx", "type", "EXPENSE", "amount", 5, "categoryId", ownCategory, "transactionId", foreignTx);
        expect(404, a.token, HttpMethod.POST, "/api/cycle-templates", Map.of("name", "forged tx", "startDay", 1, "fixedItems", List.of(forgedItem)));
        Map<String, Object> liability = liabilityBody(own, ownCategory, false, LocalDate.now().plusMonths(1));
        expect(404, a.token, HttpMethod.POST, "/api/liabilities", with(liability, "defaultAccountId", foreign));
        expect(404, a.token, HttpMethod.POST, "/api/liabilities", with(liability, "categoryId", foreignCategory));
        long ownLiability = ok(a.token, HttpMethod.POST, "/api/liabilities", liability).path("id").asLong();
        expect(404, a.token, HttpMethod.PUT, "/api/liabilities/" + ownLiability, with(liability, "defaultAccountId", foreign));
        expect(404, a.token, HttpMethod.POST, "/api/liabilities/" + ownLiability + "/repay", Map.of("accountId", foreign, "amount", 10));
        expect(404, a.token, HttpMethod.POST, "/api/liabilities/" + ownLiability + "/settle", Map.of("accountId", foreign, "settleAmount", 10));
        for (String route : List.of("targets", "wishlists")) {
            long id = ok(a.token, HttpMethod.POST, "/api/" + route, goal("own " + route)).path("id").asLong();
            expect(404, a.token, HttpMethod.POST, "/api/" + route + "/" + id + "/realize", Map.of("accountId", foreign));
            assertEquals(0, jdbc.queryForObject("SELECT is_realized FROM " + (route.equals("targets") ? "target" : "wishlist") + " WHERE id=?", Integer.class, id));
        }
        long template = ok(a.token, HttpMethod.POST, "/api/cycle-templates", with(template("own fixed", ownCategory), "isDefault", 1)).path("id").asLong();
        assertTrue(template > 0);
        JsonNode cycle = ok(a.token, HttpMethod.GET, "/api/cycles", null).get(0);
        long cycleId = cycle.path("id").asLong();
        String itemId = cycle.path("fixedItems").get(0).path("id").asText();
        expect(404, a.token, HttpMethod.POST, "/api/cycles/" + cycleId + "/book-item/" + itemId,
                Map.of("accountId", foreign, "amount", 10, "date", today()));
        assertEquals(0, balance(own).compareTo(new BigDecimal("990")));
        assertEquals(0, balance(foreign).compareTo(new BigDecimal("995")));
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM `transaction` WHERE user_id=?", Integer.class, a.id));
        // Client-supplied ownership is ignored even on otherwise valid inserts.
        long forgedOwner = ok(a.token, HttpMethod.POST, "/api/accounts", Map.of("name", "forged owner", "type", "BANK", "initialBalance", 1, "userId", b.id)).path("id").asLong();
        assertEquals(a.id, jdbc.queryForObject("SELECT user_id FROM account WHERE id=?", Long.class, forgedOwner));
    }

    @Test
    void defaultTemplatesSnapshotsAndCustomSqlAggregatesStayPerUser() {
        Person a = person(), b = person();
        assertEquals(1, ok(a.token, HttpMethod.GET, "/api/cycle-templates", null).size());
        assertTrue(ok(a.token, HttpMethod.GET, "/api/categories", null).size() > 0);
        assertEquals(0, ok(a.token, HttpMethod.GET, "/api/accounts", null).size());
        assertEquals(0, ok(a.token, HttpMethod.GET, "/api/transactions", null).size());
        long bDefault = defaultTemplate(b.id);
        long aTemplate = ok(a.token, HttpMethod.POST, "/api/cycle-templates", template("new default", category(a))).path("id").asLong();
        ok(a.token, HttpMethod.POST, "/api/cycle-templates/" + aTemplate + "/default", null);
        assertEquals(aTemplate, defaultTemplate(a.id));
        assertEquals(bDefault, defaultTemplate(b.id));
        long aa = account(a.token, "A", 1000), ba = account(b.token, "B", 50);
        ok(a.token, HttpMethod.POST, "/api/transactions", tx(aa, category(a), 30));
        ok(b.token, HttpMethod.POST, "/api/transactions", tx(ba, category(b), 5));
        assertEquals(0, ok(a.token, HttpMethod.GET, "/api/stats", null).path("totalAssets").decimalValue().compareTo(new BigDecimal("970")));
        assertEquals(0, ok(b.token, HttpMethod.GET, "/api/stats", null).path("totalAssets").decimalValue().compareTo(new BigDecimal("45")));
        assertEquals(0, ok(a.token, HttpMethod.GET, "/api/stats", null).path("currentExpense").decimalValue().compareTo(new BigDecimal("30")));
        assertEquals(0, ok(b.token, HttpMethod.GET, "/api/stats", null).path("currentExpense").decimalValue().compareTo(new BigDecimal("5")));
        long aCycle = ok(a.token, HttpMethod.GET, "/api/cycles", null).get(0).path("id").asLong();
        long bCycle = ok(b.token, HttpMethod.GET, "/api/cycles", null).get(0).path("id").asLong();
        assertNotEquals(aCycle, bCycle);
        assertEquals(a.id, jdbc.queryForObject("SELECT user_id FROM cycle_record WHERE id=?", Long.class, aCycle));
        assertEquals(b.id, jdbc.queryForObject("SELECT user_id FROM cycle_record WHERE id=?", Long.class, bCycle));
    }

    @Test
    void schedulerSkipsDisabledDeletedUsersAndNeverUsesOtherUsersFallbackAccount() {
        Person active = person(), disabled = person(), deleted = person();
        long activeAccount = account(active.token, "poor", 0);
        long disabledAccount = account(disabled.token, "disabled rich", 1000);
        long deletedAccount = account(deleted.token, "deleted rich", 1000);
        long activeLiability = liability(active, activeAccount, category(active), true, LocalDate.now());
        long disabledLiability = liability(disabled, disabledAccount, category(disabled), true, LocalDate.now());
        long deletedLiability = liability(deleted, deletedAccount, category(deleted), true, LocalDate.now());
        ok(admin, HttpMethod.PUT, "/api/admin/users/" + disabled.id + "/status", Map.of("status", "DISABLED"));
        ok(admin, HttpMethod.DELETE, "/api/admin/users/" + deleted.id, null);
        scheduler.executeAllChecks();
        scheduler.executeAllChecks();
        for (long id : List.of(activeLiability, disabledLiability, deletedLiability)) {
            assertEquals(0, jdbc.queryForObject("SELECT current_period FROM liability WHERE id=?", Integer.class, id));
        }
        assertEquals(0, balance(disabledAccount).compareTo(new BigDecimal("1000")));
        assertEquals(0, balance(deletedAccount).compareTo(new BigDecimal("1000")));
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM todo_item WHERE user_id=? AND type='LIABILITY_OVERDUE' AND biz_id=?", Integer.class, active.id, String.valueOf(activeLiability)));
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM cycle_record WHERE user_id=?", Integer.class, disabled.id));
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM cycle_record WHERE user_id=?", Integer.class, deleted.id));
        assertThrows(com.moneyday.backend.common.ApiException.class, UserContext::requireId);
        ok(admin, HttpMethod.PUT, "/api/admin/users/" + disabled.id + "/status", Map.of("status", "ACTIVE"));
        scheduler.executeAllChecks();
        assertEquals(1, jdbc.queryForObject("SELECT current_period FROM liability WHERE id=?", Integer.class, disabledLiability));
        assertEquals(0, balance(disabledAccount).compareTo(new BigDecimal("900")));
        assertEquals(0, jdbc.queryForObject("SELECT current_period FROM liability WHERE id=?", Integer.class, deletedLiability));
    }

    @Test
    void concurrentAutomaticAndManualRepaymentDeductOnlyOnceForLastPeriod() throws Exception {
        Person user = person();
        long account = account(user.token, "repay", 1000);
        Map<String, Object> body = liabilityBody(account, category(user), true, LocalDate.now());
        body.put("totalPeriods", 1); body.put("principal", 100); body.put("totalAmount", 100);
        long liability = ok(user.token, HttpMethod.POST, "/api/liabilities", body).path("id").asLong();
        CountDownLatch go = new CountDownLatch(1);
        ExecutorService pool = Executors.newFixedThreadPool(3);
        try {
            Future<?> schedule = pool.submit(() -> { await(go); scheduler.executeAllChecks(); });
            Future<ResponseEntity<JsonNode>> manual = pool.submit(() -> {
                await(go); return request(user.token, HttpMethod.POST, "/api/liabilities/" + liability + "/repay", Map.of("accountId", account, "amount", 100, "periods", 1));
            });
            Future<ResponseEntity<JsonNode>> automatic = pool.submit(() -> {
                await(go); return request(user.token, HttpMethod.POST, "/api/liabilities/check-repayments", null);
            });
            go.countDown();
            schedule.get(30, TimeUnit.SECONDS);
            ResponseEntity<JsonNode> manualResponse = manual.get(30, TimeUnit.SECONDS);
            // Whichever request loses sees an already settled liability; no second successful write is permitted.
            assertTrue(List.of(200, 400).contains(manualResponse.getStatusCode().value()));
            success(automatic.get(30, TimeUnit.SECONDS));
        } finally { pool.shutdownNow(); }
        assertEquals(0, balance(account).compareTo(new BigDecimal("900")));
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM `transaction` WHERE user_id=? AND liability_id=?", Integer.class, user.id, liability));
        assertEquals("SETTLED", jdbc.queryForObject("SELECT status FROM liability WHERE id=?", String.class, liability));
        assertEquals(1, jdbc.queryForObject("SELECT current_period FROM liability WHERE id=?", Integer.class, liability));
    }

    private record Person(long id, String name, String token) {}
    private Person create() {
        String name = unique();
        JsonNode user = ok(admin, HttpMethod.POST, "/api/admin/users", Map.of("username", name, "password", INITIAL));
        long id = user.path("id").asLong();
        assertTrue(id > 0);
        createdUsers.add(id);
        return new Person(id, name, null);
    }
    private Person person() {
        Person user = create();
        String initialToken = login(user.name, INITIAL);
        ok(initialToken, HttpMethod.PUT, "/api/user/password", Map.of("oldPassword", INITIAL, "newPassword", CHANGED));
        return new Person(user.id, user.name, login(user.name, CHANGED));
    }
    private String unique() { return "it_" + UUID.randomUUID().toString().replace("-", ""); }
    private String login(String name, String password) {
        return ok(null, HttpMethod.POST, "/api/user/login", Map.of("username", name, "password", password)).path("token").asText();
    }
    private long account(String token, String name, int initial) {
        return ok(token, HttpMethod.POST, "/api/accounts", Map.of("name", name, "type", "BANK", "initialBalance", initial)).path("id").asLong();
    }
    private long category(Person p) {
        for (JsonNode category : ok(p.token, HttpMethod.GET, "/api/categories", null)) {
            if (category.path("type").asInt() == 2) return category.path("id").asLong();
        }
        throw new AssertionError("No expense category seeded");
    }
    private BigDecimal balance(long account) { return jdbc.queryForObject("SELECT current_balance FROM account WHERE id=?", BigDecimal.class, account); }
    private long defaultTemplate(long user) { return jdbc.queryForObject("SELECT id FROM cycle_template WHERE user_id=? AND is_default=1", Long.class, user); }
    private static String today() { return LocalDate.now().toString(); }
    private Map<String, Object> tx(long account, long category, int amount) { return Map.of("type", 2, "accountId", account, "categoryId", category, "amount", amount, "transactionDate", today()); }
    private Map<String, Object> goal(String name) { return Map.of("name", name, "targetAmount", 10, "startDate", today(), "deadline", LocalDate.now().plusMonths(1).toString()); }
    private Map<String, Object> template(String name, long category) {
        return Map.of("name", name, "startDay", 1, "isDefault", 0, "fixedItems", List.of(Map.of("name", "fixed expense", "type", "EXPENSE", "amount", 10, "categoryId", category)));
    }
    private Map<String, Object> liabilityBody(long account, long category, boolean auto, LocalDate due) {
        Map<String, Object> body = new HashMap<>(Map.of("name", "test liability", "defaultAccountId", account, "categoryId", category,
                "principal", 200, "totalAmount", 200, "totalPeriods", 2, "currentPeriod", 0, "periodAmount", 100, "autoCycleFixedExpense", auto ? 1 : 0));
        body.put("rateType", "NONE"); body.put("repaymentDay", due.getDayOfMonth()); body.put("nextRepaymentDate", due.toString());
        return body;
    }
    private long liability(Person p, long account, long category, boolean auto, LocalDate due) {
        return ok(p.token, HttpMethod.POST, "/api/liabilities", liabilityBody(account, category, auto, due)).path("id").asLong();
    }
    private Map<String, Object> with(Map<String, Object> original, String key, Object value) { Map<String, Object> copy = new HashMap<>(original); copy.put(key, value); return copy; }
    private static void await(CountDownLatch go) { try { if (!go.await(10, TimeUnit.SECONDS)) throw new AssertionError("Concurrent start timed out"); } catch (InterruptedException e) { Thread.currentThread().interrupt(); throw new IllegalStateException(e); } }
    private JsonNode ok(String token, HttpMethod method, String path, Object body) { return success(request(token, method, path, body)); }
    private JsonNode success(ResponseEntity<JsonNode> response) {
        assertEquals(200, response.getStatusCode().value(), () -> "HTTP failure: " + response.getBody());
        assertNotNull(response.getBody());
        assertEquals(200, response.getBody().path("code").asInt(), () -> "API failure: " + response.getBody());
        return response.getBody().path("data");
    }
    private void expect(int status, String token, HttpMethod method, String path, Object body) {
        ResponseEntity<JsonNode> response = request(token, method, path, body);
        assertEquals(status, response.getStatusCode().value(), () -> method + " " + path + ": " + response.getBody());
        assertNotNull(response.getBody());
        assertEquals(status, response.getBody().path("code").asInt());
    }
    private ResponseEntity<JsonNode> request(String token, HttpMethod method, String path, Object body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (token != null) headers.setBearerAuth(token);
        return http.exchange(path, method, new HttpEntity<>(body, headers), JsonNode.class);
    }
}
