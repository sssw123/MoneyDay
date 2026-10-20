<template>
  <a-config-provider :theme="theme" :locale="zhCN">
    <a-layout class="app-shell">
      <aside
        v-if="!isMobile"
        class="sidebar"
        :class="{ 'sidebar--compact': collapsed }"
        aria-label="主导航"
      >
        <AppNavigation :compact="collapsed" :pending-count="pendingCount" />
        <a-button
          class="sidebar-toggle"
          type="text"
          :aria-label="collapsed ? '展开导航' : '折叠导航'"
          :aria-expanded="!collapsed"
          @click="collapsed = !collapsed"
        >
          <MenuUnfoldOutlined v-if="collapsed" /><MenuFoldOutlined v-else /><span v-if="!collapsed"
            >收起导航</span
          >
        </a-button>
      </aside>
      <a-drawer
        v-model:open="drawerOpen"
        title="导航菜单"
        placement="left"
        :width="280"
        class="mobile-navigation"
      >
        <nav aria-label="移动端主导航">
          <AppNavigation :pending-count="pendingCount" @navigate="drawerOpen = false" />
        </nav>
      </a-drawer>
      <a-layout
        class="main-layout"
        :class="{ 'main-layout--compact': collapsed, 'main-layout--mobile': isMobile }"
      >
        <header class="topbar">
          <div class="topbar-location">
            <a-button
              v-if="isMobile"
              type="text"
              aria-label="打开导航菜单"
              :aria-expanded="drawerOpen"
              @click="drawerOpen = true"
              ><MenuOutlined /></a-button
            ><span class="topbar-section">我的工作台</span><span class="topbar-divider">/</span
            ><span>{{ currentPage.title }}</span>
          </div>
          <div class="topbar-actions">
            <router-link to="/todos" class="todo-link"
              ><BellOutlined /><span class="todo-link-label">待办事项</span
              ><a-badge :count="pendingCount" size="small" /></router-link
            ><span class="topbar-separator"></span>
            <div class="profile-mark" aria-hidden="true">M</div>
            <span class="profile-label">私人账本</span>
          </div>
        </header>
        <main id="main-content" class="page-content">
          <div v-if="route.path !== '/'" class="page-heading">
            <div class="eyebrow">MY MONEYDAY</div>
            <h1>{{ currentPage.title }}</h1>
            <p>{{ currentPage.description }}</p>
          </div>
          <router-view />
        </main>
        <footer class="app-footer">
          <span>MoneyDay ©2026</span><span>认真生活，自在积累。</span>
        </footer>
      </a-layout>
    </a-layout>
  </a-config-provider>
</template>

<script lang="ts" setup>
import { ref, watch, onMounted, onUnmounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import type { ThemeConfig } from 'ant-design-vue/es/config-provider/context';
import zhCN from 'ant-design-vue/es/locale/zh_CN';
import {
  MenuOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  BellOutlined,
} from '@ant-design/icons-vue';
import AppNavigation from './components/AppNavigation.vue';
import request from './utils/request';

const theme: ThemeConfig = {
  token: {
    colorPrimary: '#171B18',
    colorSuccess: '#477824',
    colorInfo: '#48759A',
    colorWarning: '#A66B1B',
    colorError: '#C94747',
    colorText: '#171B18',
    colorTextSecondary: '#667068',
    colorBgLayout: '#F4F6F5',
    colorBorder: '#E2E7E3',
    borderRadius: 12,
    controlHeight: 40,
    fontFamily:
      "Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif",
  },
  components: {
    Card: { borderRadiusLG: 24, paddingLG: 24 },
    Button: { borderRadius: 22, borderRadiusSM: 12, controlHeightSM: 28 },
    Menu: {
      colorItemBgSelected: '#E8F3DC',
      colorItemTextSelected: '#2F501C',
      colorItemBgHover: '#F1F4EF',
      controlHeightLG: 46,
      radiusItem: 12,
    },
    Table: { colorFillAlter: '#F7F9F6', colorTextHeading: '#667068', colorFillContent: '#F5F9F0' },
  },
};
const pages: Record<string, { title: string; description: string }> = {
  '/': { title: '首页看板', description: '' },
  '/transactions': { title: '记账明细', description: '记录每一笔收支，让资金的来去清清楚楚。' },
  '/accounts': { title: '账户管理', description: '现金、银行卡与电子钱包，在这里一目了然。' },
  '/categories': { title: '分类管理', description: '整理收支分类，找到适合自己的记账方式。' },
  '/budget': { title: '周期预算', description: '按自己的节奏安排收支，为每个周期留出余裕。' },
  '/plan/targets': { title: '长期目标', description: '用真实的净资产，为想要的未来慢慢积累。' },
  '/plan/wishlist': { title: '心愿单', description: '把小小期待放在这里，让每一份结余都有盼头。' },
  '/plan/liabilities': {
    title: '透支与分期',
    description: '看清待还金额与还款节奏，从容安排未来支出。',
  },
  '/todos': { title: '待办中心', description: '周期提醒、分期还款与心愿进展，及时照顾每一件事。' },
  '/settings': { title: '系统设置', description: '设置专属账单周期，让账本贴合你的生活节奏。' },
};
const route = useRoute();
const currentPage = computed(() => pages[route.path] ?? { title: 'MoneyDay', description: '' });
const collapsed = ref(false);
const isMobile = ref(false);
const drawerOpen = ref(false);
const pendingCount = ref(0);
let desktopQuery: MediaQueryList;
let mobileQuery: MediaQueryList;
const syncViewport = () => {
  isMobile.value = mobileQuery.matches;
  collapsed.value = !desktopQuery.matches;
  if (!isMobile.value) drawerOpen.value = false;
};
const fetchPendingCount = async () => {
  try {
    const res = await request.get<never, { count: number }>('/todos/pending-count');
    pendingCount.value = res.count || 0;
  } catch {
    /* 请求拦截器统一展示错误。 */
  }
};
watch(
  () => route.path,
  () => {
    drawerOpen.value = false;
    fetchPendingCount();
  },
  { immediate: true },
);
onMounted(() => {
  desktopQuery = window.matchMedia('(min-width: 1200px)');
  mobileQuery = window.matchMedia('(max-width: 767px)');
  syncViewport();
  desktopQuery.addEventListener('change', syncViewport);
  mobileQuery.addEventListener('change', syncViewport);
});
onUnmounted(() => {
  desktopQuery.removeEventListener('change', syncViewport);
  mobileQuery.removeEventListener('change', syncViewport);
});
</script>
