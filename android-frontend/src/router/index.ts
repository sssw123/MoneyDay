import { createRouter, createWebHashHistory } from 'vue-router';
import { session } from '../state/session';
import { authService } from '../services/authService';
import { ensureAccess } from '../state/routeAccess';

const routes = [
  { path: '/login', component: () => import('../views/Login.vue'), meta: { title: '登录', public: true } },
  { path: '/change-password', component: () => import('../views/ChangePassword.vue'), meta: { title: '修改密码' } },
  { path: '/admin/users', component: () => import('../views/AdminUsers.vue'), meta: { title: '用户管理', admin: true } },
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('../views/Dashboard.vue'),
    meta: { title: '首页看板' }
  },
  {
    path: '/transactions',
    name: 'Transactions',
    component: () => import('../views/Transactions.vue'),
    meta: { title: '记账明细' }
  },
  {
    path: '/budget',
    name: 'Budget',
    component: () => import('../views/Budget.vue'),
    meta: { title: '周期预算' }
  },
  {
    path: '/plan',
    name: 'Plan',
    component: () => import('../views/Plan.vue'),
    meta: { title: '未来计划' }
  },
  {
    path: '/todos',
    name: 'Todos',
    component: () => import('../views/Todos.vue'),
    meta: { title: '待办中心' }
  },
  {
    path: '/mine',
    name: 'Mine',
    component: () => import('../views/Mine.vue'),
    meta: { title: '系统设置' }
  }
];

const router = createRouter({
  history: createWebHashHistory(),
  routes
});

router.beforeEach(ensureAccess);
window.addEventListener('moneyday:unauthorized', () => { void router.replace('/login'); });
window.addEventListener('moneyday:forbidden', async () => {
  if (router.currentRoute.value.path === '/change-password') return;
  try {
    const user = await authService.profile();
    if (user.mustChangePassword) await router.replace('/change-password');
  } catch { /* Request interceptor handles expired sessions. */ }
});

router.afterEach((to) => {
  if (to.meta.title) {
    document.title = `${to.meta.title} - MoneyDay`;
  }
});

export default router;
