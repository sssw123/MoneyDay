<template>
  <div class="mobile-container">
    <div class="content-wrapper">
      <van-notice-bar v-if="session.connectionFailed" wrapable :scrollable="false" text="服务器连接失败，当前无法保存。请检查网络后重试。" />
      <div v-if="session.connectionFailed" style="padding: 8px 16px"><van-button block size="small" :loading="reconnecting" @click="retry">重新连接</van-button></div>
      <router-view :key="`${session.generation}:${route.path}:${retryCount}`" />
    </div>

    <!-- 底部常驻 Tabbar -->
    <van-tabbar v-if="showTabbar" v-model="activeTab" route fixed placeholder safe-area-inset-bottom active-color="#1989fa">
      <van-tabbar-item to="/" icon="wap-home-o">看板</van-tabbar-item>
      <van-tabbar-item to="/transactions" icon="balance-list-o">明细</van-tabbar-item>
      <van-tabbar-item to="/budget" icon="calendar-o">周期表</van-tabbar-item>
      <van-tabbar-item to="/plan" icon="aim">未来计划</van-tabbar-item>
      <van-tabbar-item to="/todos" icon="bell-o" :badge="pendingCount > 0 ? pendingCount : ''">待办</van-tabbar-item>
      <van-tabbar-item to="/mine" icon="setting-o">设置</van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<script lang="ts" setup>
import { ref, watch, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { todoService, authService } from './services';
import { session } from './state/session';

const activeTab = ref(0);
const pendingCount = ref(0);
const route = useRoute();
const router = useRouter();
const reconnecting = ref(false);
const retryCount = ref(0);
const showTabbar = computed(() => !!session.token && !!session.user && !session.user.mustChangePassword && !['/login', '/change-password'].includes(route.path));
async function fetchPendingCount() {
  if (!showTabbar.value) { pendingCount.value = 0; return; }
  try { pendingCount.value = await todoService.countPending(); } catch { /* Shared connection notice. */ }
}
async function retry() {
  if (reconnecting.value) return;
  reconnecting.value = true;
  try {
    if (session.token) {
      const user = await authService.profile();
      await router.replace(user.mustChangePassword ? '/change-password' : route.path === '/login' ? '/' : route.fullPath);
    } else {
      await router.replace('/login');
    }
    retryCount.value++;
    await fetchPendingCount();
  } catch { /* A failed retry preserves the connection notice and login screen. */ }
  finally { reconnecting.value = false; }
}
watch(() => [route.path, session.generation], () => { pendingCount.value = 0; void fetchPendingCount(); }, { immediate: true });
</script>

<style scoped>
.mobile-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  max-width: 600px;
  margin: 0 auto;
  background-color: #f7f8fa;
  position: relative;
}

.content-wrapper {
  flex: 1;
  padding-bottom: 20px;
}

:deep(.van-tabbar--fixed) {
  max-width: 600px;
  left: 50% !important;
  transform: translateX(-50%);
}
</style>
