<template>
  <div class="business-page">
    <div class="page-toolbar">
      <a-radio-group v-model:value="statusFilter" button-style="solid" @change="fetchTodos">
        <a-radio-button value="PENDING">待处理 ({{ pendingCount }})</a-radio-button>
        <a-radio-button value="RESOLVED">已完成</a-radio-button>
        <a-radio-button value="DISMISSED">已忽略</a-radio-button>
        <a-radio-button value="ALL">全部</a-radio-button>
      </a-radio-group>
    </div>

    <!-- 待办列表 -->
    <a-spin :spinning="loading">
      <div v-if="todos.length === 0" style="padding: 60px 0; text-align: center;">
        <a-empty description="当前暂无待办事项，一切财务计划井然有序！" />
      </div>

      <div v-else style="display: flex; flex-direction: column; gap: 16px;">
        <a-card
          v-for="item in todos"
          :key="item.id"
          size="small"
          :bordered="true"
          :style="getCardStyle(item)"
        >
          <div class="todo-card-content">
            <div style="flex: 1;">
              <div class="todo-card-title">
                <a-tag :color="getTypeTagColor(item.type)">
                  {{ getTypeName(item.type) }}
                </a-tag>
                <span style="font-weight: 600; font-size: 15px; color: #333;">
                  {{ item.title }}
                </span>
                <a-tag v-if="item.status === 'RESOLVED'" color="default">已处理</a-tag>
                <a-tag v-else-if="item.status === 'DISMISSED'" color="default">已忽略</a-tag>
              </div>

              <div style="color: #666; font-size: 13.5px; line-height: 1.6; margin-bottom: 8px;">
                {{ item.content }}
              </div>

              <div style="color: #aaa; font-size: 12px;">
                发生时间：{{ formatTime(item.createdAt) }}
              </div>
            </div>

            <!-- 操作按钮区 (仅 PENDING 状态显示核心操作) -->
            <div v-if="item.status === 'PENDING'" class="todo-actions">
              <!-- 分期扣款失败: 立即补扣 -->
              <template v-if="item.type === 'LIABILITY_OVERDUE'">
                <a-button type="primary" danger size="small" @click="openRetryModal(item)">
                  立即补扣
                </a-button>
                <a-button size="small" @click="dismissTodo(item.id)">
                  忽略
                </a-button>
              </template>

              <!-- 周期固定收支: 前往核对 -->
              <template v-else-if="item.type === 'CYCLE_FIXED_ITEMS'">
                <a-button type="primary" size="small" @click="goToBudget(item)">
                  前往预算表核对
                </a-button>
                <a-button size="small" @click="resolveTodo(item.id)">
                  标记已核对
                </a-button>
              </template>

              <!-- 心愿达成: 立即兑现 / 暂不兑现 -->
              <template v-else-if="item.type === 'WISHLIST_REACHED'">
                <a-button type="primary" style="background: #477824; border-color: #477824;" size="small" @click="openRealizeModal(item)">
                  🎉 立即兑现
                </a-button>
                <a-button size="small" @click="dismissTodo(item.id)">
                  暂不兑现
                </a-button>
              </template>
            </div>
          </div>
        </a-card>
      </div>
    </a-spin>

    <!-- 分期立即补扣弹窗 -->
    <a-modal v-model:open="retryModalVisible" title="分期还款补扣" @ok="handleRetryOk">
      <div v-if="currentTodo" style="margin-bottom: 16px;">
        <p style="margin-bottom: 6px;"><b>待还事项：</b>{{ currentTodo.title }}</p>
        <p style="color: #666; font-size: 13px;">{{ currentTodo.content }}</p>
      </div>
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="扣款账户" required help="支持指定其他有充足余额的账户完成补扣">
          <a-select v-model:value="selectedAccountId" placeholder="请选择扣款账户">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }} (可用余额: ¥{{ acc.currentBalance }})
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 心愿兑现弹窗 -->
    <a-modal v-model:open="realizeModalVisible" title="实现心愿" @ok="handleRealizeOk">
      <div v-if="currentTodo" style="margin-bottom: 16px;">
        <p style="margin-bottom: 6px;"><b>达成心愿：</b>{{ currentTodo.title }}</p>
        <p style="color: #477824; font-size: 13px;">{{ currentTodo.content }}</p>
      </div>
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="扣款账户" required help="心愿达成将从该账户划扣资金并生成支出流水">
          <a-select v-model:value="selectedAccountId" placeholder="请选择扣款账户">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }} (可用余额: ¥{{ acc.currentBalance }})
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const router = useRouter();

const todos = ref<any[]>([]);
const pendingCount = ref<number>(0);
const statusFilter = ref<string>('PENDING');
const loading = ref<boolean>(false);
const accounts = ref<any[]>([]);

// 补扣分期弹窗
const retryModalVisible = ref(false);
const realizeModalVisible = ref(false);
const currentTodo = ref<any>(null);
const selectedAccountId = ref<number | null>(null);

const fetchTodos = async () => {
  loading.value = true;
  try {
    todos.value = await request.get('/todos', { params: { status: statusFilter.value } });
    const countRes: any = await request.get('/todos/pending-count');
    pendingCount.value = countRes.count || 0;
  } catch (e) {
  } finally {
    loading.value = false;
  }
};

const fetchAccounts = async () => {
  try {
    accounts.value = await request.get('/accounts');
  } catch (e) {}
};

const formatTime = (timeStr: string) => {
  if (!timeStr) return '';
  return timeStr.replace('T', ' ').substring(0, 19);
};

const getTypeName = (type: string) => {
  switch (type) {
    case 'LIABILITY_OVERDUE': return '分期扣款失败';
    case 'CYCLE_FIXED_ITEMS': return '新周期账单提醒';
    case 'WISHLIST_REACHED': return '心愿达成';
    default: return '待办事项';
  }
};

const getTypeTagColor = (type: string) => {
  switch (type) {
    case 'LIABILITY_OVERDUE': return 'error';
    case 'CYCLE_FIXED_ITEMS': return 'processing';
    case 'WISHLIST_REACHED': return 'success';
    default: return 'default';
  }
};

const getCardStyle = (item: any) => {
  if (item.status !== 'PENDING') {
    return { opacity: '0.65', background: '#fafafa' };
  }
  if (item.type === 'LIABILITY_OVERDUE') {
    return { borderLeft: '4px solid #C94747', background: '#fff2f0' };
  }
  if (item.type === 'WISHLIST_REACHED') {
    return { borderLeft: '4px solid #477824', background: '#f6ffed' };
  }
  return { borderLeft: '4px solid #1890ff', background: '#e6f7ff' };
};

// 忽略待办
const dismissTodo = async (id: number) => {
  try {
    await request.post(`/todos/${id}/dismiss`);
    message.info('已忽略该待办');
    fetchTodos();
  } catch (e) {}
};

// 标记完成
const resolveTodo = async (id: number) => {
  try {
    await request.post(`/todos/${id}/resolve`);
    message.success('已标记处理完成');
    fetchTodos();
  } catch (e) {}
};

// 跳转预算表
const goToBudget = async (item: any) => {
  await resolveTodo(item.id);
  router.push('/budget');
};

// 打开分期补扣弹窗
const openRetryModal = (item: any) => {
  currentTodo.value = item;
  selectedAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;
  retryModalVisible.value = true;
};

// 确认补扣
const handleRetryOk = async () => {
  if (!selectedAccountId.value) {
    message.error('请选择扣款账户');
    return;
  }
  try {
    await request.post(`/todos/${currentTodo.value.id}/retry-repay`, {
      accountId: selectedAccountId.value
    });
    message.success('补扣成功！待办已核销');
    retryModalVisible.value = false;
    fetchTodos();
    fetchAccounts();
  } catch (e) {}
};

// 打开心愿兑现弹窗
const openRealizeModal = (item: any) => {
  currentTodo.value = item;
  selectedAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;
  realizeModalVisible.value = true;
};

// 确认兑现心愿
const handleRealizeOk = async () => {
  if (!selectedAccountId.value) {
    message.error('请选择扣款账户');
    return;
  }
  try {
    await request.post(`/wishlists/${currentTodo.value.bizId}/realize`, {
      accountId: selectedAccountId.value
    });
    message.success('恭喜！心愿实现成功，待办已核销');
    realizeModalVisible.value = false;
    fetchTodos();
    fetchAccounts();
  } catch (e) {}
};

onMounted(() => {
  fetchTodos();
  fetchAccounts();
});
</script>
