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
      path: '/budgets',
      name: 'BudgetAndTarget',
      component: () => import('../views/BudgetAndTarget.vue')
    },
    {
      path: '/wishlist',
      name: 'Wishlist',
      component: () => import('../views/Wishlist.vue')
    },
    {
      path: '/settings',
      name: 'Settings',
      component: () => import('../views/Settings.vue')
    }
  ]
})

export default router
