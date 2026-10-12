<template>
  <a-layout has-sider style="min-height: 100vh">
    <a-layout-sider
      v-model:collapsed="collapsed"
      collapsible
      :style="{ overflow: 'auto', height: '100vh', position: 'fixed', left: 0, top: 0, bottom: 0, zIndex: 100 }"
    >
      <div class="logo">MoneyDay</div>
      <a-menu v-model:selectedKeys="selectedKeys" theme="dark" mode="inline">
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
        <a-menu-item key="/budgets">
          <router-link to="/budgets">预算与目标</router-link>
        </a-menu-item>
        <a-menu-item key="/wishlist">
          <router-link to="/wishlist">心愿单</router-link>
        </a-menu-item>
        <a-menu-item key="/settings">
          <router-link to="/settings">系统设置</router-link>
        </a-menu-item>
      </a-menu>
    </a-layout-sider>
    <a-layout :style="{ marginLeft: collapsed ? '80px' : '200px', transition: 'all 0.2s', minHeight: '100vh' }">
      <a-layout-header style="background: #fff; padding: 0" />
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
import { ref, watch } from 'vue';
import { useRoute } from 'vue-router';

const collapsed = ref<boolean>(false);
const selectedKeys = ref<string[]>(['/']);
const route = useRoute();

watch(() => route.path, (newPath) => {
  selectedKeys.value = [newPath];
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
