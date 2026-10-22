import request from '../utils/request';
import { clearSession, session, setSession, type UserProfile } from '../state/session';

export const authService = {
  async login(username: string, password: string) {
    clearSession();
    const result = await request.post<{ token: string; expiresAt: string; user: UserProfile }>('/user/login', { username, password });
    setSession(result.token, result.user);
    return result;
  },
  async profile() {
    const user = await request.get<UserProfile>('/user/profile');
    session.user = user;
    return user;
  },
  async logout() {
    const generation = session.generation;
    try { await request.post('/user/logout'); }
    finally { if (session.generation === generation) clearSession(); }
  },
  async changePassword(oldPassword: string, newPassword: string) {
    await request.put('/user/password', { oldPassword, newPassword });
    clearSession();
  },
};
