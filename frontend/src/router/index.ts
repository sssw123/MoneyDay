import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Dashboard',
      component: () => import('../views/Dashboard.vue')
    },
    {
      path: '/transactions',
      name: 'TransactionList',
      component: () => import('../views/TransactionList.vue')
    },
    {
      path: '/accounts',
      name: 'AccountList',
      component: () => import('../views/AccountList.vue')
    },
    {
      path: '/categories',
      name: 'CategoryList',
      component: () => import('../views/CategoryList.vue')
    },
    {
      path: '/budget',
      name: 'Budget',
      component: () => import('../views/Budget.vue')
    },
    {
      path: '/budgets',
      redirect: '/budget'
    },
    {
      path: '/plan/targets',
      name: 'TargetPlan',
      component: () => import('../views/TargetPlan.vue')
    },
    {
      path: '/plan/wishlist',
      name: 'Wishlist',
      component: () => import('../views/Wishlist.vue')
    },
    {
      path: '/wishlist',
      redirect: '/plan/wishlist'
    },
    {
      path: '/plan/liabilities',
      name: 'Liability',
      component: () => import('../views/Liability.vue')
    },
    {
      path: '/todos',
      name: 'TodoCenter',
      component: () => import('../views/TodoCenter.vue')
    },
    {
      path: '/settings',
      name: 'Settings',
      component: () => import('../views/Settings.vue')
    }
  ]
})

export default router
