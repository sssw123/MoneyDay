import axios, { CanceledError } from 'axios'
import { message } from 'ant-design-vue'
import { clearSession, session } from '../auth/session'

declare module 'axios' {
  interface InternalAxiosRequestConfig {
    sessionStamp?: { token: string; generation: number }
  }
}
const request = axios.create({ baseURL: '/api', timeout: 15000 })
request.interceptors.request.use(config => {
  config.sessionStamp = { token: session.token, generation: session.generation }
  if (session.token) config.headers.Authorization = `Bearer ${session.token}`
  return config
})
function stale(config?: { sessionStamp?: { token: string; generation: number } }) {
  return config?.sessionStamp && (config.sessionStamp.token !== session.token || config.sessionStamp.generation !== session.generation)
}
request.interceptors.response.use(response => {
  if (stale(response.config)) throw new CanceledError('账户已切换，忽略旧请求')
  const res = response.data
  if (res.code !== 200) {
    message.error(res.message || '请求失败')
    return Promise.reject(new Error(res.message || '请求失败'))
  }
  return res.data
}, error => {
  if (stale(error.config)) return Promise.reject(new CanceledError('账户已切换，忽略旧请求'))
  if (axios.isCancel(error)) return Promise.reject(error)
  if (error.response?.status === 401 && !error.config?.url?.endsWith('/user/login')) {
    clearSession()
    window.dispatchEvent(new Event('moneyday:unauthorized'))
  } else if (error.response?.status === 403 && session.user?.mustChangePassword) {
    window.dispatchEvent(new Event('moneyday:password-required'))
  } else {
    message.error(error.response?.data?.message || (error.response ? '请求失败，请稍后重试' : '无法连接服务，请检查网络后重试'))
  }
  return Promise.reject(error)
})

export async function logoutSession() {
  const token = session.token
  clearSession()
  // Clear the UI immediately while revoking the captured session on the server.
  if (token) {
    try { await axios.post('/api/user/logout', {}, { headers: { Authorization: `Bearer ${token}` }, timeout: 15000 }) }
    catch { /* Local logout still completes when the server is unavailable. */ }
  }
}
export default request
