import axios from 'axios';
import { showToast } from 'vant';

const instance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000,
});

instance.interceptors.response.use(
  (response) => {
    const res = response.data;
    if (res.code !== 200) {
      showToast({ type: 'fail', message: res.message || '操作失败' });
      return Promise.reject(new Error(res.message || 'Error'));
    }
    return res.data;
  },
  (error) => {
    const msg = error.response?.data?.message || error.message || '服务器连接失败';
    showToast({ type: 'fail', message: msg });
    return Promise.reject(error);
  }
);

const request = {
  get: <T = any>(url: string, config?: any): Promise<T> => instance.get(url, config) as any,
  post: <T = any>(url: string, data?: any, config?: any): Promise<T> => instance.post(url, data, config) as any,
  put: <T = any>(url: string, data?: any, config?: any): Promise<T> => instance.put(url, data, config) as any,
  delete: <T = any>(url: string, config?: any): Promise<T> => instance.delete(url, config) as any,
};

export default request;
