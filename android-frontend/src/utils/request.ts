import axios, { type InternalAxiosRequestConfig } from 'axios';
import { showToast } from 'vant';
import { Capacitor } from '@capacitor/core';
import { session, clearSession } from '../state/session';

type SessionRequest = InternalAxiosRequestConfig & { sessionGeneration?: number };
const baseURL = import.meta.env.VITE_API_BASE_URL || '/api';
const invalidNativeUrl = Capacitor.isNativePlatform() && !/^https?:\/\//.test(baseURL);
const instance = axios.create({ baseURL, timeout: 15000 });
instance.interceptors.request.use((config: SessionRequest) => {
  config.sessionGeneration = session.generation;
  if (invalidNativeUrl) return Promise.reject(new axios.AxiosError('Android 需要配置完整的 VITE_API_BASE_URL 后重新打包', 'API_CONFIGURATION', config));
  if (session.token) config.headers.Authorization = `Bearer ${session.token}`;
  return config;
});

function stale(config?: SessionRequest) {
  return config?.sessionGeneration !== session.generation;
}
function handleFailure(status: number | undefined, message: string) {
  if (status === 401) {
    clearSession();
    window.dispatchEvent(new Event('moneyday:unauthorized'));
  } else if (status === 403 && session.token) {
    window.dispatchEvent(new Event('moneyday:forbidden'));
  }
  showToast({ type: 'fail', message });
}
instance.interceptors.response.use(
  (response) => {
    if (stale(response.config)) return Promise.reject(new Error('登录用户已变更，请求结果已丢弃'));
    session.connectionFailed = false;
    const res = response.data;
    if (res.code !== 200) {
      handleFailure(res.code, res.message || '操作失败');
      return Promise.reject(new Error(res.message || '操作失败'));
    }
    return res.data;
  },
  (error) => {
    if (stale(error.config)) return Promise.reject(new Error('登录用户已变更，请求结果已丢弃'));
    session.connectionFailed = !error.response;
    const msg = error.code === 'API_CONFIGURATION' ? error.message : error.response?.data?.message || (error.response ? '操作失败' : '服务器连接失败，请检查网络后重试');
    handleFailure(error.response?.status, msg);
    return Promise.reject(error);
  },
);
const request = {
  get: <T = unknown>(url: string, config?: object): Promise<T> => instance.get(url, config) as unknown as Promise<T>,
  post: <T = unknown>(url: string, data?: unknown): Promise<T> => instance.post(url, data) as unknown as Promise<T>,
  put: <T = unknown>(url: string, data?: unknown): Promise<T> => instance.put(url, data) as unknown as Promise<T>,
  delete: <T = unknown>(url: string): Promise<T> => instance.delete(url) as unknown as Promise<T>,
};
export default request;
