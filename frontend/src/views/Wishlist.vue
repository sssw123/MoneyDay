<template>
  <div>
    <div style="margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
      <a-space wrap>
        <a-button type="primary" @click="showAddModal">新增心愿</a-button>
        <span style="font-size: 14px; color: #666; margin-left: 8px;">
          当前全局累计结余池 (心愿标尺):
          <b :style="{ color: cumulativeBalance >= 0 ? '#52c41a' : '#ff4d4f', fontSize: '16px' }">
            ¥{{ cumulativeBalance }}
          </b>
        </span>
        <span style="font-size: 13px; color: #999; margin-left: 8px;">
          (心愿单随缘消费，不占预留资金，实现完全看心情)
        </span>
      </a-space>
    </div>

    <a-table :dataSource="wishlists" :columns="columns" rowKey="id">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'isRealized'">
          <a-tag :color="record.isRealized === 1 ? 'green' : 'pink'">
            {{ record.isRealized === 1 ? '已实现' : '心愿中' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'targetAmount'">
          ¥{{ record.targetAmount }}
        </template>
        <template v-else-if="column.key === 'progress'">
          <a-progress :percent="record.progress || 0"
                      :stroke-color="record.isRealized === 1 ? '#52c41a' : '#eb2f96'"
                      :status="(record.progress || 0) >= 100 ? 'success' : 'active'" />
        </template>
        <template v-else-if="column.key === 'estimatedCompletionDate'">
          <span v-if="record.isRealized === 1">-</span>
          <a-tag v-else-if="record.estimatedCompletionDate === '当前可实现'" color="green">
            当前可实现
          </a-tag>
          <a-tooltip v-else-if="record.estimatedCompletionDate === '无法预估'" :title="record.estimatedReason || '存钱速度无盈余，无法预估'">
            <a-tag color="default">无法预估</a-tag>
          </a-tooltip>
          <a-tooltip v-else-if="record.isEstimatedFallback" :title="record.estimatedReason">
            <a-tag color="orange" style="cursor: pointer;">
              {{ record.estimatedCompletionDate }} ⚠
            </a-tag>
          </a-tooltip>
          <a-tooltip v-else :title="record.estimatedReason">
            <span style="color: #eb2f96; font-weight: 500;">
              {{ record.estimatedCompletionDate }}
            </span>
          </a-tooltip>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <template v-if="record.isRealized === 0">
              <a-tooltip :title="cumulativeBalance < record.targetAmount ? `当前累计结余不足 (¥${cumulativeBalance})，点击可任性实现` : ''">
                <a-button
                  type="primary"
                  size="small"
                  :style="cumulativeBalance < record.targetAmount ? { background: '#eb2f96', borderColor: '#eb2f96' } : {}"
                  @click="showRealizeModal(record)">
                  实现心愿
                </a-button>
              </a-tooltip>
            </template>
            <template v-else>
              <a-popconfirm title="确定撤销该心愿的实现状态吗？扣款流水将被删除并退回账户余额" @confirm="handleUnrealize(record)">
                <a style="color: #ff4d4f">撤销</a>
              </a-popconfirm>
            </template>
            <a @click="editWishlist(record)">编辑</a>
            <a-popconfirm title="确定删除吗？" @confirm="deleteWishlist(record.id)">
              <a style="color: red">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- 新增 / 编辑心愿弹窗 -->
    <a-modal v-model:open="modalVisible" :title="editingId ? '编辑心愿' : '新增心愿'" @ok="handleOk">
      <a-form :model="form" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="心愿名称" required>
          <a-input v-model:value="form.name" placeholder="如：降噪耳机、周末露营、想买的衣服" />
        </a-form-item>
        <a-form-item label="心愿金额" required>
          <a-input-number v-model:value="form.targetAmount" :min="0.01" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item label="立项时间" required help="心愿加入清单的时间">
          <a-date-picker v-model:value="form.startDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
        <a-form-item label="期望日期">
          <a-date-picker v-model:value="form.deadline" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 实现心愿（扣款设定）弹窗 -->
    <a-modal v-model:open="realizeVisible" title="实现心愿（扣款设定）" @ok="handleRealizeOk">
      <div v-if="realizeRecord && cumulativeBalance < (realizeRecord.targetAmount || 0)" style="margin-bottom: 16px;">
        <a-alert
          type="warning"
          show-icon
          message="结余超支软警告"
          :description="`当前全局累计结余为 ¥${cumulativeBalance}，小于心愿金额 ¥${realizeRecord.targetAmount}。兑现此心愿将导致结余超支或动用老本储蓄。兑现心愿完全看心情，确定要任性实现吗？`"
        />
      </div>
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="扣款账户" required help="实现心愿将生成一笔真实支出记录，分类自动绑定为【目标】">
          <a-select v-model:value="realizeAccountId" placeholder="请选择扣款账户">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }} (余额: ¥{{ acc.currentBalance }})
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const wishlists = ref<any[]>([]);
const accounts = ref<any[]>([]);
const cumulativeBalance = ref(0);

const columns = [
  { title: '状态', key: 'isRealized', width: 90 },
  { title: '心愿名称', dataIndex: 'name', key: 'name' },
  { title: '心愿金额', key: 'targetAmount' },
  { title: '立项时间', dataIndex: 'startDate', key: 'startDate' },
  { title: '结余进度', key: 'progress' },
  { title: '预计达成时间', key: 'estimatedCompletionDate' },
  { title: '期望日期', dataIndex: 'deadline', key: 'deadline' },
  { title: '操作', key: 'action' }
];

const modalVisible = ref(false);
const editingId = ref<number | null>(null);
const form = ref({
  name: '',
  targetAmount: 0,
  startDate: new Date().toISOString().split('T')[0],
  deadline: ''
});

const realizeVisible = ref(false);
const realizeRecord = ref<any>(null);
const realizeAccountId = ref<number | null>(null);

const fetchData = async () => {
  wishlists.value = await request.get('/wishlists');
  accounts.value = await request.get('/accounts');
  const stats: any = await request.get('/stats');
  cumulativeBalance.value = stats.cumulativeBalance || 0;
};

const showAddModal = () => {
  editingId.value = null;
  form.value = {
    name: '',
    targetAmount: 0,
    startDate: new Date().toISOString().split('T')[0],
    deadline: ''
  };
  modalVisible.value = true;
};

const editWishlist = (record: any) => {
  editingId.value = record.id;
  form.value = {
    name: record.name,
    targetAmount: record.targetAmount,
    startDate: record.startDate,
    deadline: record.deadline || ''
  };
  modalVisible.value = true;
};

const handleOk = async () => {
  try {
    if (editingId.value) {
      await request.put(`/wishlists/${editingId.value}`, form.value);
    } else {
      await request.post('/wishlists', form.value);
    }
    message.success('保存成功');
    modalVisible.value = false;
    fetchData();
  } catch (e) {}
};

const deleteWishlist = async (id: number) => {
  try {
    await request.delete(`/wishlists/${id}`);
    message.success('删除成功');
    fetchData();
  } catch (e) {}
};

const showRealizeModal = (record: any) => {
  realizeRecord.value = record;
  realizeAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;
  realizeVisible.value = true;
};

const handleRealizeOk = async () => {
  if (!realizeAccountId.value) {
    message.error('请选择扣款账户');
    return;
  }
  try {
    await request.post(`/wishlists/${realizeRecord.value.id}/realize`, { accountId: realizeAccountId.value });
    message.success('心愿兑现成功！账户已扣款');
    realizeVisible.value = false;
    fetchData();
  } catch (e) {}
};

const handleUnrealize = async (record: any) => {
  try {
    await request.post(`/wishlists/${record.id}/unrealize`);
    message.success('已成功撤销心愿，资金已退回账户！');
    fetchData();
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>
