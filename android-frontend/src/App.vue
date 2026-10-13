<template>
  <div class="mobile-container">
    <div class="content-wrapper">
      <router-view />
    </div>

    <!-- 底部常驻 Tabbar -->
    <van-tabbar v-model="activeTab" route fixed placeholder safe-area-inset-bottom active-color="#1989fa">
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
import { ref, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import { todoService, inspectionService } from './services';

const activeTab = ref(0);
const pendingCount = ref<number>(0);
const route = useRoute();

const fetchPendingCount = async () => {
  try {
    pendingCount.value = await todoService.countPending();
  } catch (e) {}
};

watch(() => route.path, () => {
  fetchPendingCount();
});

onMounted(async () => {
  await inspectionService.executeAllChecks();
  await fetchPendingCount();
});
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
