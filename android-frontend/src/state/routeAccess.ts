import type { RouteLocationNormalized } from 'vue-router';
import { session } from './session';
import { authService } from '../services/authService';

/** All protected navigations refresh server identity and account state. */
export async function ensureAccess(to: Pick<RouteLocationNormalized, 'path' | 'meta'>) {
  if (!session.token) return to.meta.public ? true : '/login';
  try {
    const user = await authService.profile();
    if (user.mustChangePassword && to.path !== '/change-password') return '/change-password';
    if (to.meta.public) return '/';
    if (to.meta.admin && user.role !== 'ADMIN') return '/';
    return true;
  } catch {
    // A retained token cannot prove identity offline. Keep a usable login screen
    // instead of cancelling initial navigation at START_LOCATION.
    return to.meta.public ? true : '/login';
  }
}
