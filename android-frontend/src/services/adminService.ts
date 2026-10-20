import request from '../utils/request';
import type { UserProfile } from '../state/session';

export const adminService = {
  list: (page: number, keyword: string, status: string) => request.get<{ records: UserProfile[]; total: number; page: number; pageSize: number }>('/admin/users', { params: { page, pageSize: 20, keyword, status } }),
  create: (username: string, password: string) => request.post<UserProfile>('/admin/users', { username, password }),
  status: (id: number, status: 'ACTIVE' | 'DISABLED') => request.put(`/admin/users/${id}/status`, { status }),
  reset: (id: number, password: string) => request.post(`/admin/users/${id}/reset-password`, { password }),
  delete: (id: number) => request.delete(`/admin/users/${id}`),
};
