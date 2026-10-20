<template>
  <div class="business-page">
    <div class="page-toolbar">
      <a-space wrap>
        <a-button type="primary" @click="showTargetModal">新增目标</a-button>
        <span style="font-size: 14px; color: #666; margin-left: 8px;">
          可用净资产 (总资产 - 待还负债):
          <b :style="{ color: availableNetAssets >= 0 ? '#557344' : '#C94747', fontSize: '16px' }">
            ¥{{ availableNetAssets }}
          </b>
        </span>
        <span style="font-size: 13px; color: #999; margin-left: 8px;">
          (买车、买房、大额储备等，以可用净资产为真实托底标尺)
        </span>
      </a-space>
    </div>

    <a-table :scroll="{ x: 'max-content' }" :dataSource="targets" :columns="targetColumns" rowKey="id">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'targetAmount'">
          ¥{{ record.targetAmount }}
        </template>
        <template v-else-if="column.key === 'progress'">
          <a-progress :percent="record.progress || 0"
                      :stroke-color="record.isRealized === 1 ? '#477824' : '#557344'"
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
            <span style="color: #557344; font-weight: 500;">
              {{ record.estimatedCompletionDate }}
            </span>
          </a-tooltip>
        </template>
        <template v-else-if="column.key === 'isRealized'">
          <a-tag :color="record.isRealized === 1 ? 'green' : 'purple'">
            {{ record.isRealized === 1 ? '已实现' : '进行中' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <template v-if="record.isRealized === 0">
              <a-tooltip :title="availableNetAssets < record.targetAmount ? `可用净资产不足以实现此目标 (缺口: ¥${record.gap || 0})` : ''">
                <a-button
                  type="primary"
                  size="small"
                  :disabled="availableNetAssets < record.targetAmount"
                  @click="showRealizeModal(record)">
                  实现目标
                </a-button>
              </a-tooltip>
            </template>
            <template v-else>
              <a-popconfirm title="确定撤销该目标的实现状态吗？扣款流水将被删除并退回账户余额" @confirm="handleUnrealize(record)">
                <a-button type="link" size="small" style="color: #C94747">撤销</a-button>
              </a-popconfirm>
            </template>
            <a-button type="link" size="small" @click="editTarget(record)">编辑</a-button>
            <a-popconfirm title="确定删除吗？" @confirm="deleteTarget(record.id)">
              <a-button type="link" size="small" danger>删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- 新增 / 编辑目标弹窗 -->
    <a-modal v-model:open="targetVisible" :title="targetEditingId ? '编辑目标' : '新增目标'" @ok="handleTargetOk">
      <a-form :model="targetForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="目标名称" required>
          <a-input v-model:value="targetForm.name" placeholder="如：买车、购房首付、大额储蓄金" />
        </a-form-item>
        <a-form-item label="目标金额" required>
          <a-input-number v-model:value="targetForm.targetAmount" :min="0.01" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item label="立项时间" required help="目标确立时间，默认为当前日期">
          <a-date-picker v-model:value="targetForm.startDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
        <a-form-item label="截止日期">
          <a-date-picker v-model:value="targetForm.deadline" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 实现目标弹窗 -->
    <a-modal v-model:open="realizeVisible" title="实现目标（扣款设定）" @ok="handleRealizeOk">
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="扣款账户" required help="实现目标将生成一笔真实支出记录，分类自动绑定为【目标】">
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

const targets = ref<any[]>([]);
const accounts = ref<any[]>([]);
const availableNetAssets = ref(0);

const targetColumns = [
  { title: '状态', key: 'isRealized', width: 90 },
  { title: '目标名称', dataIndex: 'name', key: 'name' },
  { title: '目标金额', key: 'targetAmount', align: 'right' as const },
  { title: '立项时间', dataIndex: 'startDate', key: 'startDate' },
  { title: '净资产进度', key: 'progress' },
  { title: '预计实现时间', key: 'estimatedCompletionDate' },
  { title: '截止日期', dataIndex: 'deadline', key: 'deadline' },
  { title: '操作', key: 'action' }
];

const targetVisible = ref(false);
const targetEditingId = ref<number | null>(null);
const targetForm = ref({
  name: '',
  targetAmount: 0,
  type: 'LONG_TERM',
  startDate: new Date().toISOString().split('T')[0],
  deadline: ''
});

const realizeVisible = ref(false);
const realizeTargetId = ref<number | null>(null);
const realizeAccountId = ref<number | null>(null);

const fetchData = async () => {
  targets.value = await request.get('/targets');
  accounts.value = await request.get('/accounts');
  const stats: any = await request.get('/stats');
  availableNetAssets.value = stats.availableAssets || 0;
};

const showTargetModal = () => {
  targetEditingId.value = null;
  targetForm.value = {
    name: '',
    targetAmount: 0,
    type: 'LONG_TERM',
    startDate: new Date().toISOString().split('T')[0],
    deadline: ''
  };
  targetVisible.value = true;
};

const editTarget = (record: any) => {
  targetEditingId.value = record.id;
  targetForm.value = {
    name: record.name,
    targetAmount: record.targetAmount,
    type: 'LONG_TERM',
    startDate: record.startDate,
    deadline: record.deadline || ''
  };
  targetVisible.value = true;
};

const handleTargetOk = async () => {
  try {
    if (targetEditingId.value) {
      await request.put(`/targets/${targetEditingId.value}`, targetForm.value);
    } else {
      await request.post('/targets', targetForm.value);
    }
    message.success('保存成功');
    targetVisible.value = false;
    fetchData();
  } catch (e) {}
};

const deleteTarget = async (id: number) => {
  try {
    await request.delete(`/targets/${id}`);
    message.success('删除成功');
    fetchData();
  } catch (e) {}
};

const showRealizeModal = (record: any) => {
  realizeTargetId.value = record.id;
  realizeAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;
  realizeVisible.value = true;
};

const handleRealizeOk = async () => {
  if (!realizeAccountId.value) {
    message.error('请选择扣款账户');
    return;
  }
  try {
    await request.post(`/targets/${realizeTargetId.value}/realize`, { accountId: realizeAccountId.value });
    message.success('目标实现成功！账户已扣款');
    realizeVisible.value = false;
    fetchData();
  } catch (e) {}
};

const handleUnrealize = async (record: any) => {
  try {
    await request.post(`/targets/${record.id}/unrealize`);
    message.success('已成功撤销目标实现状态，资金已退回账户！');
    fetchData();
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>
