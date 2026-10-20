import { reactive } from 'vue'

export interface UserProfile {
  id: number
  username: string
  role: 'ADMIN' | 'USER'
  status: 'ACTIVE' | 'DISABLED' | 'DELETED'
  mustChangePassword: boolean
  createdAt: string
}
export interface LoginResult { token: string; expiresAt: string; user: UserProfile }
const key = 'moneyday.session'
function readSession(): LoginResult | null {
  try {
    const value = JSON.parse(sessionStorage.getItem(key) || 'null') as LoginResult | null
    if (value?.token && value.user?.id && Date.parse(value.expiresAt) > Date.now()) return value
  } catch { /* Invalid stored sessions require a new login. */ }
  sessionStorage.removeItem(key)
  return null
}
const initial = readSession()
export const session = reactive({
  token: initial?.token ?? '',
  expiresAt: initial?.expiresAt ?? '',
  user: initial?.user ?? null as UserProfile | null,
  generation: 0,
})
function persist() {
  if (session.token && session.user) sessionStorage.setItem(key, JSON.stringify({ token: session.token, expiresAt: session.expiresAt, user: session.user }))
  else sessionStorage.removeItem(key)
}
export function setSession(value: LoginResult) {
  session.generation++
  session.token = value.token
  session.expiresAt = value.expiresAt
  session.user = value.user
  persist()
}
export function updateProfile(user: UserProfile) { session.user = user; persist() }
export function clearSession() {
  session.generation++
  session.token = ''
  session.expiresAt = ''
  session.user = null
  persist()
}
export const passwordRule = {
  async validator(_: unknown, value: string) {
    if (!value || Array.from(value).length < 8 || new TextEncoder().encode(value).length > 72) throw new Error('密码至少 8 位，且 UTF-8 编码不超过 72 字节')
  },
}
