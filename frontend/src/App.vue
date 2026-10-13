<template>
  <a-layout has-sider style="min-height: 100vh">
    <a-layout-sider
      v-model:collapsed="collapsed"
      collapsible
      :style="{ overflow: 'auto', height: '100vh', position: 'fixed', left: 0, top: 0, bottom: 0, zIndex: 100 }"
    >
      <div class="logo">MoneyDay</div>
      <a-menu v-model:selectedKeys="selectedKeys" v-model:openKeys="openKeys" theme="dark" mode="inline">
        <a-menu-item key="/">
          <router-link to="/">首页看板</router-link>
        </a-menu-item>
        <a-menu-item key="/transactions">
          <router-link to="/transactions">记账明细</router-link>
        </a-menu-item>
        <a-menu-item key="/accounts">
          <router-link to="/accounts">账户管理</router-link>
        </a-menu-item>
        <a-menu-item key="/categories">
          <router-link to="/categories">分类管理</router-link>
        </a-menu-item>
        <a-menu-item key="/budget">
          <router-link to="/budget">预算</router-link>
        </a-menu-item>
        <a-sub-menu key="future-plan" title="未来计划">
          <a-menu-item key="/plan/targets">
            <router-link to="/plan/targets">目标</router-link>
          </a-menu-item>
          <a-menu-item key="/plan/wishlist">
            <router-link to="/plan/wishlist">心愿单</router-link>
          </a-menu-item>
          <a-menu-item key="/plan/liabilities">
            <router-link to="/plan/liabilities">透支</router-link>
          </a-menu-item>
        </a-sub-menu>
        <a-menu-item key="/todos">
          <router-link to="/todos" style="display: flex; align-items: center; justify-content: space-between;">
            <span>待办中心</span>
            <a-badge v-if="pendingCount > 0" :count="pendingCount" size="small" :overflow-count="99" />
          </router-link>
        </a-menu-item>
        <a-menu-item key="/settings">
          <router-link to="/settings">系统设置</router-link>
        </a-menu-item>
      </a-menu>
    </a-layout-sider>
    <a-layout :style="{ marginLeft: collapsed ? '80px' : '200px', transition: 'all 0.2s', minHeight: '100vh' }">
      <a-layout-header style="background: #fff; padding: 0 24px; display: flex; justify-content: flex-end; align-items: center; border-bottom: 1px solid #f0f0f0;">
        <router-link to="/todos" style="display: flex; align-items: center; gap: 8px; color: #555;">
          <span>待办事项</span>
          <a-badge :count="pendingCount" size="small" />
        </router-link>
      </a-layout-header>
      <a-layout-content style="margin: 16px">
        <div :style="{ padding: '24px', background: '#fff', minHeight: '360px' }">
          <router-view />
        </div>
      </a-layout-content>
      <a-layout-footer style="text-align: center">
        MoneyDay ©2026
      </a-layout-footer>
    </a-layout>
  </a-layout>
</template>

<script lang="ts" setup>
import { ref, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import request from './utils/request';

const collapsed = ref<boolean>(false);
const selectedKeys = ref<string[]>(['/']);
const openKeys = ref<string[]>(['future-plan']);
const pendingCount = ref<number>(0);
const route = useRoute();

const fetchPendingCount = async () => {
  try {
    const res: any = await request.get('/todos/pending-count');
    pendingCount.value = res.count || 0;
  } catch (e) {}
};

watch(() => route.path, (newPath) => {
  selectedKeys.value = [newPath];
  if (newPath.startsWith('/plan/')) {
    if (!openKeys.value.includes('future-plan')) {
      openKeys.value.push('future-plan');
    }
  }
  fetchPendingCount();
}, { immediate: true });

onMounted(() => {
  fetchPendingCount();
});
</script>

<style scoped>
.logo {
  height: 32px;
  margin: 16px;
  color: white;
  font-weight: bold;
  font-size: 1.2rem;
  text-align: center;
  line-height: 32px;
}
</style>
