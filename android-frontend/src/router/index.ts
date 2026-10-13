import { createRouter, createWebHistory } from 'vue-router';

const routes = [
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
  history: createWebHistory(),
  routes
});

router.afterEach((to) => {
  if (to.meta.title) {
    document.title = `${to.meta.title} - MoneyDay`;
  }
});

export default router;
