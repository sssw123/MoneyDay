<template>
  <div class="todos-page">
    <van-nav-bar title="待办中心" fixed placeholder />

    <van-tabs v-model:active="statusFilter" @change="fetchTodos" color="#1989fa">
      <van-tab title="待处理" name="PENDING" />
      <van-tab title="已完成" name="RESOLVED" />
      <van-tab title="已忽略" name="DISMISSED" />
      <van-tab title="全部" name="ALL" />
    </van-tabs>

    <van-pull-refresh v-model="refreshing" @refresh="fetchTodos">
      <div class="content-box">
        <div v-if="todos.length === 0" style="padding: 60px 0; text-align: center;">
          <van-empty description="当前暂无待办事项，一切财务计划井然有序！" />
        </div>

        <div v-else class="todo-list">
          <div
            v-for="item in todos"
            :key="item.id"
            class="todo-card"
            :class="getCardClass(item)"
          >
            <div class="card-head">
              <van-tag :type="getTagType(item.type)" size="medium">
                {{ getTypeName(item.type) }}
              </van-tag>
              <span class="todo-status-tag" v-if="item.status !== 'PENDING'">
                {{ item.status === 'RESOLVED' ? '已处理' : '已忽略' }}
              </span>
            </div>

            <div class="todo-title">{{ item.title }}</div>
            <div class="todo-content">{{ item.content }}</div>
            <div class="todo-time">{{ formatTime(item.createdAt) }}</div>

            <!-- 操作按钮 (仅在待处理状态展示) -->
            <div class="card-actions" v-if="item.status === 'PENDING'">
              <template v-if="item.type === 'LIABILITY_OVERDUE'">
                <van-button size="small" type="danger" @click="openRetryModal(item)">
                  立即补扣
                </van-button>
                <van-button size="small" plain @click="dismissTodo(item.id)">
                  忽略
                </van-button>
              </template>

              <template v-else-if="item.type === 'CYCLE_FIXED_ITEMS'">
                <van-button size="small" type="primary" @click="goToBudget(item)">
                  前往核对
                </van-button>
                <van-button size="small" plain @click="resolveTodo(item.id)">
                  标记已核对
                </van-button>
              </template>

              <template v-else-if="item.type === 'WISHLIST_REACHED'">
                <van-button size="small" type="primary" color="#07c160" @click="openRealizeModal(item)">
                  🎉 立即兑现
                </van-button>
                <van-button size="small" plain @click="dismissTodo(item.id)">
                  暂不兑现
                </van-button>
              </template>
            </div>
          </div>
        </div>
      </div>
    </van-pull-refresh>

    <!-- 补扣/兑现通用账户选择弹窗 -->
    <van-popup v-model:show="modalVisible" position="bottom" round safe-area-inset-bottom>
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="modalVisible = false">取消</span>
          <span class="title">{{ modalTitle }}</span>
          <span class="confirm" @click="handleModalOk">确认</span>
        </div>
        <div style="padding: 12px 16px;">
          <p><b>事项：</b>{{ currentTodo?.title }}</p>
          <p style="color: #666; font-size: 13px;">{{ currentTodo?.content }}</p>
        </div>
        <van-cell-group inset>
          <van-cell title="扣款账户" is-link :value="selectedAccountName || '请选择账户'" @click="showAccountPicker = true" required />
        </van-cell-group>
      </div>
    </van-popup>

    <van-popup v-model:show="showAccountPicker" position="bottom" round>
      <van-picker title="选择账户" :columns="accountColumns" @confirm="onAccountConfirm" @cancel="showAccountPicker = false" />
    </van-popup>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { showToast } from 'vant';
import { todoService, accountService, wishlistService } from '../services';

const router = useRouter();

const statusFilter = ref('PENDING');
const refreshing = ref(false);
const todos = ref<any[]>([]);
const accounts = ref<any[]>([]);

const modalVisible = ref(false);
const modalTitle = ref('');
const currentTodo = ref<any>(null);
const selectedAccountId = ref<number | null>(null);
const showAccountPicker = ref(false);

const getAccountName = (id: number) => {
  const a = accounts.value.find((acc: any) => acc.id === id);
  return a ? a.name : '';
};
const selectedAccountName = computed(() => selectedAccountId.value ? getAccountName(selectedAccountId.value) : '');

const accountColumns = computed(() => {
  return accounts.value.map((a: any) => ({
    text: `${a.name} (¥${a.currentBalance})`,
    value: a.id
  }));
});

const formatTime = (timeStr: string) => {
  if (!timeStr) return '';
  return timeStr.replace('T', ' ').substring(0, 16);
};

const getTypeName = (type: string) => {
  switch (type) {
    case 'LIABILITY_OVERDUE': return '分期扣款失败';
    case 'CYCLE_FIXED_ITEMS': return '新周期账单';
    case 'WISHLIST_REACHED': return '心愿达成';
    default: return '待办';
  }
};

const getTagType = (type: string) => {
  switch (type) {
    case 'LIABILITY_OVERDUE': return 'danger';
    case 'CYCLE_FIXED_ITEMS': return 'primary';
    case 'WISHLIST_REACHED': return 'success';
    default: return 'default';
  }
};

const getCardClass = (item: any) => {
  if (item.status !== 'PENDING') return 'card-done';
  if (item.type === 'LIABILITY_OVERDUE') return 'card-danger';
  if (item.type === 'WISHLIST_REACHED') return 'card-success';
  return 'card-info';
};

const fetchTodos = async () => {
  try {
    const list = await todoService.getTodos(statusFilter.value);
    todos.value = list || [];
  } catch (e) {
  } finally {
    refreshing.value = false;
  }
};

const fetchAccounts = async () => {
  try {
    accounts.value = await accountService.getAccounts() || [];
  } catch (e) {}
};

const onAccountConfirm = ({ selectedOptions }: any) => {
  if (selectedOptions[0]) {
    selectedAccountId.value = selectedOptions[0].value;
  }
  showAccountPicker.value = false;
};

const dismissTodo = async (id: number) => {
  try {
    await todoService.dismissTodo(id);
    showToast('已忽略');
    fetchTodos();
  } catch (e) {}
};

const resolveTodo = async (id: number) => {
  try {
    await todoService.resolveTodo(id);
    showToast({ type: 'success', message: '已标记完成' });
    fetchTodos();
  } catch (e) {}
};

const goToBudget = async (item: any) => {
  await resolveTodo(item.id);
  router.push('/budget');
};

const openRetryModal = (item: any) => {
  currentTodo.value = item;
  modalTitle.value = '分期还款补扣';
  selectedAccountId.value = accounts.value[0]?.id || null;
  modalVisible.value = true;
};

const openRealizeModal = (item: any) => {
  currentTodo.value = item;
  modalTitle.value = '兑现心愿';
  selectedAccountId.value = accounts.value[0]?.id || null;
  modalVisible.value = true;
};

const handleModalOk = async () => {
  if (!selectedAccountId.value) {
    showToast('请选择扣款账户');
    return;
  }
  try {
    if (currentTodo.value.type === 'LIABILITY_OVERDUE') {
      await todoService.retryLiabilityRepayment(
        currentTodo.value.id,
        selectedAccountId.value
      );
      showToast({ type: 'success', message: '补扣成功！' });
    } else if (currentTodo.value.type === 'WISHLIST_REACHED') {
      await wishlistService.realizeWishlist(
        Number(currentTodo.value.bizId),
        selectedAccountId.value
      );
      showToast({ type: 'success', message: '心愿实现成功！' });
    }
    modalVisible.value = false;
    fetchTodos();
    fetchAccounts();
  } catch (e) {}
};

onMounted(() => {
  fetchTodos();
  fetchAccounts();
});
</script>

<style scoped>
.todos-page {
  padding-bottom: 20px;
}

.content-box {
  padding: 12px 16px;
}

.todo-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.todo-card {
  background: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
  border-left: 4px solid #1989fa;
}

.card-danger {
  border-left-color: #ee0a24;
  background: #fff8f8;
}

.card-success {
  border-left-color: #07c160;
  background: #f8fff8;
}

.card-info {
  border-left-color: #1989fa;
  background: #f7faff;
}

.card-done {
  border-left-color: #dcdee0;
  opacity: 0.7;
}

.card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.todo-status-tag {
  font-size: 11px;
  color: #969799;
}

.todo-title {
  font-size: 15px;
  font-weight: 600;
  color: #323233;
  margin-bottom: 6px;
}

.todo-content {
  font-size: 13px;
  color: #646566;
  line-height: 1.5;
  margin-bottom: 8px;
}

.todo-time {
  font-size: 11px;
  color: #969799;
  margin-bottom: 10px;
}

.card-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  border-top: 1px dashed #ebedf0;
  padding-top: 10px;
}

.popup-box {
  padding-bottom: 20px;
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #f2f3f5;
}

.popup-header .title {
  font-weight: 600;
  font-size: 16px;
}

.popup-header .cancel {
  color: #969799;
  font-size: 14px;
}

.popup-header .confirm {
  color: #1989fa;
  font-weight: 500;
  font-size: 14px;
}
</style>
