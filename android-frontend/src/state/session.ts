import { reactive } from 'vue';

export interface UserProfile {
  id: number;
  username: string;
  role: 'ADMIN' | 'USER';
  status: 'ACTIVE' | 'DISABLED' | 'DELETED';
  mustChangePassword: boolean;
  createdAt: string;
}

export const session = reactive({
  token: sessionStorage.getItem('moneyday_token') || '',
  user: null as UserProfile | null,
  generation: 0,
  connectionFailed: false,
});

export function setSession(token: string, user: UserProfile) {
  session.generation++;
  session.token = token;
  session.user = user;
  session.connectionFailed = false;
  sessionStorage.setItem('moneyday_token', token);
}

export function clearSession() {
  session.generation++;
  session.token = '';
  session.user = null;
  session.connectionFailed = false;
  sessionStorage.removeItem('moneyday_token');
  sessionStorage.removeItem('moneyday_user');
}

export function validPassword(value: string) {
  return Array.from(value).length >= 8 && new TextEncoder().encode(value).length <= 72;
}
