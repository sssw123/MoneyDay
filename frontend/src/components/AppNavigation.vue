<template>
  <div class="brand" :class="{ 'brand--compact': compact }">
    <div class="brand-mark"><span></span><span></span><span></span></div>
    <div v-if="!compact" class="brand-copy">
      <strong>MoneyDay<span>®</span></strong
      ><small>让每一笔，都有方向</small>
    </div>
  </div>
  <div v-if="!compact" class="nav-label">我的账本</div>
  <a-menu
    :selected-keys="[route.path]"
    v-model:openKeys="openKeys"
    mode="inline"
    :inline-collapsed="compact"
    @click="emit('navigate')"
  >
    <a-menu-item key="/"
      ><template #icon><AppstoreOutlined /></template
      ><router-link to="/">首页看板</router-link></a-menu-item
    >
    <a-menu-item key="/transactions"
      ><template #icon><SwapOutlined /></template
      ><router-link to="/transactions">记账明细</router-link></a-menu-item
    >
    <a-menu-item key="/accounts"
      ><template #icon><WalletOutlined /></template
      ><router-link to="/accounts">账户管理</router-link></a-menu-item
    >
    <a-menu-item key="/categories"
      ><template #icon><TagsOutlined /></template
      ><router-link to="/categories">分类管理</router-link></a-menu-item
    >
    <a-menu-item key="/budget"
      ><template #icon><PieChartOutlined /></template
      ><router-link to="/budget">预算</router-link></a-menu-item
    >
    <a-sub-menu key="future-plan"
      ><template #icon><RocketOutlined /></template><template #title>未来计划</template>
      <a-menu-item key="/plan/targets"
        ><router-link to="/plan/targets">目标</router-link></a-menu-item
      >
      <a-menu-item key="/plan/wishlist"
        ><router-link to="/plan/wishlist">心愿单</router-link></a-menu-item
      >
      <a-menu-item key="/plan/liabilities"
        ><router-link to="/plan/liabilities">透支</router-link></a-menu-item
      >
    </a-sub-menu>
    <a-menu-item key="/todos"
      ><template #icon><CheckSquareOutlined /></template
      ><router-link class="nav-todo" to="/todos"
        ><span>待办中心</span
        ><a-badge v-if="pendingCount" :count="pendingCount" size="small" /></router-link
    ></a-menu-item>
    <a-menu-item key="/settings"
      ><template #icon><SettingOutlined /></template
      ><router-link to="/settings">系统设置</router-link></a-menu-item
    >
    <a-menu-item v-if="session.user?.role === 'ADMIN'" key="/admin/users">
      <template #icon><TeamOutlined /></template>
      <router-link to="/admin/users">用户管理</router-link>
    </a-menu-item>
  </a-menu>
  <div v-if="!compact" class="nav-note">
    <span class="nav-note-dot"></span>
    <div>好好记账，慢慢积累<small>把日常变成未来的底气。</small></div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { useRoute } from 'vue-router';
import { session } from '../auth/session';
import {
  AppstoreOutlined,
  SwapOutlined,
  WalletOutlined,
  TagsOutlined,
  PieChartOutlined,
  RocketOutlined,
  CheckSquareOutlined,
  SettingOutlined,
  TeamOutlined,
} from '@ant-design/icons-vue';
defineProps<{ compact?: boolean; pendingCount: number }>();
const emit = defineEmits<{ navigate: [] }>();
const route = useRoute();
const openKeys = ref<string[]>(['future-plan']);
watch(
  () => route.path,
  (path) => {
    if (path.startsWith('/plan/') && !openKeys.value.includes('future-plan'))
      openKeys.value.push('future-plan');
  },
);
</script>
