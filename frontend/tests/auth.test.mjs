// Run with Node 22: node --test tests/auth.test.mjs (uses the project's Vite only).
import { after, test } from 'node:test'
import assert from 'node:assert/strict'
import { mkdtemp, writeFile, rm } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import path from 'node:path'
import { pathToFileURL, fileURLToPath } from 'node:url'
import { build } from 'vite'

const root = fileURLToPath(new URL('../', import.meta.url))
const directory = await mkdtemp(path.join(tmpdir(), 'moneyday-web-auth-'))
const entry = path.join(directory, 'entry.ts')
const messages = path.join(directory, 'messages.ts')
await writeFile(messages, 'export const message = { error() {} }')
await writeFile(entry, `export * from ${JSON.stringify(path.join(root, 'src/auth/session.ts'))}; export { default as request } from ${JSON.stringify(path.join(root, 'src/utils/request.ts'))};`)
await build({
  configFile: false, root, logLevel: 'silent',
  resolve: { alias: { 'ant-design-vue': messages } },
  build: { outDir: path.join(directory, 'out'), lib: { entry, formats: ['es'], fileName: () => 'auth.mjs' }, minify: false },
})
const values = new Map()
globalThis.sessionStorage = { getItem: key => values.get(key) ?? null, setItem: (key, value) => values.set(key, value), removeItem: key => values.delete(key) }
globalThis.window = new EventTarget()
const { session, setSession, clearSession, updateProfile, passwordRule, request } = await import(pathToFileURL(path.join(directory, 'out/auth.mjs')))
after(async () => { await rm(directory, { recursive: true, force: true }) })
const profile = { id: 1, username: 'Alice', role: 'USER', status: 'ACTIVE', mustChangePassword: false, createdAt: '2026-10-20T00:00:00Z' }
function login(id = 1, force = false) { setSession({ token: `token-${id}`, expiresAt: new Date(Date.now() + 86400000).toISOString(), user: { ...profile, id, mustChangePassword: force } }) }
function response(config, data) { return { data: { code: 200, message: 'success', data }, status: 200, statusText: 'OK', headers: {}, config } }
function rejection(config, status) { return Object.assign(new Error('request failed'), { config, response: { status, data: { message: 'rejected' } } }) }

test('session persist/update/clear and generation invalidation', () => {
  const initialGeneration = session.generation
  login()
  assert.equal(session.generation, initialGeneration + 1)
  assert.equal(JSON.parse(values.get('moneyday.session')).user.username, 'Alice')
  updateProfile({ ...profile, username: 'alice-updated' })
  assert.equal(JSON.parse(values.get('moneyday.session')).user.username, 'alice-updated')
  clearSession()
  assert.equal(session.token, '')
  assert.equal(session.user, null)
  assert.equal(values.has('moneyday.session'), false)
})
test('Bearer token attached and envelopes unwrapped', async () => {
  login()
  request.defaults.adapter = async config => { assert.equal(config.headers.Authorization, 'Bearer token-1'); return response(config, ['own-record']) }
  assert.deepEqual(await request.get('/accounts'), ['own-record'])
})
test('switching accounts rejects an in-flight success from the old user', async () => {
  login(1)
  let complete
  request.defaults.adapter = config => new Promise(resolve => { complete = () => resolve(response(config, ['private-user-1'])) })
  const pending = request.get('/accounts')
  await new Promise(resolve => setImmediate(resolve))
  login(2)
  complete()
  await assert.rejects(pending, error => error.code === 'ERR_CANCELED')
  assert.equal(session.user.id, 2)
})
test('old 401 cannot log out the newly logged-in account', async () => {
  login(1)
  let complete
  request.defaults.adapter = config => new Promise((_, reject) => { complete = () => reject(rejection(config, 401)) })
  const pending = request.get('/accounts')
  await new Promise(resolve => setImmediate(resolve))
  login(2)
  complete()
  await assert.rejects(pending, error => error.code === 'ERR_CANCELED')
  assert.equal(session.token, 'token-2')
})
test('401 clears all session data and emits login navigation event', async () => {
  login()
  let events = 0
  window.addEventListener('moneyday:unauthorized', () => events++, { once: true })
  request.defaults.adapter = async config => { throw rejection(config, 401) }
  await assert.rejects(request.get('/accounts'))
  assert.equal(session.token, '')
  assert.equal(session.user, null)
  assert.equal(values.size, 0)
  assert.equal(events, 1)
})
test('invalid login keeps login flow independent of expiry event', async () => {
  clearSession()
  let events = 0
  const listener = () => events++
  window.addEventListener('moneyday:unauthorized', listener)
  request.defaults.adapter = async config => { throw rejection(config, 401) }
  await assert.rejects(request.post('/user/login', { username: 'wrong', password: 'wrong' }))
  assert.equal(events, 0)
  window.removeEventListener('moneyday:unauthorized', listener)
})
test('forced-password 403 emits dedicated redirect; ordinary forbidden leaves session intact', async () => {
  login(1, true)
  let events = 0
  const listener = () => events++
  window.addEventListener('moneyday:password-required', listener)
  request.defaults.adapter = async config => { throw rejection(config, 403) }
  await assert.rejects(request.get('/accounts'))
  assert.equal(events, 1)
  login(2)
  await assert.rejects(request.get('/admin/users'))
  assert.equal(events, 1)
  assert.equal(session.token, 'token-2')
  window.removeEventListener('moneyday:password-required', listener)
})
test('password rules check both minimum length and BCrypt UTF-8 limit', async () => {
  await assert.rejects(passwordRule.validator(null, '1234567'))
  await assert.rejects(passwordRule.validator(null, '密'.repeat(25)))
  await assert.rejects(passwordRule.validator(null, 'a'.repeat(73)))
  await assert.rejects(passwordRule.validator(null, '😀'.repeat(7)))
  await passwordRule.validator(null, '😀'.repeat(8))
  await passwordRule.validator(null, 'a'.repeat(72))
  await passwordRule.validator(null, '密码'.repeat(12))
})
