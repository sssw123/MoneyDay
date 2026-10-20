import { createRouter, createWebHistory } from 'vue-router'
import { session, clearSession, updateProfile } from '../auth/session'
import type { UserProfile } from '../auth/session'
import request from '../utils/request'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', name: 'Login', component: () => import('../views/Login.vue'), meta: { standalone: true } },
    { path: '/change-password', name: 'ChangePassword', component: () => import('../views/ChangePassword.vue'), meta: { standalone: true } },
    { path: '/admin/users', name: 'UserManagement', component: () => import('../views/UserManagement.vue'), meta: { admin: true } },
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

router.beforeEach(async to => {
  if (!session.token) return to.path === '/login' ? true : { path: '/login' }
  if (Date.parse(session.expiresAt) <= Date.now()) {
    clearSession()
    return { path: '/login' }
  }
  try {
    const profile = await request.get<never, UserProfile>('/user/profile')
    updateProfile(profile)
  } catch {
    // The request interceptor clears expired sessions; network failures remain retryable.
    if (to.path === '/login') return true
    return { path: '/login' }
  }
  if (session.user?.mustChangePassword && to.path !== '/change-password') return { path: '/change-password' }
  if (to.path === '/login') return { path: '/' }
  if (to.meta.admin && session.user?.role !== 'ADMIN') return { path: '/' }
  return true
})
window.addEventListener('moneyday:unauthorized', () => { void router.replace('/login') })
window.addEventListener('moneyday:password-required', () => { void router.replace('/change-password') })

export default router
