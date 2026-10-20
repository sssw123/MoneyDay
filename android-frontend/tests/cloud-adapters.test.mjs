import { createServer } from 'vite';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import http from 'node:http';
import assert from 'node:assert/strict';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const storage = new Map();
globalThis.sessionStorage = { getItem: key => storage.get(key) || null, setItem: (key, value) => storage.set(key, value), removeItem: key => storage.delete(key) };
globalThis.window = new EventTarget();
const received = [];
let user = { id: 2, username: 'alpha', role: 'USER', status: 'ACTIVE', mustChangePassword: false, createdAt: '2026-10-20' };
let delayResponse;
let profileStatus = 200;
let profileOffline = false;
const api = http.createServer(async (req, res) => {
  let raw = ''; for await (const chunk of req) raw += chunk;
  const path = req.url; received.push({ path, method: req.method, auth: req.headers.authorization, payload: raw ? JSON.parse(raw) : null });
  if (path === '/api/user/profile' && profileOffline) { req.socket.destroy(); return; }
  if (path === '/api/write-lost') { req.socket.destroy(); return; }
  const reply = () => {
    if (path === '/api/user/profile' && profileStatus !== 200) { res.statusCode = profileStatus; res.setHeader('Content-Type', 'application/json'); res.end(JSON.stringify({ code: profileStatus, message: 'session expired' })); return; }
    const data = path === '/api/user/login' ? { token: 'test-only-token', expiresAt: '2026-10-27', user } : path === '/api/user/profile' ? user : path === '/api/todos/pending-count' ? { count: 3 } : path === '/api/cycle-templates' && req.method === 'GET' ? [{id: 8, isDefault: 0}, {id: 9, isDefault: 1}] : path === '/api/accounts' && req.method === 'GET' ? [{id: 5}] : path.startsWith('/api/categories') && req.method === 'GET' ? [{id: 4, name: '餐饮', isActive: 1, type: 2}] : path.startsWith('/api/admin/users') && req.method === 'GET' ? {records: [], total: 0} : path === '/api/targets/cumulative-balance' ? 42 : path === '/api/cycles' ? [] : { id: 17 };
    res.setHeader('Content-Type', 'application/json'); res.end(JSON.stringify({ code: 200, message: 'success', data }));
  };
  if (path === '/api/delayed') delayResponse = reply; else reply();
});
await new Promise(resolve => api.listen(0, '127.0.0.1', resolve));
const port = api.address().port;
const vite = await createServer({ root, configFile: false, optimizeDeps: { noDiscovery: true, entries: [] }, resolve: { alias: [{ find: /^vant$/, replacement: path.join(root, 'tests/vant.stub.ts') }] }, server: { middlewareMode: true }, define: { 'import.meta.env.VITE_API_BASE_URL': JSON.stringify(`http://127.0.0.1:${port}/api`) } });
try {
  const { authService } = await vite.ssrLoadModule('/src/services/authService.ts');
  const { session, clearSession, validPassword } = await vite.ssrLoadModule('/src/state/session.ts');
  assert.equal(validPassword('😀'.repeat(7)), false); assert.equal(validPassword('😀'.repeat(8)), true);
  assert.equal(validPassword('1234567'), false); assert.equal(validPassword('abcdefgh'), true); assert.equal(validPassword('界'.repeat(24)), true); assert.equal(validPassword('界'.repeat(25)), false);
  const { ensureAccess } = await vite.ssrLoadModule('/src/state/routeAccess.ts');
  assert.equal(await ensureAccess({ path: '/', meta: {} }), '/login');
  assert.equal(await ensureAccess({ path: '/login', meta: { public: true } }), true);
  await authService.login('alpha','test-only-password'); assert.equal(session.user.id, 2); await authService.profile();
  profileOffline = true;
  // Initial protected navigation must resolve to a real page even with a stored token.
  assert.equal(await ensureAccess({ path: '/', meta: {} }), '/login');
  assert.equal(await ensureAccess({ path: '/login', meta: { public: true } }), true);
  assert.equal(session.token, 'test-only-token'); assert.equal(session.connectionFailed, true);
  profileOffline = false;
  // The reconnect action refreshes the current session before navigating to the dashboard.
  await authService.profile(); assert.equal(session.connectionFailed, false);
  assert.equal(await ensureAccess({ path: '/', meta: {} }), true);
  assert.equal(await ensureAccess({ path: '/admin/users', meta: { admin: true } }), '/');
  user = { ...user, mustChangePassword: true };
  assert.equal(await ensureAccess({ path: '/', meta: {} }), '/change-password');
  assert.equal(await ensureAccess({ path: '/change-password', meta: {} }), true);
  user = { ...user, mustChangePassword: false, role: 'ADMIN' };
  assert.equal(await ensureAccess({ path: '/admin/users', meta: { admin: true } }), true);
  const services = {};
  for (const name of ['account','category','transaction','cycle','liability','wishlist','target','todo','stat','admin']) Object.assign(services, await vite.ssrLoadModule(`/src/services/${name}Service.ts`));
  const {accountService:a,categoryService:c,transactionService:t,cycleService:y,liabilityService:l,wishlistService:w,targetService:g,todoService:d,statService:s,adminService:m}=services;
  assert.equal((await a.addAccount({name:'a'})).id,17); await a.getAccounts(); await a.updateAccount({id:5,name:'a'}); await a.deleteAccount(5);
  await c.getCategories(); await c.addCategory({name:'c'}); await c.toggleCategory(4,0);
  await t.getAllTransactions(); await t.addTransaction({type:1,amount:2,accountId:5,transactionDate:'2026-10-20'}); await t.updateTransaction({id:7,type:1,amount:2,accountId:5,transactionDate:'2026-10-20'}); await t.deleteTransaction(7);
  await y.getCycleTemplates(); assert.equal((await y.getDefaultTemplate()).id, 9); await y.saveCycleTemplate({id:8,startDay:1,fixedItems:[]}); await y.getRecentCycles(); await y.bookItem(8,'income/a',5,2,'2026-10-20'); await y.unbookItem(8,'income/a'); assert.equal(await y.getTotalCumulativeBalance(),42);
  await l.getAllLiabilities(); await l.addLiability({name:'l'}); await l.repayPeriods(9,1,2,5); await l.settleLiability(9,5,3); await l.deleteLiability(9);
  for (const [svc,name] of [[w,'Wishlist'],[g,'Target']]) { await svc[`getAll${name === 'Wishlist' ? 'Wishlists' : 'Targets'}`](); await svc[`add${name}`]({name:'x'}); await svc[`update${name}`]({ id: 10, name: 'changed' }); await svc[`realize${name}`](10,5); await svc[`unrealize${name}`](10); await svc[`delete${name}`](10); }
  await d.getTodos(); assert.equal(await d.countPending(),3); await d.dismissTodo(4); await d.resolveTodo(4); await d.retryLiabilityRepayment(4,5); await s.getStats();
  await m.list(1,'a','ACTIVE'); await m.create('beta','test-only-password'); await m.status(3,'DISABLED'); await m.reset(3,'test-only-password'); await m.delete(3);
  const expected = [
    ['GET','/accounts'], ['POST','/accounts'], ['PUT','/accounts/5'], ['DELETE','/accounts/5'],
    ['GET','/categories'], ['POST','/categories'], ['PUT','/categories/4'],
    ['GET','/transactions'], ['POST','/transactions'], ['PUT','/transactions/7'], ['DELETE','/transactions/7'],
    ['GET','/cycle-templates'], ['PUT','/cycle-templates/8'], ['GET','/cycles'],
    ['POST','/cycles/8/book-item/income%2Fa'], ['POST','/cycles/8/unbook-item/income%2Fa'], ['GET','/targets/cumulative-balance'],
    ['GET','/liabilities'], ['POST','/liabilities'], ['DELETE','/liabilities/9'], ['POST','/liabilities/9/repay'], ['POST','/liabilities/9/settle'],
    ['GET','/wishlists'], ['POST','/wishlists'], ['PUT','/wishlists/10'], ['DELETE','/wishlists/10'], ['POST','/wishlists/10/realize'], ['POST','/wishlists/10/unrealize'],
    ['GET','/targets'], ['POST','/targets'], ['PUT','/targets/10'], ['DELETE','/targets/10'], ['POST','/targets/10/realize'], ['POST','/targets/10/unrealize'],
    ['GET','/todos'], ['GET','/todos/pending-count'], ['POST','/todos/4/dismiss'], ['POST','/todos/4/resolve'], ['POST','/todos/4/retry-repay'], ['GET','/stats'],
    ['GET','/admin/users'], ['POST','/admin/users'], ['PUT','/admin/users/3/status'], ['POST','/admin/users/3/reset-password'], ['DELETE','/admin/users/3'],
  ];
  for (const [method, path] of expected) assert(received.some(record => record.method === method && record.path.split('?')[0] === `/api${path}`), `${method} ${path}`);
  assert(received.slice(1).every(r=>r.auth==='Bearer test-only-token'));
  assert(received.some(r=>r.path==='/api/cycles/8/book-item/income%2Fa'&&r.payload.accountId===5));
  assert(received.some(r=>r.path==='/api/liabilities/9/settle'&&r.payload.settleAmount===3));
  const request = (await vite.ssrLoadModule('/src/utils/request.ts')).default;
  await assert.rejects(request.post('/write-lost', { amount: 1 }));
  assert.equal(session.connectionFailed, true);
  assert.equal(received.filter(r => r.path === '/api/write-lost').length, 1, 'financial writes must never automatically replay');
  await authService.profile(); assert.equal(session.connectionFailed, false);
  const pending = request.get('/delayed'); while(!delayResponse) await new Promise(r=>setTimeout(r,5)); clearSession(); delayResponse(); await assert.rejects(pending,/登录用户已变更/);
  await authService.login('alpha', 'test-only-password');
  await authService.changePassword('test-only-password', 'new-test-password'); assert.equal(session.token, '');
  await authService.login('alpha', 'test-only-password'); await authService.logout(); assert.equal(session.token, '');
  await authService.login('alpha', 'test-only-password'); profileStatus = 401;
  assert.equal(await ensureAccess({ path: '/', meta: {} }), '/login'); assert.equal(session.user, null); assert.equal(sessionStorage.getItem('moneyday_token'), null);
  console.log(`PASS: ${received.length} HTTP service/auth mappings, Bearer authorization, server mutation results, route roles/forced change, password/logout/401 invalidation, stale-session response rejection, offline initial navigation/session reconnect/no write replay; no local database accessed.`);
} finally { await vite.close(); api.close(); }
